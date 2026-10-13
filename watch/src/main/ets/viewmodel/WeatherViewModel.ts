import { AppError, City, WeatherData, WeatherRepository } from '@mymeteo/data';

export class WeatherViewModel {
  private repository?: WeatherRepository;

  setRepository(repository: WeatherRepository): void {
    this.repository = repository;
  }

  async getLocation(): Promise<City> {
    if (!this.repository) {
      throw new AppError(1100, 'Unable to initialize the weather database. Restart the app.');
    }
    const location = await this.repository.getCurrentLocation();
    return this.repository.searchCityByCoordinates(location.latitude, location.longitude, 13);
  }

  async getWeatherData(city: City): Promise<WeatherData> {
    if (!this.repository) {
      throw new AppError(1100, 'Unable to initialize the weather database. Restart the app.');
    }
    return this.repository.getWeatherData(city);
  }
}

export const weatherViewModel: WeatherViewModel = new WeatherViewModel();
