import http from '@ohos.net.http';

export async function makeHttpRequest<T>(url: string, method: http.RequestMethod): Promise<T> {
  return new Promise((resolve, reject) => {
    const httpRequest = http.createHttp();
    httpRequest.request(url, {
      method: method,
      header: {
        'Content-Type': 'application/json'
      }
    }, (err, data) => {
      if (err) {
        console.error('An error occurred:', JSON.stringify(err));
        reject(new Error('Unable to fetch data'));
        return;
      }
      try {
        console.info('code:' + data.responseCode);
        const response: T = JSON.parse(data.result as string);
        resolve(response);
      } catch (parseError) {
        console.error('Error parsing data:', parseError);
        reject(new Error('Invalid response format'));
      }
    });
  });
}