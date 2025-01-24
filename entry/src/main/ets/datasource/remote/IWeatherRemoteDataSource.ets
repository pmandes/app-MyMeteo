import { City, CurrentWeather, Forecast } from '../../model/WeatherModel';

export interface IWeatherRemoteDataSource {
  searchCity(query: string): Promise<City[]>;
  getCurrentWeather(latitude: number, longitude: number): Promise<CurrentWeather>;
  getForecast(latitude: number, longitude: number): Promise<Forecast>;
}
