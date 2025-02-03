import { DbTable } from './DbTable';

export abstract class BaseEntity {

  protected static TABLE: DbTable;

  static getTableName(): string {
    return this.TABLE?.tableName ?? 'unknown_table';
  }

  static getTableColumns(): string[] {
    return this.TABLE?.columns ?? [];
  }

  getTableName(): string {
    return (this.constructor as typeof BaseEntity).getTableName();
  }

  getTableColumns(): string[] {
    return (this.constructor as typeof BaseEntity).getTableColumns();
  }
}