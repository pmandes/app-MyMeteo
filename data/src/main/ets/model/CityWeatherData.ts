import { City } from '../net/dto/WeatherDTO';
import { WeatherData } from './WeatherData';

export interface CityWeatherData {
  city: City;
  weather: WeatherData;
}
