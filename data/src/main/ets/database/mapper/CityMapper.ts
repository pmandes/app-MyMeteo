import { City } from '../../net/dto/WeatherDTO';
import { CityEntity } from '../entity/CityEntity';
import relationalStore from '@ohos.data.relationalStore';

export function entityToCity(entity: CityEntity): City {
  return {
    place_id: entity.cityId,
    name: entity.cityName,
    display_name: entity.cityDisplayName,
    lat: entity.latitude,
    lon: entity.longitude,
    last_update: entity.lastUpdate
  }
}

export function cityToEntity(city: City): CityEntity {
  return new CityEntity(
    city.place_id,
    city.name,
    city.display_name,
    city.lat,
    city.lon,
    city.last_update
  );
}

export function entityToRecord(entity: CityEntity): relationalStore.ValuesBucket {
  return {
    id: entity.cityId,
    name: entity.cityName,
    display_name: entity.cityDisplayName,
    latitude: entity.latitude,
    longitude: entity.longitude,
    timestamp: entity.lastUpdate.getTime()
  }
}

export function resultSetToCities(resultSet: relationalStore.ResultSet): City[] {
  const cities: City[] = [];
  while(resultSet.goToNextRow()) {
    const city: City = {
      place_id: resultSet.getLong(resultSet.getColumnIndex('id')),
      name: resultSet.getString(resultSet.getColumnIndex('name')),
      display_name: resultSet.getString(resultSet.getColumnIndex('display_name')),
      lat: resultSet.getDouble(resultSet.getColumnIndex('latitude')),
      lon: resultSet.getDouble(resultSet.getColumnIndex('longitude')),
      last_update: new Date(resultSet.getDouble(resultSet.getColumnIndex('timestamp')))
    }
    cities.push(city)
  }
  return cities;
}