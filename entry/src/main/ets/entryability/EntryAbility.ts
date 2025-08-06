import { AbilityConstant, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';

import {
  CityDAORdb,
  MyMeteoDB,
  WeatherAPI,
  WeatherDAORdb,
  ForecastDAORdb,
  WeatherLocalDataSource,
  WeatherRemoteDataSource,
  WeatherRepository
} from '@mymeteo/data';

export default class EntryAbility extends UIAbility {

  private repository?: WeatherRepository;
  private initPromise: Promise<void>;

  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onCreate');
    this.initPromise = this.initDbAndRepo();
  }

  async onWindowStageCreate(windowStage: window.WindowStage): Promise<void> {
    // Main window is created, set main page for this ability
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onWindowStageCreate');

    // We must ensure that the database has been initialized before we load the UI content.
    await this.initPromise;
    hilog.warn(0x0000, 'testTag', '%{public}s', 'DB and Repository initialized.');

    windowStage.loadContent('pages/Index', (err) => {
      if (err.code) {
        hilog.error(0x0000, 'testTag', 'Failed to load the content. Cause: %{public}s', JSON.stringify(err) ?? '');
        return;
      }
      hilog.info(0x0000, 'testTag', 'Succeeded in loading the content.');
    });
  }

  onDestroy(): void {
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onDestroy');
  }

  onWindowStageDestroy(): void {
    // Main window is destroyed, release UI related resources
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onWindowStageDestroy');
  }

  onForeground(): void {
    // Ability has brought to foreground
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onForeground');
  }

  onBackground(): void {
    // Ability has back to background
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onBackground');
  }

  private async initDbAndRepo(): Promise<void> {

    try {
      const dbInstance = await MyMeteoDB.getInstance(this.context);

      this.repository = new WeatherRepository(
        new WeatherRemoteDataSource(new WeatherAPI()),
        new WeatherLocalDataSource(
          new CityDAORdb(dbInstance),
          new WeatherDAORdb(dbInstance),
          new ForecastDAORdb(dbInstance)
        )
      );

      globalThis.weatherRepository = this.repository;
      const cities = await this.repository.getSavedCities();
      hilog.warn(0x0000, 'testTag', 'Saved cities: %{public}s', JSON.stringify(cities));

    } catch (error) {
      hilog.error(0x0000, 'testTag', 'DB init error: %{public}s', JSON.stringify(error));
    }
  }
}
