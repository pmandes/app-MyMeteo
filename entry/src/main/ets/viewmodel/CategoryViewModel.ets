import { City, WeatherData } from '../model/WeatherModel';
import { WeatherAPI } from '../net/WeatherAPI';
import { WeatherRepository } from '../repository/WeatherRepository';
import { WeatherRemoteDataSource } from '../datasource/remote/WeatherRemoteDataSource';
import { WeatherLocalDataSource } from '../datasource/local/WeatherLocalDataSource';
import { CityDAORdb } from '../database/dao/CityDAORdb';
import { MyMeteoDB } from '../database/MyMeteoDB';

export class CategoryViewModel {

  private repository?: WeatherRepository;

  constructor() {
    MyMeteoDB.getInstance(getContext()).then( dbInstance => {
      this.repository = new WeatherRepository(
        new WeatherRemoteDataSource(new WeatherAPI()),
        new WeatherLocalDataSource(new CityDAORdb(dbInstance))
      );
    });
  }

  async searchCity(query: string): Promise<City[]> {

    if (!this.repository) {
      return [];
    }

    console.info('searchCity: ', query);

    this.repository?.getSavedCities().then(cities => {
      console.info('Saved cities: ', JSON.stringify(cities));
    }).catch((err: Error) => {
      console.error('getSavedCities error: ', err);
    });

    return this.repository?.searchCity(query);
  }

  async getWeatherData(city: City): Promise<WeatherData> {
    console.info('getWeatherData: ', city);

    if (!this.repository) {
      return { forecast: null, currentWeather: null };
    }

    try {
      await this.repository?.saveCity(city);
    } catch (err) {
      console.error('saveCity error: ', err);
    }

    try {

      const data = await Promise.all([
        this.repository?.getCurrentWeather(city.lat, city.lon),
        this.repository?.getForecast(city.lat, city.lon)
      ]);

      return {
        currentWeather: data[0],
        forecast: data[1]
      };
    } catch (err) {
      console.info('Get weather data error: ', err);

      return {
        currentWeather: null,
        forecast: null
      };
    }
  }
}

let categoryViewModel = new CategoryViewModel();
export default categoryViewModel as CategoryViewModel;