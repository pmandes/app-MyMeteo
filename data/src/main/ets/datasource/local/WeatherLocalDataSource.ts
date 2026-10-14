import { City, CurrentWeather, Forecast } from '../../net/dto/WeatherDTO';
import { ICityDAO } from '../../database/dao/ICityDAO';
import { IWeatherDAO } from '../../database/dao/IWeatherDAO';
import { IForecastDAO } from '../../database/dao/IForecastDAO';
import { IWeatherLocalDataSource } from './IWeatherLocalDataSource';
import { WeatherData } from '../../model/WeatherData';


export class WeatherLocalDataSource implements IWeatherLocalDataSource {

  private cityDAO: ICityDAO;
  private weatherDAO: IWeatherDAO;
  private forecastDAO: IForecastDAO;

  constructor(cityDAO: ICityDAO, weatherDAO: IWeatherDAO, forecastDAO: IForecastDAO) {
    this.cityDAO = cityDAO;
    this.weatherDAO = weatherDAO;
    this.forecastDAO = forecastDAO;
  }

  async getAllCities(): Promise<City[]> {
    return this.cityDAO.getAllCities();
  }

  async saveCity(city: City): Promise<number> {
    return this.cityDAO.insertCity(city);
  }

  async deleteCity(city: City): Promise<number> {
    return this.cityDAO.deleteCity(city);
  }

  async saveWeatherData(cityId: number, currentWeather: CurrentWeather, forecast: Forecast): Promise<void> {

    // Finish every started write before releasing the repository's mutation queue.
    const weather_result = await this.weatherDAO.insertWeather(cityId, currentWeather);
    const forecast_result = await this.forecastDAO.insertForecast(cityId, forecast);

    console.error("SAVE: weather: " + weather_result + ", forecast: " + forecast_result)
  }

  async getWeatherData(cityId: number): Promise<WeatherData> {

    const [ weather, forecast ] = await Promise.all([
      this.weatherDAO.getWeatherByCityId(cityId),
      this.forecastDAO.getForecastByCityId(cityId)
    ]);

    console.error("LOAD: weather: " + JSON.stringify(weather) + ", forecast: " + JSON.stringify(forecast));

    return {
      currentWeather: weather[0] ?? null,
      forecast: forecast[0] ?? null,
      lastUpdated: weather[0]?.last_update ?? null,
    }
  }

}
