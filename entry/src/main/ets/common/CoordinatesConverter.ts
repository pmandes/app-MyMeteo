
// Usage example:
// console.log(toDMS(51.1789, CoordinateType.LATITUDE)); // "51°10'44.04"N"
// console.log(toDMS(-0.0014, CoordinateType.LONGITUDE)); // "0°0'5.04"W"

export enum CoordinateType {
  LATITUDE = 'LATITUDE',
  LONGITUDE = 'LONGITUDE'
}

export function toDMS(value: number, type: CoordinateType): string {
  const absValue = Math.abs(value);
  const degrees = Math.floor(absValue);
  const minutesDecimal = (absValue - degrees) * 60;
  const minutes = Math.floor(minutesDecimal);
  const seconds = (minutesDecimal - minutes) * 60;

  const direction = type === CoordinateType.LATITUDE
    ? (value >= 0 ? 'N' : 'S')
    : (value >= 0 ? 'E' : 'W');

  return `${degrees}°${minutes}'${seconds.toFixed(2)}"${direction}`;
}

