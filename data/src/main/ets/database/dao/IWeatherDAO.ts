import { CurrentWeather } from '../../net/dto/WeatherDTO';

export interface IWeatherDAO {
  insertWeather(cityId: number, currentWeather: CurrentWeather): Promise<number>;
  getWeatherByCityId(cityId: number): Promise<CurrentWeather[]>;
}