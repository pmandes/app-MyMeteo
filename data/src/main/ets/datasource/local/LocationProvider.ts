import { LatLng } from '../../net/dto/WeatherDTO';
import { ILocationProvider } from './ILocationProvider';
import { geoLocationManager } from '@kit.LocationKit';
import { AppError } from '../../common/AppError';

export class LocationProvider implements ILocationProvider {
  async getCurrentLocation(): Promise<LatLng> {
    if (!geoLocationManager.isLocationEnabled()) {
      throw new AppError(1201, 'Enable location in device settings.');
    }
    const request: geoLocationManager.CurrentLocationRequest = {
      priority: geoLocationManager.LocationRequestPriority.FIRST_FIX,
      scenario: geoLocationManager.LocationRequestScenario.UNSET,
      maxAccuracy: 0,
      timeoutMs: 10000
    };
    try {
      const location = await geoLocationManager.getCurrentLocation(request);
      return { latitude: location.latitude, longitude: location.longitude };
    } catch (error) {
      throw new AppError(1202, 'Unable to obtain location. Check location permissions and try again.');
    }
  }
}
