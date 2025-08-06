/**
 * This is a concrete database class extending abstract RelationalDatabase.
 * Includes its own logic for table initialization and managing a singleton instance.
 */
import { relationalStore } from '@kit.ArkData';
import { BaseRelationalDatabase } from './db/BaseRelationalDatabase';
import { DBConfig } from '../config/DBConfig';
import { Context } from '@kit.AbilityKit'

export class MyMeteoDB extends BaseRelationalDatabase {
  private static instance: MyMeteoDB | null = null;

  /**
   * Private constructor calling the parent constructor.
   * @param {relationalStore.RdbStore} rdbStore - The RdbStore instance to be passed up.
   */
  private constructor(rdbStore: relationalStore.RdbStore) {
    super(rdbStore);
  }

  /**
   * Singleton method to get an instance of MyMeteoDB.
   * @param {Context} context - The application context required to create RdbStore.
   * @returns {Promise<MyMeteoDB>} An instance of MyMeteoDB.
   */
  public static async getInstance(context: Context): Promise<MyMeteoDB> {
    if (!MyMeteoDB.instance) {
      const store = await relationalStore.getRdbStore(context, DBConfig.STORE_CONFIG);
      await MyMeteoDB.initializeTables(store);
      MyMeteoDB.instance = new MyMeteoDB(store);
      console.debug('DB initialized: ' + DBConfig.STORE_CONFIG.name);
    }
    return MyMeteoDB.instance;
  }

  /**
   * Initializes all necessary tables for this particular database.
   * @param {relationalStore.RdbStore} store - The RdbStore instance for executing SQL statements.
   */
  private static async initializeTables(store: relationalStore.RdbStore): Promise<void> {

    await store.executeSql(DBConfig.CITY_TABLE.sqlCreate);
    console.debug(`DB Table created: ${DBConfig.CITY_TABLE.tableName}[${DBConfig.CITY_TABLE.columns}]`);

    await store.executeSql(DBConfig.WEATHER_TABLE.sqlCreate);
    console.debug(`DB Table created: ${DBConfig.WEATHER_TABLE.tableName}[${DBConfig.WEATHER_TABLE.columns}]`);

    await store.executeSql(DBConfig.FORECAST_TABLE.sqlCreate);
    console.debug(`DB Table created: ${DBConfig.FORECAST_TABLE.tableName}[${DBConfig.FORECAST_TABLE.columns}]`);
  }
}
