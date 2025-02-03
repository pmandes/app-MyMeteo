/**
 * This abstract class provides common CRUD methods for relational databases
 * using the '@ohos.data.relationalStore' module. Concrete database classes
 * should extend this class and implement their own initialization logic.
 */
import relationalStore from '@ohos.data.relationalStore';
import { AppError } from '../../common/AppError';
import { BusinessError } from '@ohos.base';
import { BaseEntity } from './BaseEntity';

export abstract class BaseRelationalDatabase {
  protected rdbStore: relationalStore.RdbStore;

  /**
   * Protected constructor to be called only by subclasses.
   * @param {relationalStore.RdbStore} rdbStore - The RdbStore instance for database operations.
   */
  protected constructor(rdbStore: relationalStore.RdbStore) {
    this.rdbStore = rdbStore;
  }

  /**
   * Inserts a record into the specified table.
   * @template T - The entity type extending from Entity.
   * @param {string} tableName - The name of the table where the record will be inserted.
   * @param {T} entity - The entity object to be inserted.
   * @param {(entity: T) => relationalStore.ValuesBucket} toRowData - A function that maps the entity to a ValuesBucket.
   * @returns {Promise<number>} A promise that resolves to the ID of the inserted record.
   */
  public async insert<T extends BaseEntity>(
    tableName: string,
    entity: T,
    toRowData: (entity: T) => relationalStore.ValuesBucket,
    overwrite: boolean = false
  ): Promise<number> {
    return new Promise((resolve, reject) => {
      console.debug('DB Insert into table: ' + tableName + ', data: ' + JSON.stringify(entity));

      if (!this.rdbStore) {
        return reject(new AppError(1100, 'Unable to connect to database'));
      }

      const conflictResolution = overwrite
        ? relationalStore.ConflictResolution.ON_CONFLICT_REPLACE
        : relationalStore.ConflictResolution.ON_CONFLICT_ROLLBACK;

      console.debug('Record: ' + JSON.stringify(toRowData(entity)));

      this.rdbStore
        .insert(tableName, toRowData(entity), conflictResolution)
        .then(value => {
          console.debug('DB insert: ' + value);
          resolve(value);
        })
        .catch((error: BusinessError) => {
          console.error('Database error:', JSON.stringify(error));
          reject(new AppError(1101, 'Unable to insert data'));
        });
    });
  }

  /**
   * Queries records from the specified table based on given predicates.
   * @template T - The entity type extending from Entity.
   * @param {string} tableName - The name of the table to query.
   * @param {string[]} columns - The columns to retrieve from the table.
   * @param {(predicates: relationalStore.RdbPredicates) => relationalStore.RdbPredicates} getPredicates -
   *  A function that configures the RdbPredicates for the query.
   * @param {(resultSet: relationalStore.ResultSet) => T[]} rowMapper - A function that maps the result set to an array of entities.
   * @returns {Promise<T[]>} A promise that resolves to an array of entities matching the query.
   */
  public async query<T extends BaseEntity>(
    tableName: string,
    columns: string[],
    getPredicates: (predicates: relationalStore.RdbPredicates) => relationalStore.RdbPredicates,
    rowMapper: (resultSet: relationalStore.ResultSet) => any[]
  ): Promise<any[]> {
    return new Promise((resolve, reject) => {
      console.debug('DB Select from table: ' + tableName);

      if (!this.rdbStore) {
        return reject(new AppError(1100, 'Unable to connect to database'));
      }

      const predicates = getPredicates(new relationalStore.RdbPredicates(tableName));
      console.debug('DB query predicates: ' + JSON.stringify(predicates));

      this.rdbStore
        .query(predicates, columns)
        .then(resultSet => {
          const count: number = resultSet.rowCount;

          console.debug('DB row count: ' + count);
          console.debug('DB resultSet: ' + JSON.stringify(resultSet));

          const result: T[] = rowMapper(resultSet);

          console.debug('DB result: ' + JSON.stringify(result));

          resultSet.close();
          resolve(result);
        })
        .catch((error: BusinessError) => {
          console.error('Database error:', JSON.stringify(error));
          reject(new AppError(1102, 'Unable to query data'));
        });
    });
  }

  /**
   * Updates records in the specified table based on given predicates.
   * @template T - The entity type extending from Entity.
   * @param {string} tableName - The name of the table to update.
   * @param {T} entity - The entity data used for updating the records.
   * @param {(predicates: relationalStore.RdbPredicates) => relationalStore.RdbPredicates} getPredicates -
   *  A function that configures the RdbPredicates for the update.
   * @param {(entity: T) => relationalStore.ValuesBucket} toRowData - A function that maps the entity to a ValuesBucket.
   * @returns {Promise<number>} A promise that resolves to the number of records updated.
   */
  public async update<T extends BaseEntity>(
    tableName: string,
    entity: T,
    getPredicates: (predicates: relationalStore.RdbPredicates) => relationalStore.RdbPredicates,
    toRowData: (entity: T) => relationalStore.ValuesBucket,
    overwrite: boolean = false
  ): Promise<number> {
    return new Promise((resolve, reject) => {
      if (!this.rdbStore) {
        return reject(new AppError(1100, 'Unable to connect to database'));
      }

      const predicates = getPredicates(new relationalStore.RdbPredicates(tableName));
      console.debug('DB Update on table: ' + tableName + ', data: ' + JSON.stringify(entity));

      const conflictResolution = overwrite
        ? relationalStore.ConflictResolution.ON_CONFLICT_REPLACE
        : relationalStore.ConflictResolution.ON_CONFLICT_ROLLBACK;

      this.rdbStore
        .update(toRowData(entity), predicates, conflictResolution)
        .then(value => {
          console.debug('DB update: ' + value);
          resolve(value);
        })
        .catch((error: BusinessError) => {
          console.error('Database error:', JSON.stringify(error));
          reject(new AppError(1104, 'Unable to update data'));
        });
    });
  }

  /**
   * Deletes records from the specified table based on given predicates.
   * @template T - The entity type extending from Entity.
   * @param {string} tableName - The name of the table to delete from.
   * @param {(predicates: relationalStore.RdbPredicates) => relationalStore.RdbPredicates} getPredicates -
   *  A function that configures the RdbPredicates for the delete operation.
   * @returns {Promise<number>} A promise that resolves to the number of rows deleted.
   */
  public async delete<T extends BaseEntity>(
    tableName: string,
    getPredicates: (predicates: relationalStore.RdbPredicates) => relationalStore.RdbPredicates,
  ): Promise<number> {
    return new Promise((resolve, reject) => {
      console.debug('DB Delete from table: ' + tableName);

      if (!this.rdbStore) {
        return reject(new AppError(1100, 'Unable to connect to database'));
      }

      const predicates = getPredicates(new relationalStore.RdbPredicates(tableName));
      this.rdbStore
        .delete(predicates)
        .then(rows => {
          console.debug('DB rows deleted: ' + rows);
          resolve(rows);
        })
        .catch((error: BusinessError) => {
          console.error('Database error:', JSON.stringify(error));
          reject(new AppError(1103, 'Unable to delete data'));
        });
    });
  }
}
