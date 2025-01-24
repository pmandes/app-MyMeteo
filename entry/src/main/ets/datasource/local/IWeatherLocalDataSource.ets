import { City, CurrentWeather, Forecast } from '../../model/WeatherModel';

export interface IWeatherLocalDataSource {
  saveCity(city: City): Promise<number>;
  getCity(query: string): Promise<City | null>;
  getAllCities(): Promise<City[]>;
  saveCurrentWeather(weather: CurrentWeather): Promise<void>;
  getCurrentWeather(cityId: string): Promise<CurrentWeather | null>;
  saveForecast(forecast: Forecast): Promise<void>;
  getForecast(cityId: string): Promise<Forecast | null>;
}
