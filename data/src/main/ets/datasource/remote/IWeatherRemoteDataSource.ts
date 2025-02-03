import { City, CurrentWeather, Forecast } from '../../net/dto/WeatherDTO';

export interface IWeatherRemoteDataSource {
  searchCity(query: string): Promise<City[]>;
  getCurrentWeather(cityId: number, latitude: number, longitude: number): Promise<CurrentWeather>;
  getForecast(latitude: number, longitude: number): Promise<Forecast>;
}
