import relationalStore from '@ohos.data.relationalStore';
import { DbTable } from '../database/db/DbTable';

export class DBConfig {

  /**
   * Rdb database config.
   */
  static readonly STORE_CONFIG: relationalStore.StoreConfig = {
    name: 'database.db',
    securityLevel: relationalStore.SecurityLevel.S1
  };

  /**
   * City table config.
   */
  static readonly CITY_TABLE: DbTable = {
    tableName: 'tbl_city',
    sqlCreate: 'CREATE TABLE IF NOT EXISTS tbl_city(' +
      'id INTEGER PRIMARY KEY,' +
      'name TEXT, ' +
      'display_name TEXT, ' +
      'latitude REAL,' +
      'longitude REAL,' +
      'timestamp DATETIME)',
    columns: ['id', 'name', 'display_name', 'latitude', 'longitude', 'timestamp']
  };

  /**
   * Current weather table config.
   */
  static readonly WEATHER_TABLE: DbTable = {
    tableName: 'tbl_weather',
    sqlCreate: 'CREATE TABLE IF NOT EXISTS tbl_weather(' +
      'city_id INTEGER PRIMARY KEY,' +
      'temperature REAL,' +
      'wind_speed REAL,' +
      'wind_direction REAL,' +
      'wind_gust REAL,' +
      'pressure REAL,' +
      'humidity REAL,' +
      'temperature_unit TEXT,' +
      'wind_speed_unit TEXT,' +
      'wind_direction_unit TEXT,' +
      'wind_gust_unit TEXT,' +
      'pressure_unit TEXT,' +
      'humidity_unit TEXT,' +
      'is_day INTEGER,' +
      'weather_code INTEGER,' +
      'timestamp DATETIME)',
    columns: [
      'city_id', 'temperature','wind_speed', 'wind_direction', 'wind_gust', 'pressure',
      'humidity', 'temperature_unit', 'wind_speed_unit', 'wind_direction_unit', 'wind_gust_unit',
      'pressure_unit', 'humidity_unit', 'is_day', 'weather_code','timestamp'
    ]
  };

  /**
   * Weather Forecast table config.
   */
  static readonly FORECAST_TABLE: DbTable = {
    tableName: 'tbl_forecast',
    sqlCreate:
    'CREATE TABLE IF NOT EXISTS tbl_forecast(' +
      'city_id INTEGER PRIMARY KEY,' +
      'latitude REAL,' +
      'longitude REAL,' +
      'elevation REAL,' +
      'daily_units TEXT,' +
      'daily TEXT' +
      ')',
    columns: [
      'city_id', 'latitude', 'longitude', 'elevation', 'daily_units', 'daily'
    ]
  };
}