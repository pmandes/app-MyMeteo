export interface City {
  name: string,
  display_name: string,
  lon: number,
  lat: number
}

export interface CurrentWeather {
  latitude?:              number;
  longitude?:             number;
  generationtime_ms?:     number;
  utc_offset_seconds?:    number;
  timezone?:              string;
  timezone_abbreviation?: string;
  elevation?:             number;
  current_units?:         CurrentUnits;
  current?:               Current;
}

export interface Current {
  time?:                 string;
  interval?:             number;
  temperature_2m?:       number;
  relative_humidity_2m?: number;
  apparent_temperature?: number;
  is_day?:               number;
  precipitation?:        number;
  rain?:                 number;
  showers?:              number;
  snowfall?:             number;
  weather_code?:         number;
  cloud_cover?:          number;
  pressure_msl?:         number;
  surface_pressure?:     number;
  wind_speed_10m?:       number;
  wind_direction_10m?:   number;
  wind_gusts_10m?:       number;
}

export interface CurrentUnits {
  time?:                 string;
  interval?:             string;
  temperature_2m?:       string;
  relative_humidity_2m?: string;
  apparent_temperature?: string;
  is_day?:               string;
  precipitation?:        string;
  rain?:                 string;
  showers?:              string;
  snowfall?:             string;
  weather_code?:         string;
  cloud_cover?:          string;
  pressure_msl?:         string;
  surface_pressure?:     string;
  wind_speed_10m?:       string;
  wind_direction_10m?:   string;
  wind_gusts_10m?:       string;
}

export interface Forecast {
  latitude?:              number;
  longitude?:             number;
  generationtime_ms?:     number;
  utc_offset_seconds?:    number;
  timezone?:              string;
  timezone_abbreviation?: string;
  elevation?:             number;
  daily_units?:           DailyUnits;
  daily?:                 Daily;
}

export interface Daily {
  time?:                          number[];
  weather_code?:                  number[];
  temperature_2m_max?:            number[];
  temperature_2m_min?:            number[];
  apparent_temperature_max?:      number[];
  apparent_temperature_min?:      number[];
  sunrise?:                       number[];
  sunset?:                        number[];
  uv_index_max?:                  number[];
  uv_index_clear_sky_max?:        number[];
  precipitation_sum?:             number[];
  rain_sum?:                      number[];
  showers_sum?:                   number[];
  snowfall_sum?:                  number[];
  precipitation_hours?:           number[];
  precipitation_probability_max?: number[];
  wind_speed_10m_max?:            number[];
  wind_gusts_10m_max?:            number[];
  wind_direction_10m_dominant?:   number[];
  shortwave_radiation_sum?:       number[];
  et0_fao_evapotranspiration?:    number[];
}

export interface DailyUnits {
  time?:                          string;
  weather_code?:                  string;
  temperature_2m_max?:            string;
  temperature_2m_min?:            string;
  apparent_temperature_max?:      string;
  apparent_temperature_min?:      string;
  sunrise?:                       string;
  sunset?:                        string;
  uv_index_max?:                  string;
  uv_index_clear_sky_max?:        string;
  precipitation_sum?:             string;
  rain_sum?:                      string;
  showers_sum?:                   string;
  snowfall_sum?:                  string;
  precipitation_hours?:           string;
  precipitation_probability_max?: string;
  wind_speed_10m_max?:            string;
  wind_gusts_10m_max?:            string;
  wind_direction_10m_dominant?:   string;
  shortwave_radiation_sum?:       string;
  et0_fao_evapotranspiration?:    string;
}