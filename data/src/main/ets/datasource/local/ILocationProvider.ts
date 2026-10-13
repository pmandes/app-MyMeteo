import { LatLng } from "../../net/dto/WeatherDTO";

export interface ILocationProvider {
  getCurrentLocation(): Promise<LatLng>;
}
