import http from '@ohos.net.http';
import { AppError } from '../common/AppError';

const MAX_ATTEMPTS = 3;
const BASE_RETRY_DELAY_MS = 1000;
const MAX_RETRY_DELAY_MS = 5000;
// Rate limiting and overload on the public APIs usually clear within seconds.
const RETRYABLE_STATUS_CODES: number[] = [429, 502, 503, 504];

export async function makeHttpRequest<T>(url: string, method: http.RequestMethod): Promise<T> {
  for (let attempt = 1; ; attempt++) {
    const response = await sendRequest(url, method);
    if (response.responseCode === 200) {
      try {
        return JSON.parse(response.result as string) as T;
      } catch (error) {
        throw new AppError(1003, 'Invalid response format');
      }
    }
    if (attempt >= MAX_ATTEMPTS || !RETRYABLE_STATUS_CODES.includes(response.responseCode)) {
      throw new AppError(1002, httpErrorMessage(response.responseCode));
    }
    const delay = retryDelay(response, attempt);
    console.warn(`[makeHttpRequest] HTTP ${response.responseCode}, retry ${attempt}/${MAX_ATTEMPTS - 1} in ${delay} ms`);
    await sleep(delay);
  }
}

async function sendRequest(url: string, method: http.RequestMethod): Promise<http.HttpResponse> {
  // An HttpRequest object serves a single request, so every attempt needs a new one.
  const request = http.createHttp();
  try {
    return await request.request(url, {
      method: method,
      header: { 'Content-Type': 'application/json', 'User-Agent': 'MyMeteo/1.0 (https://github.com/pmandes/app-MyMeteo)' },
      connectTimeout: 10000,
      readTimeout: 10000
    });
  } catch (error) {
    throw new AppError(1001, 'Unable to fetch data. Check your connection.');
  } finally {
    request.destroy();
  }
}

function retryDelay(response: http.HttpResponse, attempt: number): number {
  const retryAfter = headerValue(response.header, 'retry-after');
  const retryAfterSeconds = retryAfter ? Number(retryAfter) : NaN;
  const delay = Number.isFinite(retryAfterSeconds) && retryAfterSeconds >= 0
    ? retryAfterSeconds * 1000
    : BASE_RETRY_DELAY_MS * Math.pow(2, attempt - 1);
  return Math.min(delay, MAX_RETRY_DELAY_MS);
}

function headerValue(header: Object, name: string): string | undefined {
  const headers = (header ?? {}) as Record<string, string>;
  const key = Object.keys(headers).find(key => key.toLowerCase() === name);
  return key === undefined ? undefined : String(headers[key]);
}

function httpErrorMessage(responseCode: number): string {
  if (responseCode === 429) {
    return 'Too many requests (HTTP 429). Try again in a moment.';
  }
  if (responseCode === 502 || responseCode === 503 || responseCode === 504) {
    return `Service temporarily unavailable (HTTP ${responseCode}). Try again in a moment.`;
  }
  return 'HTTP error ' + responseCode;
}

function sleep(ms: number): Promise<void> {
  return new Promise<void>(resolve => setTimeout(resolve, ms));
}
