import hilog from '@ohos.hilog';
import { City, CurrentWeather, Forecast } from '../model/WeatherModel';
import { WeatherAPIService } from '../net/WeatherAPIService';
import { MapBoxAPIService } from '../net/MapBoxAPIService';

export class CategoryViewModel {

  async searchCity(query: string): Promise<City[]> {

      console.error('searchCity: ', query)

      const apiService = new WeatherAPIService();

      try {
        const cities = apiService.searchCity(query);

        hilog.info(0x0000, 'CategoryViewModel', '%{public}s %{public}s ', 'Cities: ', JSON.stringify(cities));

        return cities;

      } catch (err) {

        hilog.info(0x0000, 'CategoryViewModel', '%{public}s %{public}s ', 'Error: ',  JSON.stringify(err));
      }

      return [];
  }

  async getCurrentWeather(city: City): Promise<CurrentWeather|null> {

    const apiService = new WeatherAPIService();

    try {
      const currentWeather = apiService.getCurrentWeather(city.lat, city.lon);
      return currentWeather;

    } catch (err) {

      hilog.error(0x0000, 'CategoryViewModel', '%{public}s %{public}s ', 'Error: ',  JSON.stringify(err));
    }

    return null;
  }

  async getForecast(city: City): Promise<Forecast|null> {

    const apiService = new WeatherAPIService();

    try {
      const forecast = apiService.getForecast(city.lat, city.lon);
      return forecast;

    } catch (err) {

      hilog.error(0x0000, 'CategoryViewModel', '%{public}s %{public}s ', 'Error: ',  JSON.stringify(err));
    }

    return null;
  }

  getMapImageUrl(city: City): string {
    return "https://api.mapbox.com/styles/v1/mapbox/streets-v12/static/21.071432235636493,52.2337172,4.5,0/500x400@2x?access_token=pk.eyJ1IjoicGF3ZWxtYW5kZXMiLCJhIjoiY200c2Y1NDlnMDA2cTJwc2lkbTIwdHljZyJ9.L2vMgVNik2ERoqK-nb4T_g"
  }

  getMapImage(city: City): string {
    const apiService = new MapBoxAPIService();
    apiService.getMapImageUrl(city.lon, city.lat, 4.5);
    return "";
  }
}

let categoryViewModel = new CategoryViewModel();

export default categoryViewModel as CategoryViewModel;