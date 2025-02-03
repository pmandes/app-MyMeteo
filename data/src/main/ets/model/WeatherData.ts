import { CurrentWeather, Forecast } from '../net/dto/WeatherDTO';

export interface WeatherData {
  currentWeather: CurrentWeather | null;
  forecast: Forecast | null;
  lastUpdated: Date;
}