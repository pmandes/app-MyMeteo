import http from '@ohos.net.http';
import { AppError } from '../common/AppError';

export async function makeHttpRequest<T>(url: string, method: http.RequestMethod): Promise<T> {
  const request = http.createHttp();
  try {
    const response = await request.request(url, {
      method: method,
      header: { 'Content-Type': 'application/json', 'User-Agent': 'MyMeteo/1.0 (https://github.com/pmandes/app-MyMeteo)' },
      connectTimeout: 10000,
      readTimeout: 10000
    });
    if (response.responseCode !== 200) {
      throw new AppError(1002, 'HTTP error ' + response.responseCode);
    }
    try {
      return JSON.parse(response.result as string) as T;
    } catch (error) {
      throw new AppError(1003, 'Invalid response format');
    }
  } catch (error) {
    if (error instanceof AppError) {
      throw error;
    }
    throw new AppError(1001, 'Unable to fetch data. Check your connection.');
  } finally {
    request.destroy();
  }
}
