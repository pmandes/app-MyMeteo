import { CurrentWeather } from '../../net/dto/WeatherDTO';
import { WeatherEntity } from '../entity/WeatherEntity';
import relationalStore from '@ohos.data.relationalStore';

export function entityToCurrentWeather(entity: WeatherEntity): CurrentWeather {
  const currentWeather: CurrentWeather = {
    last_update: entity.lastUpdate,
    current_units: {
      temperature_2m: entity.temperatureUnit,
      wind_speed_10m: entity.windSpeedUnit,
      wind_direction_10m: entity.windDirectionUnit,
      wind_gusts_10m: entity.windGustUnit,
      surface_pressure: entity.pressureUnit,
      relative_humidity_2m: entity.humidityUnit
    },
    current: {
      temperature_2m: entity.temperature,
      wind_speed_10m: entity.windSpeed,
      wind_direction_10m: entity.windDirection,
      wind_gusts_10m: entity.windGust,
      surface_pressure: entity.pressure,
      relative_humidity_2m: entity.humidity,
      is_day: entity.isDay,
      weather_code: entity.weatherCode
    }
  };

  return currentWeather;
}

export function currentWeatherToEntity(cityId: number, currentWeather: CurrentWeather): WeatherEntity {
  return new WeatherEntity(
    cityId,

    currentWeather.current?.temperature_2m || 0,
    currentWeather.current?.wind_speed_10m || 0,
    currentWeather.current?.wind_direction_10m || 0,
    currentWeather.current?.wind_gusts_10m || 0,
    currentWeather.current?.surface_pressure || 0,
    currentWeather.current?.relative_humidity_2m || 0,
    currentWeather.current?.is_day || 0,
    currentWeather.current?.weather_code || 0,

    currentWeather.current_units?.temperature_2m || '',
    currentWeather.current_units?.wind_speed_10m || '',
    currentWeather.current_units?.wind_direction_10m || '',
    currentWeather.current_units?.wind_gusts_10m || '',
    currentWeather.current_units?.surface_pressure || '',
    currentWeather.current_units?.relative_humidity_2m || '',

    currentWeather.last_update
  );
}

export function entityToRecord(entity: WeatherEntity): relationalStore.ValuesBucket {
  return {
    city_id: entity.cityId,
    temperature: entity.temperature,
    wind_speed: entity.windSpeed,
    wind_direction: entity.windDirection,
    wind_gust: entity.windGust,
    pressure: entity.pressure,
    humidity: entity.humidity,
    temperature_unit: entity.temperatureUnit,
    wind_speed_unit: entity.windSpeedUnit,
    wind_direction_unit: entity.windDirectionUnit,
    wind_gust_unit: entity.windGustUnit,
    pressure_unit: entity.pressureUnit,
    humidity_unit: entity.humidityUnit,
    timestamp: entity.lastUpdate.getTime()
  }
}

export function resultSetToWeather(resultSet: relationalStore.ResultSet): CurrentWeather[] {
  const weatherArray: CurrentWeather[] = [];

  console.error("resultSetToWeather: " + JSON.stringify(resultSet));

  while(resultSet.goToNextRow()) {

    const entity = new WeatherEntity(
      resultSet.getDouble(resultSet.getColumnIndex('city_id')),
      resultSet.getDouble(resultSet.getColumnIndex('temperature')),
      resultSet.getDouble(resultSet.getColumnIndex('wind_speed')),
      resultSet.getDouble(resultSet.getColumnIndex('wind_direction')),
      resultSet.getDouble(resultSet.getColumnIndex('wind_gust')),
      resultSet.getDouble(resultSet.getColumnIndex('pressure')),
      resultSet.getDouble(resultSet.getColumnIndex('humidity')),
      resultSet.getDouble(resultSet.getColumnIndex('is_day')),
      resultSet.getDouble(resultSet.getColumnIndex('weather_code')),
      resultSet.getString(resultSet.getColumnIndex('temperature_unit')),
      resultSet.getString(resultSet.getColumnIndex('wind_speed_unit')),
      resultSet.getString(resultSet.getColumnIndex('wind_direction_unit')),
      resultSet.getString(resultSet.getColumnIndex('wind_gust_unit')),
      resultSet.getString(resultSet.getColumnIndex('pressure_unit')),
      resultSet.getString(resultSet.getColumnIndex('humidity_unit')),
      new Date(resultSet.getDouble(resultSet.getColumnIndex('timestamp')))
    );

    weatherArray.push(entityToCurrentWeather(entity))
  }

  console.error("resultSetToWeather array: " + JSON.stringify(weatherArray));

  return weatherArray;
}
