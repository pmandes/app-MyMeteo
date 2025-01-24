import { City, CurrentWeather, Forecast } from 'ets/model/WeatherModel';
import { ICityDAO } from '../../database/dao/ICityDAO';
import { IWeatherLocalDataSource } from './IWeatherLocalDataSource';

export class WeatherLocalDataSource implements IWeatherLocalDataSource {

  private cityDAO: ICityDAO;

  constructor(cityDAO: ICityDAO) {
    this.cityDAO = cityDAO;
  }

  getAllCities(): Promise<City[]> {
    return this.cityDAO.getAllCities();
  }

  saveCity(city: City): Promise<number> {
    return this.cityDAO.insertCity(city);
  }

  getCity(query: string): Promise<City> {
    throw new Error('Method not implemented.');
  }

  saveCurrentWeather(weather: CurrentWeather): Promise<void> {
    throw new Error('Method not implemented.');
  }

  getCurrentWeather(cityId: string): Promise<CurrentWeather> {
    throw new Error('Method not implemented.');
  }

  saveForecast(forecast: Forecast): Promise<void> {
    throw new Error('Method not implemented.');
  }

  getForecast(cityId: string): Promise<Forecast> {
    throw new Error('Method not implemented.');
  }
}