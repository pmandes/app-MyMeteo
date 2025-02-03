import { DBConfig } from '../../config/DBConfig';
import { BaseEntity } from '../db/BaseEntity';
import { DbTable } from '../db/DbTable';
import { Entity } from '../db/Entity';

export class ForecastEntity extends BaseEntity implements Entity {

  protected static TABLE: DbTable = DBConfig.FORECAST_TABLE;

  cityId: number; // Primary Key
  latitude: number;
  longitude: number;
  elevation: number;
  dailyUnits: string;
  daily: string;

  constructor(
    cityId: number,
    latitude: number,
    longitude: number,
    elevation: number,
    dailyUnits: string,
    daily: string
  ) {
    super();
    this.cityId = cityId;
    this.latitude = latitude;
    this.longitude = longitude;
    this.elevation = elevation;
    this.dailyUnits = dailyUnits;
    this.daily = daily;
  }
}
