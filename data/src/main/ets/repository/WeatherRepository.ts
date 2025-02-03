import { IWeatherRemoteDataSource } from '../datasource/remote/IWeatherRemoteDataSource';
import { IWeatherLocalDataSource } from '../datasource/local/IWeatherLocalDataSource';
import { City, CurrentWeather, Forecast } from '../net/dto/WeatherDTO';
import { WeatherData } from '../model/WeatherData';

const LOG_TAG = 'WeatherRepository';

/**
 * Repository providing weather data from either local or remote sources.
 * Decides whether to fetch fresh data or return cached values.
 */
export class WeatherRepository {
  private remoteDataSource: IWeatherRemoteDataSource;
  private localDataSource: IWeatherLocalDataSource;
  private FIFTEEN_MINUTES = 1 * 60 * 1000;

  /**
   * Creates a new instance of WeatherRepository.
   * @param {IWeatherRemoteDataSource} remoteDataSource - The remote data source for weather (API calls).
   * @param {IWeatherLocalDataSource} localDataSource - The local data source (e.g. DB or IndexedDB).
   */
  constructor(remoteDataSource: IWeatherRemoteDataSource, localDataSource: IWeatherLocalDataSource) {
    this.remoteDataSource = remoteDataSource;
    this.localDataSource = localDataSource;
  }

  /**
   * Retrieves weather data for the specified city.
   * 1. Ensures the city is saved in local DB.
   * 2. Checks if local data exists and is fresh.
   * 3. If missing or obsolete, fetches from remote and updates local.
   * @param {City} city - The city object containing IDs and coordinates.
   * @returns {Promise<WeatherData>} A promise that resolves to the weather data (current + forecast).
   */
  async getWeatherData(city: City): Promise<WeatherData> {
    console.info(`[${LOG_TAG}] getWeatherData start for city: ${JSON.stringify(city)}`);

    console.debug(`[${LOG_TAG}] Ensuring city is saved locally (cityId=${city.place_id})`);
    await this.saveCity(city);

    console.debug(`[${LOG_TAG}] Trying to get local data for cityId=${city.place_id}...`);
    const localData = await this.localDataSource.getWeatherData(city.place_id);

    if (!localData || !localData.currentWeather || !localData.forecast) {
      console.warn(`[${LOG_TAG}] No local data (or incomplete). Will fetch fresh data from remote...`);
      return this.fetchAndSaveWeatherData(city);
    }

    console.debug(`[${LOG_TAG}] Local data found: ${JSON.stringify(localData)}`);
    const { lastUpdated } = localData;

    if (this.isDataObsolete(lastUpdated)) {
      console.warn(`[${LOG_TAG}] Local data is obsolete (lastUpdated=${lastUpdated}). Fetching new data...`);
      return this.fetchAndSaveWeatherData(city);
    }

    console.info(`[${LOG_TAG}] Local data is fresh enough. Returning local data.`);
    return localData;
  }

  /**
   * Fetches fresh weather data (current & forecast) from remote, saves locally, and returns it.
   * @private
   * @param {City} city - The city for which to fetch data.
   * @returns {Promise<WeatherData>} A promise resolving to freshly fetched weather data.
   */
  private async fetchAndSaveWeatherData(city: City): Promise<WeatherData> {
    console.info(`[${LOG_TAG}] fetchAndSaveWeatherData -> fetching data from remote for cityId=${city.place_id}`);

    const [ currentWeather, forecast ] = await Promise.all([
      this.remoteDataSource.getCurrentWeather(city.place_id, city.lat, city.lon),
      this.remoteDataSource.getForecast(city.lat, city.lon)
    ]);

    const lastUpdated = new Date();
    console.debug(`[${LOG_TAG}] Received currentWeather: ${JSON.stringify(currentWeather)}`);
    console.debug(`[${LOG_TAG}] Received forecast: ${JSON.stringify(forecast)}`);

    console.info(`[${LOG_TAG}] Saving new weather data to local DB...`);
    await this.saveWeatherData(city.place_id, currentWeather, forecast, lastUpdated);

    console.info(`[${LOG_TAG}] Returning newly fetched data for cityId=${city.place_id}`);
    return { currentWeather, forecast, lastUpdated };
  }

  /**
   * Checks if data is older than 15 minutes.
   * @param {number} lastUpdated - Timestamp (ms) of last update.
   * @returns {boolean} True if the data is older than 15 min, false otherwise.
   */
  private isDataObsolete(lastUpdated: Date): boolean {
    const now = Date.now();
    const last = lastUpdated.getTime();
    const diff = now - last;
    console.debug(`[${LOG_TAG}] isDataObsolete? lastUpdated=${last}ms, now=${now}ms, diff=${diff}ms, threshold=${this.FIFTEEN_MINUTES}ms`);
    return diff > this.FIFTEEN_MINUTES;
  }

  // ----------------------------------------------------------------------------
  // Methods delegating to localDataSource / remoteDataSource
  // ----------------------------------------------------------------------------

  /**
   * Returns all saved cities from the local database.
   * @returns {Promise<City[]>} List of saved cities.
   */
  async getSavedCities(): Promise<City[]> {
    console.info(`[${LOG_TAG}] getSavedCities -> returning all cities from local DB...`);
    return this.localDataSource.getAllCities();
  }

  /**
   * Returns saved weather data (if exists) for a given city from the local database.
   * @param {number} cityId - The place_id of the city.
   * @returns {Promise<WeatherData>} The saved weather data or an empty object if not found.
   */
  async getSavedWeatherData(cityId: number): Promise<WeatherData> {
    console.info(`[${LOG_TAG}] getSavedWeatherData -> cityId=${cityId}`);
    return this.localDataSource.getWeatherData(cityId);
  }

  /**
   * Saves (or updates) the provided city in the local database.
   * @param {City} city - The city object to be saved.
   * @returns {Promise<void>}
   */
  async saveCity(city: City): Promise<void> {
    console.debug(`[${LOG_TAG}] saveCity -> cityId=${city.place_id}, name=${city.name}`);
    await this.localDataSource.saveCity(city);
  }

  /**
   * Saves the weather data for a specific city to the local database.
   * @param {number} cityId - The city's place_id.
   * @param {CurrentWeather} currentWeather - Current weather data object.
   * @param {Forecast} forecast - Forecast data object.
   * @param {number} lastUpdated - Timestamp (ms) of the data retrieval.
   * @returns {Promise<void>}
   */
  async saveWeatherData(
    cityId: number,
    currentWeather: CurrentWeather,
    forecast: Forecast,
    lastUpdated: Date
  ): Promise<void> {
    console.debug(`[${LOG_TAG}] saveWeatherData -> cityId=${cityId}, lastUpdated=${lastUpdated}`);
    await this.localDataSource.saveWeatherData(cityId, currentWeather, forecast, lastUpdated);
  }

  /**
   * Searches for cities matching the given query via the remote data source.
   * @param {string} query - The search query (city name, partial name, etc.).
   * @returns {Promise<City[]>} A list of matching city objects.
   */
  async searchCity(query: string): Promise<City[]> {
    console.info(`[${LOG_TAG}] searchCity: query="${query}"`);
    return this.remoteDataSource.searchCity(query);
  }

  /**
   * Retrieves current weather from remote for a given city and coords.
   * @param {number} cityId - The place_id of the city.
   * @param {number} latitude - Latitude coordinate.
   * @param {number} longitude - Longitude coordinate.
   * @returns {Promise<CurrentWeather>} The current weather data.
   */
  async getCurrentWeather(cityId: number, latitude: number, longitude: number): Promise<CurrentWeather> {
    console.info(`[${LOG_TAG}] getCurrentWeather -> cityId=${cityId}, lat=${latitude}, lon=${longitude}`);
    return this.remoteDataSource.getCurrentWeather(cityId, latitude, longitude);
  }

  /**
   * Retrieves forecast from remote for given coordinates.
   * @param {number} latitude - Latitude coordinate.
   * @param {number} longitude - Longitude coordinate.
   * @returns {Promise<Forecast>} The forecast data.
   */
  async getForecast(latitude: number, longitude: number): Promise<Forecast> {
    console.info(`[${LOG_TAG}] getForecast -> lat=${latitude}, lon=${longitude}`);
    return this.remoteDataSource.getForecast(latitude, longitude);
  }
}
