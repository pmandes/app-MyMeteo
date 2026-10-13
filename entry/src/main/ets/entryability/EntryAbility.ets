import { UIAbility } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';
import { CityDAORdb, MyMeteoDB, WeatherAPI, WeatherDAORdb, ForecastDAORdb,
  WeatherLocalDataSource, WeatherRemoteDataSource, WeatherRepository, LocationProvider } from '@mymeteo/data';
import { weatherViewModel } from '../viewmodel/WeatherViewModel';

export default class EntryAbility extends UIAbility {
  async onWindowStageCreate(windowStage: window.WindowStage): Promise<void> {
    try {
      const db = await MyMeteoDB.getInstance(this.context);
      const repository = new WeatherRepository(
        new WeatherRemoteDataSource(new WeatherAPI()),
        new WeatherLocalDataSource(new CityDAORdb(db), new WeatherDAORdb(db), new ForecastDAORdb(db)),
        new LocationProvider()
      );
      weatherViewModel.setRepository(repository);
    } catch (error) {
      hilog.error(0x0000, 'EntryAbility', 'Repository initialization failed: %{public}s', JSON.stringify(error));
    }
    // Load the page even when initialization fails, so it can display an error.
    windowStage.loadContent('pages/Index', (error) => {
      if (error.code) {
        hilog.error(0x0000, 'EntryAbility', 'Cannot load main page: %{public}s', JSON.stringify(error));
      }
    });
  }
}
