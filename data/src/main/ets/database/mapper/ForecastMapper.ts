import { Daily, DailyUnits, Forecast } from '../../net/dto/WeatherDTO';
import { ForecastEntity } from '../entity/ForecastEntity';
import relationalStore from '@ohos.data.relationalStore';

export function entityToForecast(entity: ForecastEntity): Forecast {
  return {
    latitude: entity.latitude,
    longitude: entity.longitude,
    elevation: entity.elevation,
    daily_units: entity.dailyUnits ? JSON.parse(entity.dailyUnits) as DailyUnits : undefined,
    daily: entity.daily ? JSON.parse(entity.daily) as Daily : undefined,
  };
}

export function forecastToEntity(cityId: number, forecast: Forecast): ForecastEntity {
  return new ForecastEntity(
    cityId,
    forecast.latitude ?? 0,
    forecast.longitude ?? 0,
    forecast.elevation ?? 0,
    forecast.daily_units ? JSON.stringify(forecast.daily_units) : '',
    forecast.daily ? JSON.stringify(forecast.daily) : ''
  );
}

export function entityToRecord(entity: ForecastEntity): relationalStore.ValuesBucket {
  return {
    city_id: entity.cityId,
    latitude: entity.latitude,
    longitude: entity.longitude,
    elevation: entity.elevation,
    daily_units: entity.dailyUnits,
    daily: entity.daily
  };
}

export function resultSetToForecasts(resultSet: relationalStore.ResultSet): Forecast[] {
  const forecasts: Forecast[] = [];

  console.error("resultSetToForecasts: " + JSON.stringify(resultSet));

  while (resultSet.goToNextRow()) {

    const dailyUnitsStr = resultSet.getString(resultSet.getColumnIndex('daily_units'));
    const dailyStr = resultSet.getString(resultSet.getColumnIndex('daily'));

    const forecast: Forecast = {
      latitude: resultSet.getDouble(resultSet.getColumnIndex('latitude')),
      longitude: resultSet.getDouble(resultSet.getColumnIndex('longitude')),
      elevation: resultSet.getDouble(resultSet.getColumnIndex('elevation')),
      daily_units: dailyUnitsStr ? JSON.parse(dailyUnitsStr) : undefined,
      daily: dailyStr ? JSON.parse(dailyStr) : undefined,
    };

    forecasts.push(forecast);
  }

  console.error("resultSetToForecasts array: " + JSON.stringify(forecasts));

  return forecasts;
}
