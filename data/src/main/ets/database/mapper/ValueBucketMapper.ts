import relationalStore from '@ohos.data.relationalStore';

type FieldType =
| number
  | string
  | boolean
  | Date
  | object
  | Uint8Array
  | null;

interface MapperConfig {
  dateFields?: string[];
  jsonFields?: string[];
}

export class GenericEntityMapper {
  private dateFields: Set<string>;
  private jsonFields: Set<string>;

  constructor(config?: MapperConfig) {
    this.dateFields = new Set(config?.dateFields || []);
    this.jsonFields = new Set(config?.jsonFields || []);
  }

  toValuesBucket<T extends Record<string, FieldType>>(entity: T): relationalStore.ValuesBucket {
    const bucket: relationalStore.ValuesBucket = {};

    Object.keys(entity).forEach((key: string) => {
      const value = entity[key];
      const converted = this.convertValue(key, value);

      if (converted !== null && converted !== undefined) {
        bucket[key] = converted;
      }
    });

    return bucket;
  }

  private convertValue(key: string, value: FieldType): relationalStore.ValueType {
    if (this.dateFields.has(key)) {
      return this.handleDate(value);
    }

    if (this.jsonFields.has(key)) {
      return this.handleJson(value);
    }

    return this.mapBasicTypes(value);
  }

  private handleDate(value: FieldType): number {
    if (value instanceof Date) {
      return value.getTime();
    }
    if (typeof value === 'number') {
      return value;
    }
    throw new Error(`Invalid date value for field: ${value}`);
  }

  private handleJson(value: FieldType): string {
    try {
      return typeof value === 'string' ? value : JSON.stringify(value);
    } catch (e) {
      console.error(`JSON serialization error: ${e.message}`);
      return 'null';
    }
  }

  private mapBasicTypes(value: FieldType): relationalStore.ValueType {
    switch (typeof value) {
      case 'number':
      case 'string':
      case 'boolean':
        return value;
      case 'object':
        return this.handleObject(value);
      default:
        console.warn(`Unsupported type: ${typeof value}`);
        return null;
    }
  }

  private handleObject(value: object | null): relationalStore.ValueType {
    if (value === null) return null;
    if (value instanceof Uint8Array) return value;
    return JSON.stringify(value);
  }
}