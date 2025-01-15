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
      if (err) {
        console.error('An error occurred:', JSON.stringify(err));
        reject(new AppError(1001, 'Unable to fetch data'));
        return;
      }
      try {
        console.debug('Response code:' + data.responseCode);

        if (data.responseCode != 200) {
          reject(new AppError(1002, 'HTTP error ' + data.responseCode));
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