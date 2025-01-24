import { IWeatherRemoteDataSource } from './IWeatherRemoteDataSource';
import { WeatherAPI } from '../../net/WeatherAPI';
import { City, CurrentWeather, Forecast } from '../../model/WeatherModel';

export class WeatherRemoteDataSource implements IWeatherRemoteDataSource {

  private api: WeatherAPI;

  constructor(weatherAPI: WeatherAPI) {
    this.api = weatherAPI;
  }

  async searchCity(query: string): Promise<City[]> {
    return this.api.searchCity(query);
  }

  async getCurrentWeather(latitude: number, longitude: number): Promise<CurrentWeather> {
    return this.api.getCurrentWeather(latitude, longitude);
  }

  async getForecast(latitude: number, longitude: number): Promise<Forecast> {
    return this.api.getForecast(latitude, longitude);
  }
}