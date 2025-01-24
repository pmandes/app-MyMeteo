import relationalStore from '@ohos.data.relationalStore';
import { DbTable } from '../../database/db/DbTable';

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
    tableName: 'city',
    sqlCreate: 'CREATE TABLE IF NOT EXISTS city(' +
      'id INTEGER PRIMARY KEY AUTOINCREMENT,' +
      'name TEXT, ' +
      'latitude REAL,' +
      'longitude REAL)',
    columns: ['id', 'name', 'latitude', 'longitude']
  };

}