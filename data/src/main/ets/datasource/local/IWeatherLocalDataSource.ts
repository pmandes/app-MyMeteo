import { WeatherData } from '../../model/WeatherData';
import { City, CurrentWeather, Forecast } from '../../net/dto/WeatherDTO';

export interface IWeatherLocalDataSource {
  saveCity(city: City): Promise<number>;
  getAllCities(): Promise<City[]>;
  deleteCity(city: City): Promise<number>;
  saveWeatherData(cityId: number, currentWeather: CurrentWeather, forecast: Forecast, lastUpdate: Date): Promise<void>;
  getWeatherData(cityId: number): Promise<WeatherData>;
}
