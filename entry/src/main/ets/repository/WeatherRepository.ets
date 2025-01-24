import { IWeatherRemoteDataSource } from '../datasource/remote/IWeatherRemoteDataSource';
import { IWeatherLocalDataSource } from '../datasource/local/IWeatherLocalDataSource';
import { City, CurrentWeather, Forecast } from '../model/WeatherModel';

export class WeatherRepository {
  private remoteDataSource: IWeatherRemoteDataSource;
  private localDataSource: IWeatherLocalDataSource;

  constructor(remoteDataSource: IWeatherRemoteDataSource, localDataSource: IWeatherLocalDataSource) {
    this.remoteDataSource = remoteDataSource;
    this.localDataSource = localDataSource;
  }

  async searchCity(query: string): Promise<City[]> {
    const cities = await this.remoteDataSource.searchCity(query);
    // for (const city of cities) {
    //   await this.localDataSource.saveCity(city);
    // }
    return cities;
  }

  async getCurrentWeather(latitude: number, longitude: number): Promise<CurrentWeather> {
    const currentWeather = await this.remoteDataSource.getCurrentWeather(latitude, longitude);
    //await this.localDataSource.saveCurrentWeather(currentWeather);
    return currentWeather;
  }

  async getForecast(latitude: number, longitude: number): Promise<Forecast> {
    const forecast = await this.remoteDataSource.getForecast(latitude, longitude);
    //await this.localDataSource.saveForecast(forecast);
    return forecast;
  }

  async saveCity(city: City): Promise<void> {
    const result = await this.localDataSource.saveCity(city)
  }

  async getSavedCities() : Promise<City[]> {
    return this.localDataSource.getAllCities()
  }
}