/**
 * Sends an HTTP request and returns the response data of a generic type.
 * This function uses the '@ohos.net.http' module to make the request and
 * parse the JSON response body.
 *
 * @template T - The expected type of the JSON-parsed response.
 * @param {string} url - The target URL for the HTTP request.
 * @param {http.RequestMethod} method - The HTTP method (GET, POST, etc.).
 * @returns {Promise<T>} A promise that resolves to the parsed response data of type T.
 * @throws {AppError} Throws an AppError if the network request fails,
 *                    the response code is not 200, or JSON parsing fails.
 */
import http from '@ohos.net.http';
import { AppError } from '../common/AppError';

export async function makeHttpRequest<T>(url: string, method: http.RequestMethod): Promise<T> {
  return new Promise((resolve, reject) => {
    const httpRequest = http.createHttp();

    httpRequest.request(url, {
      method: method,
      header: {
        'Content-Type': 'application/json'
      }
    }, (err, data: http.HttpResponse) => {
      console.debug('HTTP request: ' + method + ' ' + url);

      if (err) {
        console.error('An error occurred:', JSON.stringify(err));
        reject(new AppError(1001, 'Unable to fetch data'));
        return;
      }

      try {
        console.debug('HTTP response code:' + data.responseCode);
        if (data.responseCode !== 200) {
          reject(new AppError(1002, 'HTTP error ' + data.responseCode));
          return;
        }

        const response: T = JSON.parse(data.result as string);
        resolve(response);
      } catch (parseError) {
        console.error('Error parsing data:', parseError);
        reject(new AppError(1003, 'Invalid response format'));
      }
    });
  });
}
