import hilog from '@ohos.hilog';
import { City, CurrentWeather, Forecast } from '../model/WeatherModel';
import { WeatherAPIService } from '../net/WeatherAPIService';
import { MapBoxAPIService } from '../net/MapBoxAPIService';

export class CategoryViewModel {

  async searchCity(query: string): Promise<City[]> {

      console.info('searchCity: ', query)

      const apiService = new WeatherAPIService();
      return apiService.searchCity(query);
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
}

let categoryViewModel = new CategoryViewModel();

export default categoryViewModel as CategoryViewModel;