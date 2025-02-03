import { Entity } from '../db/Entity';
import { DbTable } from '../db/DbTable';
import { DBConfig } from '../../config/DBConfig';
import { BaseEntity } from '../db/BaseEntity';

export class CityEntity extends BaseEntity implements Entity {

  protected static readonly TABLE: DbTable = DBConfig.CITY_TABLE;

  cityId: number; // Primary Key
  cityName: string;
  cityDisplayName: string;
  latitude: number;
  longitude: number;
  lastUpdate: Date;

  constructor(id: number, name: string, displayName: string, latitude: number, longitude: number, lastUpdate: Date) {
    super();
    this.cityId = id;
    this.cityName = name;
    this.cityDisplayName = displayName;
    this.latitude = latitude;
    this.longitude = longitude;
    this.lastUpdate = lastUpdate;
  }
}