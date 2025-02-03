import { Forecast } from '../../net/dto/WeatherDTO';

export interface IForecastDAO {
  insertForecast(cityId: number, forecast: Forecast): Promise<number>;
  getForecastByCityId(cityId: number): Promise<Forecast[]>;
}