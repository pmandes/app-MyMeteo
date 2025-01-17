import { City, WeatherData } from '../model/WeatherModel';
import { WeatherAPIService } from '../net/WeatherAPIService';

export class CategoryViewModel {

  async searchCity(query: string): Promise<City[]> {

      console.info('searchCity: ', query)

      const apiService = new WeatherAPIService();
      return apiService.searchCity(query);
  }

  async getWeatherData(city: City): Promise<WeatherData> {
    console.info('getWeatherData: ', city);

    const apiService = new WeatherAPIService();

    try {

      const data = await Promise.all([
        apiService.getCurrentWeather(city.lat, city.lon),
        apiService.getForecast(city.lat, city.lon)
      ]);

      return {
        currentWeather: data[0],
        forecast: data[1]
      };
    } catch (err) {
      console.info('Get weather data error: ', err);

      return {
        currentWeather: null,
        forecast: null
      };
    }
  }
}

let categoryViewModel = new CategoryViewModel();

export default categoryViewModel as CategoryViewModel;