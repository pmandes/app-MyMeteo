import http from '@ohos.net.http';
import { BASE_API_OPEN_STREET_MAP_URL, BASE_API_OPEN_METEO_URL } from './baseUrls';
import { City, CurrentWeather, Forecast } from '../model/WeatherModel';
import { makeHttpRequest } from './makeHttpRequest';

export class WeatherAPIService {

  private API_SEARCH_URL: string = `${BASE_API_OPEN_STREET_MAP_URL}/search?city={city}&format=jsonv2&addressdetails=1`;
  private API_CURRENT_WEATHER_URL: string = `${BASE_API_OPEN_METEO_URL}/v1/forecast?latitude={latitude}&longitude={longitude}&current=temperature_2m,relative_humidity_2m,apparent_temperature,is_day,precipitation,rain,showers,snowfall,weather_code,cloud_cover,pressure_msl,surface_pressure,wind_speed_10m,wind_direction_10m,wind_gusts_10m&forecast_days=1`;
  private API_FORECAST_URL: string = `${BASE_API_OPEN_METEO_URL}/v1/forecast?latitude={latitude}&longitude={longitude}&daily=weather_code,temperature_2m_max,temperature_2m_min,apparent_temperature_max,apparent_temperature_min,sunrise,sunset,daylight_duration,sunshine_duration,uv_index_max,uv_index_clear_sky_max,precipitation_sum,rain_sum,showers_sum,snowfall_sum,precipitation_hours,precipitation_probability_max,wind_speed_10m_max,wind_gusts_10m_max,wind_direction_10m_dominant,shortwave_radiation_sum,et0_fao_evapotranspiration&timeformat=unixtime&timezone=auto`;

  async searchCity(query: string): Promise<City[]> {
    const url = this.API_SEARCH_URL.replace('{city}', encodeURIComponent(query));
    return makeHttpRequest<City[]>(url, http.RequestMethod.GET);
  }

  async getCurrentWeather(latitude: number, longitude: number): Promise<CurrentWeather> {
    const url = this.API_CURRENT_WEATHER_URL
      .replace('{latitude}', latitude.toString())
      .replace('{longitude}', longitude.toString());
    return makeHttpRequest<CurrentWeather>(url, http.RequestMethod.GET);
  }

  async getForecast(latitude: number, longitude: number): Promise<Forecast> {
    const url = this.API_FORECAST_URL
      .replace('{latitude}', latitude.toString())
      .replace('{longitude}', longitude.toString());
    return makeHttpRequest<Forecast>(url, http.RequestMethod.GET);
  }
}