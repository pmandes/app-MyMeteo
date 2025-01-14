import http from '@ohos.net.http';
import image from '@ohos.multimedia.image';
import { City, CurrentWeather, Forecast } from '../model/WeatherModel';

export class WeatherAPIService {
  private API_SEARCH_URL: string =
    'https://nominatim.openstreetmap.org/search?city={city}&format=jsonv2&addressdetails=1';
  private API_CURRENT_WEATHER_URL: string =
    'https://api.open-meteo.com/v1/forecast?latitude={latitude}&longitude={longitude}&current=temperature_2m,relative_humidity_2m,apparent_temperature,is_day,precipitation,rain,showers,snowfall,weather_code,cloud_cover,pressure_msl,surface_pressure,wind_speed_10m,wind_direction_10m,wind_gusts_10m&forecast_days=1';
  private API_FORECAST_URL: string =
    'https://api.open-meteo.com/v1/forecast?latitude={latitude}&longitude={longitude}&daily=weather_code,temperature_2m_max,temperature_2m_min,apparent_temperature_max,apparent_temperature_min,sunrise,sunset,daylight_duration,sunshine_duration,uv_index_max,uv_index_clear_sky_max,precipitation_sum,rain_sum,showers_sum,snowfall_sum,precipitation_hours,precipitation_probability_max,wind_speed_10m_max,wind_gusts_10m_max,wind_direction_10m_dominant,shortwave_radiation_sum,et0_fao_evapotranspiration&timeformat=unixtime&timezone=auto';
  private API_MAP_BOX_URL: string =
    'http://api.mapbox.com/styles/v1/mapbox/streets-v12/static/{longitude},{latitude},{zoom},0/500x400@2x?access_token=pk.eyJ1IjoicGF3ZWxtYW5kZXMiLCJhIjoiY200c2Y1NDlnMDA2cTJwc2lkbTIwdHljZyJ9.L2vMgVNik2ERoqK-nb4T_g';

  async searchCity(query: string): Promise<City[]> {

    return new Promise((resolve, reject) => {

      const httpRequest = http.createHttp();
      const url = this.API_SEARCH_URL.replace('{city}', encodeURIComponent(query));

      console.warn('URL: ', url)

      httpRequest.request(url, {
        method: http.RequestMethod.GET,
        header: {
          'Content-Type': 'application/json'
        }

      }, (err, data) => {

        if (err) {
          console.error('An error occurred:', JSON.stringify(err))
          reject(new Error('Unable to fetch data'));
          return;
        }

        try {
          console.info('code:' + data.responseCode);
          console.info('data: ', JSON.stringify(data))

          const response: Array<City> = JSON.parse(data.result as string);

          resolve(response)

        } catch (parseError) {
          console.error('Error parsing data:', parseError)
          reject(new Error('Invalid response format'));
        }
      });
    });
  }

  async getCurrentWeather(latitude: number, longitude: number): Promise<CurrentWeather> {

    return new Promise((resolve, reject) => {

      const httpRequest = http.createHttp();

      httpRequest.request(this.API_CURRENT_WEATHER_URL
        .replace('{latitude}', latitude.toString())
        .replace('{longitude}', longitude.toString()), {
        method: http.RequestMethod.GET,
        header: {
          'Content-Type': 'application/json'
        }
      }, (err, data) => {

        if (err) {
          console.error('An error occurred:', JSON.stringify(err))
          reject(new Error('Unable to fetch data'));
          return;
        }

        try {
          console.info('code:' + data.responseCode);

          const response: CurrentWeather = JSON.parse(data.result as string);

          resolve(response)

        } catch (parseError) {
          console.error('Error parsing data:', parseError)
          reject(new Error('Invalid response format'));
        }
      });
    });
  }

  async getForecast(latitude: number, longitude: number): Promise<CurrentWeather> {

    return new Promise((resolve, reject) => {

      const httpRequest = http.createHttp();

      httpRequest.request(this.API_FORECAST_URL
        .replace('{latitude}', latitude.toString())
        .replace('{longitude}', longitude.toString()), {
        method: http.RequestMethod.GET,
        header: {
          'Content-Type': 'application/json'
        }
      }, (err, data) => {

        if (err) {
          console.error('An error occurred:', JSON.stringify(err))
          reject(new Error('Unable to fetch data'));
          return;
        }

        try {
          console.info('code:' + data.responseCode);

          const response: Forecast = JSON.parse(data.result as string);

          resolve(response)

        } catch (parseError) {
          console.error('Error parsing data:', parseError)
          reject(new Error('Invalid response format'));
        }
      });
    });
  }

  getMapImageUrl(longitude: number, latitude: number, zoom: number): Promise<string> {

    const httpRequest = http.createHttp();

    const url = this.API_MAP_BOX_URL
      .replace('{latitude}', latitude.toString())
      .replace('{longitude}', longitude.toString())
      .replace('{zoom}', zoom.toString());

    console.info('Map URL:', url)

    return new Promise((resolve, reject) => {
      httpRequest.request(url, {
        method: http.RequestMethod.GET,


      }, (err, data) => {

        if (err) {
          console.error('An error occurred:', JSON.stringify(err))
          reject(new Error('Unable to fetch data'));
          return;
        }

        try {
          console.info('code:' + data.responseCode);

          if (data.responseCode === http.ResponseCode.OK) {

            const imageData: ArrayBuffer = data.result as ArrayBuffer;
            let imageSource: image.ImageSource = image.createImageSource(imageData);

          } else {

            console.error('Http error:', data.responseCode)
            reject(new Error('Http error'));
          }

          resolve("response")

        } catch (parseError) {
          console.error('Error parsing data:', parseError)
          reject(new Error('Invalid response format'));
        }

      });
    });
  }
}
