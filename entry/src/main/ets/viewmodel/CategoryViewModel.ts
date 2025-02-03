import { City, WeatherData, WeatherRepository } from '@mymeteo/data';

const LOG_TAG = 'CategoryViewModel';

/**
 * ViewModel managing city data and weather data retrieval for the UI layer.
 */
export class CategoryViewModel {
  private repository?: WeatherRepository;

  /**
   * Creates a new instance of CategoryViewModel.
   * @param {WeatherRepository} repository - The repository to access weather and city data.
   */
  constructor(repository: WeatherRepository) {
    console.debug(`[${LOG_TAG}] created...`);
    this.repository = repository;
  }

  /**
   * Retrieves the list of saved cities from the database (via repository).
   * @returns {Promise<City[]>} A promise resolving to an array of saved City objects.
   */
  async getSavedCities(): Promise<City[]> {
    if (!this.repository) {
      console.error(`[${LOG_TAG}] No repository. Returning empty array.`);
      return [];
    }

    console.info(`[${LOG_TAG}] getSavedCities -> Retrieving saved cities...`);
    const cities: City[] = await this.repository.getSavedCities();

    console.info(`[${LOG_TAG}] Saved cities: ${JSON.stringify(cities)}`);
    return cities;
  }

  /**
   * Searches for cities by a query string (delegates to repository's remote search).
   * @param {string} query - Partial or full city name to search.
   * @returns {Promise<City[]>} A promise resolving to a list of cities matching the query.
   */
  async searchCity(query: string): Promise<City[]> {
    if (!this.repository) {
      console.error(`[${LOG_TAG}] No repository. searchCity returning empty array.`);
      return [];
    }

    console.info(`[${LOG_TAG}] searchCity: ${query}`);
    return this.repository.searchCity(query);
  }

  /**
   * Retrieves weather data for the specified city, deciding
   * whether to use local data or refresh from remote (handled by repository).
   * @param {City} city - The city for which to retrieve weather data.
   * @returns {Promise<WeatherData>} A promise that resolves to the weather data (current + forecast).
   */
  async getWeatherData(city: City): Promise<WeatherData> {
    console.info(`[${LOG_TAG}] getWeatherData called for city: ${city.name} (id=${city.place_id})`);

    if (!this.repository) {
      console.error(`[${LOG_TAG}] No repository. Returning empty WeatherData.`);
      return { currentWeather: null, forecast: null, lastUpdated: null };
    }

    try {

      const weatherData = await this.repository.getWeatherData(city);

      console.info(`[${LOG_TAG}] getWeatherData -> Received data: ${JSON.stringify(weatherData)}`);
      return weatherData;

    } catch (err) {
      console.error(`[${LOG_TAG}] getWeatherData error: `, err);
      return { currentWeather: null, forecast: null, lastUpdated: null };
    }
  }
}

export let categoryViewModel: CategoryViewModel = new CategoryViewModel(globalThis.weatherRepository)
