import { AppError, City, WeatherData, WeatherRepository } from '@mymeteo/data';

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
}

export const weatherViewModel: WeatherViewModel = new WeatherViewModel();
