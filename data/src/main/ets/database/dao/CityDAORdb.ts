/**
 * A Data Access Object (DAO) implementation for managing City data using a Relational Database.
 * This class communicates with the database through an instance of {@link BaseRelationalDatabase}.
 */
import { ICityDAO } from './ICityDAO';
import { CityEntity } from '../entity/CityEntity';
import { BaseRelationalDatabase } from '../db/BaseRelationalDatabase';
import relationalStore from '@ohos.data.relationalStore';
import { City } from '../../net/dto/WeatherDTO';
import { cityToEntity, entityToRecord, resultSetToCities } from '../mapper/CityMapper';

export class CityDAORdb implements ICityDAO {
  private db: BaseRelationalDatabase;

  /**
   * Constructs a new CityDAORdb with the specified BaseRelationalDatabase instance.
   * @param {BaseRelationalDatabase} dbInstance - The relational database instance used for CRUD operations.
   */
  constructor(dbInstance: BaseRelationalDatabase) {
    this.db = dbInstance;
  }

  /**
   * Retrieves all city records from the database.
   * @returns {Promise<City[]>} A promise that resolves to an array of City objects.
   */
  async getAllCities(): Promise<City[]> {
    return this.db.query(
      CityEntity.getTableName(),
      CityEntity.getTableColumns(),
      (predicates) => predicates,
      (resultSet: relationalStore.ResultSet) => resultSetToCities(resultSet)
    );
  }

  /**
   * Retrieves a city record by its unique ID.
   * @param {number} cityId - The unique ID of the city.
   * @returns {Promise<City[]>} A promise that resolves to an array of City objects matching the ID.
   */
  async getCityById(cityId: number): Promise<City[]> {
    return this.db.query(
      CityEntity.getTableName(),
      CityEntity.getTableColumns(),
      (predicates) => predicates.equalTo(CityEntity.getTableColumns()[0], cityId),
      (resultSet: relationalStore.ResultSet) => resultSetToCities(resultSet)
    );
  }

  /**
   * Inserts a new city record into the database.
   * @param {City} city - The city data to be inserted.
   * @returns {Promise<number>} A promise that resolves to the row ID of the inserted record.
   */
  async insertCity(city: City): Promise<number> {
    city.last_update = new Date();
    return this.db.insert<CityEntity>(
      CityEntity.getTableName(),
      cityToEntity(city),
      (entity) => entityToRecord(entity),
      true
    );
  }

  /**
   * Updates an existing city record in the database.
   * @param {City} city - The updated city data.
   * @returns {Promise<number>} A promise that resolves to the number of rows affected by the update.
   */
  async updateCity(city: City): Promise<number> {
    city.last_update = new Date();
    return this.db.update<CityEntity>(
      CityEntity.getTableName(),
      cityToEntity(city),
      (predicates) => predicates.equalTo(
        CityEntity.getTableColumns()[0], city.place_id
      ),
      (entity) => entityToRecord(entity)
    );
  }

  /**
   * Deletes a city record from the database.
   * @param {City} city - The city data specifying which record to delete (via city ID).
   * @returns {Promise<number>} A promise that resolves to the number of rows deleted.
   */
  async deleteCity(city: City): Promise<number> {
    return this.db.delete<CityEntity>(
      CityEntity.getTableName(),
      (predicates) => predicates.equalTo(CityEntity.getTableColumns()[0], city.place_id)
    );
  }
}
