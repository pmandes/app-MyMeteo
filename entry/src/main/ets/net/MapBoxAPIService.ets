import http from '@ohos.net.http';
import image from '@ohos.multimedia.image';
import { BASE_API_MAP_BOX_URL } from './baseUrls';

export class MapBoxAPIService {

  private API_MAP_BOX_URL: string = `${BASE_API_MAP_BOX_URL}/styles/v1/mapbox/streets-v12/static/{longitude},{latitude},{zoom},0/500x400@2x?access_token=pk.eyJ1IjoicGF3ZWxtYW5kZXMiLCJhIjoiY200c2Y1NDlnMDA2cTJwc2lkbTIwdHljZyJ9.L2vMgVNik2ERoqK-nb4T_g`;

  getMapImageUrl(longitude: number, latitude: number, zoom: number): Promise<string> {
    const url = this.API_MAP_BOX_URL
      .replace('{latitude}', latitude.toString())
      .replace('{longitude}', longitude.toString())
      .replace('{zoom}', zoom.toString());
    console.info('Map URL:', url);
    return new Promise((resolve, reject) => {
      const httpRequest = http.createHttp();
      httpRequest.request(url, { method: http.RequestMethod.GET }, (err, data) => {
        if (err) {
          console.error('An error occurred:', JSON.stringify(err));
          reject(new Error('Unable to fetch data'));
          return;
        }
        try {
          console.info('code:' + data.responseCode);
          if (data.responseCode === http.ResponseCode.OK) {
            const imageData: ArrayBuffer = data.result as ArrayBuffer;
            let imageSource: image.ImageSource = image.createImageSource(imageData);
          } else {
            console.error('Http error:', data.responseCode);
            reject(new Error('Http error'));
          }
          resolve("response");
        } catch (parseError) {
          console.error('Error parsing data:', parseError);
          reject(new Error('Invalid response format'));
        }
      });
    });
  }
}