import { BaseRelationalDatabase } from '../db/BaseRelationalDatabase';
import relationalStore from '@ohos.data.relationalStore';
import { ForecastEntity } from '../entity/ForecastEntity';
import { forecastToEntity, entityToRecord, resultSetToForecasts } from '../mapper/ForecastMapper';
import { IForecastDAO } from './IForecastDAO';
import { Forecast } from '../../net/dto/WeatherDTO';


export class ForecastDAORdb implements IForecastDAO {
  private db: BaseRelationalDatabase;

  constructor(dbInstance: BaseRelationalDatabase) {
    this.db = dbInstance;
  }

  insertForecast(cityId: number, forecast: Forecast): Promise<number> {
    return this.db.insert<ForecastEntity>(
      ForecastEntity.getTableName(),
      forecastToEntity(cityId, forecast),
      (entity) => entityToRecord(entity),
      true
    );
  }

  getForecastByCityId(cityId: number): Promise<Forecast[]> {
    return this.db.query<ForecastEntity>(
      ForecastEntity.getTableName(),
      ForecastEntity.getTableColumns(),
      (predicates) => predicates.equalTo(ForecastEntity.getTableColumns()[0], cityId),
      (resultSet: relationalStore.ResultSet) => resultSetToForecasts(resultSet)
    );
  }
}
