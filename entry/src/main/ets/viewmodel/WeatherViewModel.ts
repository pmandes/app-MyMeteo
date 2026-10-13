import { AppError, City, CityWeatherData, WeatherData, WeatherRepository } from '@mymeteo/data';

export class WeatherViewModel {
  private repository?: WeatherRepository;

  setRepository(repository: WeatherRepository): void {
    this.repository = repository;
  }

  private getRepository(): WeatherRepository {
    if (!this.repository) {
      throw new AppError(1100, 'Unable to initialize the weather database. Restart the app.');
    }
    return this.repository;
  }

  async getSavedCities(): Promise<City[]> {
    return this.getRepository().getSavedCities();
  }

  async searchCity(query: string): Promise<City[]> {
    return this.getRepository().searchCity(query);
  }

  async getWeatherData(city: City, forceRefresh: boolean = false): Promise<WeatherData> {
    return this.getRepository().getWeatherData(city, forceRefresh);
  }

  async getStartupWeather(locationAllowed: boolean): Promise<CityWeatherData | null> {
    if (locationAllowed) {
      try {
        const repository = this.getRepository();
        const location = await repository.getCurrentLocation();
        const city = await repository.searchCityByCoordinates(location.latitude, location.longitude, 13);
        const weather = await repository.getWeatherData(city);
        if (weather.currentWeather?.current && weather.forecast?.daily?.time?.length) {
          return { city, weather };
        }
      } catch (error) {
        console.warn('Local weather unavailable; trying saved weather.');
      }
    }
    try {
      return await this.getRepository().getLastSavedWeatherData();
    } catch (error) {
      return null;
    }
  }
}

export const weatherViewModel: WeatherViewModel = new WeatherViewModel();
