import { Entity } from '../db/Entity';
import { DbTable } from '../db/DbTable';
import { DBConfig } from '../../config/DBConfig';
import { BaseEntity } from '../db/BaseEntity';

export class WeatherEntity extends BaseEntity implements Entity {

  protected static readonly TABLE: DbTable = DBConfig.WEATHER_TABLE;

  cityId: number; // Primary Key

  temperature: number;
  windSpeed: number;
  windDirection: number;
  windGust: number;
  pressure: number;
  humidity: number;
  isDay: number;
  weatherCode: number;

  temperatureUnit: string;
  windSpeedUnit: string;
  windDirectionUnit: string;
  windGustUnit: string;
  pressureUnit: string;
  humidityUnit: string;

  lastUpdate: Date;

  constructor(
    cityId: number,
    temperature: number,
    windSpeed: number,
    windDirection: number,
    windGust: number,
    pressure: number,
    humidity: number,
    isDay: number,
    weatherCode: number,
    temperatureUnit: string,
    windSpeedUnit: string,
    windDirectionUnit: string,
    windGustUnit: string,
    pressureUnit: string,
    humidityUnit: string,
    lastUpdate: Date
  ) {
    super();
    this.cityId = cityId;
    this.temperature = temperature;
    this.windSpeed = windSpeed;
    this.windDirection = windDirection;
    this.windGust = windGust;
    this.pressure = pressure;
    this.humidity = humidity;
    this.isDay = isDay;
    this.weatherCode = weatherCode;
    this.temperatureUnit = temperatureUnit;
    this.windSpeedUnit = windSpeedUnit;
    this.windDirectionUnit = windDirectionUnit;
    this.windGustUnit = windGustUnit;
    this.pressureUnit = pressureUnit;
    this.humidityUnit = humidityUnit;
    this.lastUpdate = lastUpdate;
  }
}