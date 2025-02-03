export interface Entity {
  getTableName(): string;
  getTableColumns(): string[];
}