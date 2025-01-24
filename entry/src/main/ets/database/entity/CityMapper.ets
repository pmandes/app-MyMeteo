import { City } from '../../model/WeatherModel';
import { CityEntity } from './CityEntity';
import relationalStore from '@ohos.data.relationalStore';

export function cityToEntity(city: City): CityEntity {
  return new CityEntity(
    city.id,
    city.name,
    city.display_name,
    city.lat,
    city.lon
  );
}

export function entityToCity(entity: CityEntity): City {
  return {
    id: entity.cityId,
    name: entity.cityName,
    display_name: entity.cityDisplayName,
    lat: entity.latitude,
    lon: entity.longitude
  };
}

export function resultSetToCities(resultSet: relationalStore.ResultSet): City[] {
  const cities: City[] = [];
  while(resultSet.goToNextRow()) {
    const city: City = {
      id: resultSet.getLong(resultSet.getColumnIndex('id')),
      name: resultSet.getString(resultSet.getColumnIndex('name')),
      display_name: resultSet.getString(resultSet.getColumnIndex('name')),
      lat: resultSet.getDouble(resultSet.getColumnIndex('latitude')),
      lon: resultSet.getDouble(resultSet.getColumnIndex('longitude'))
    }
    cities.push(city)
  }
  return cities;
}