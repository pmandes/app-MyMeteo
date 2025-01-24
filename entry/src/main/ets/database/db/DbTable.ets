export interface DbTable {
  tableName: string;
  sqlCreate: string;
  columns: string[];
}