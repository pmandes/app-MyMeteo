import { BaseRelationalDatabase } from '../db/BaseRelationalDatabase';
import relationalStore from '@ohos.data.relationalStore';
import { WeatherEntity } from '../entity/WeatherEntity';
import { currentWeatherToEntity, entityToRecord, resultSetToWeather } from '../mapper/WeatherMapper';
import { IWeatherDAO } from './IWeatherDAO';
import { CurrentWeather } from '../../net/dto/WeatherDTO';


export class WeatherDAORdb implements IWeatherDAO {
  private db: BaseRelationalDatabase;

  constructor(dbInstance: BaseRelationalDatabase) {
    this.db = dbInstance;
  }

  insertWeather(cityId: number, currentWeather: CurrentWeather): Promise<number> {
    return this.db.insert<WeatherEntity>(
      WeatherEntity.getTableName(),
      currentWeatherToEntity(cityId, currentWeather),
      (entity) => entityToRecord(entity),
      true
    );
  }

  getWeatherByCityId(cityId: number): Promise<CurrentWeather[]> {
    return this.db.query(
      WeatherEntity.getTableName(),
      WeatherEntity.getTableColumns(),
      (predicates) => predicates.equalTo(WeatherEntity.getTableColumns()[0], cityId),
      (resultSet: relationalStore.ResultSet) => resultSetToWeather(resultSet)
    );
  }
}
