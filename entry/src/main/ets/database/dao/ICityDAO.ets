import { City } from '../../model/WeatherModel';

export interface ICityDAO {
  getAllCities(): Promise<City[]>;
  insertCity(city: City): Promise<number>;
  updateCity(city: City): Promise<number>;
  deleteCity(city: City): Promise<number>;
  getCityById(cityId: number): Promise<City[]>;
}