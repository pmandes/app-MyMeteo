import { Entity } from '../db/Entity';
import { DbTable } from '../db/DbTable';
import { DBConfig } from '../../common/constants/DBConfig';

export class CityEntity implements Entity {

  private static readonly TABLE: DbTable = DBConfig.CITY_TABLE;

  cityId: number | undefined; // Primary Key
  cityName: string;
  cityDisplayName: string;
  latitude: number;
  longitude: number;

  constructor(id: number | undefined, name: string, displayName: string, latitude: number, longitude: number) {
    this.cityId = id;
    this.cityName = name;
    this.cityDisplayName = displayName;
    this.latitude = latitude;
    this.longitude = longitude;
  }

  static getTableName(): string {
    return CityEntity.TABLE.tableName;
  }

  static getTableColumns(): string[] {
    return CityEntity.TABLE.columns;
  }
}