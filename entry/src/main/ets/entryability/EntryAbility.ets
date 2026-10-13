import { UIAbility } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';
import { CityDAORdb, MyMeteoDB, WeatherAPI, WeatherDAORdb, ForecastDAORdb,
  WeatherLocalDataSource, WeatherRemoteDataSource, WeatherRepository, LocationProvider } from '@mymeteo/data';
import { weatherViewModel } from '../viewmodel/WeatherViewModel';

export default class EntryAbility extends UIAbility {
  private mainWindow?: window.Window;
  private updateInsets = (): void => {
    if (!this.mainWindow) { return; }
    const system = this.mainWindow.getWindowAvoidArea(window.AvoidAreaType.TYPE_SYSTEM);
    const indicator = this.mainWindow.getWindowAvoidArea(window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR);
    const cutout = this.mainWindow.getWindowAvoidArea(window.AvoidAreaType.TYPE_CUTOUT);
    AppStorage.setOrCreate('myMeteoTopPx', Math.max(system.topRect.height, cutout.topRect.height));
    AppStorage.setOrCreate('myMeteoBottomPx', Math.max(system.bottomRect.height, indicator.bottomRect.height));
    AppStorage.setOrCreate('myMeteoLeftPx', Math.max(system.leftRect.width, cutout.leftRect.width));
    AppStorage.setOrCreate('myMeteoRightPx', Math.max(system.rightRect.width, cutout.rightRect.width));
  };

  async onWindowStageCreate(windowStage: window.WindowStage): Promise<void> {
    try {
      this.mainWindow = windowStage.getMainWindowSync();
      await this.mainWindow.setWindowLayoutFullScreen(true);
      await this.mainWindow.setWindowBackgroundColor('#FFDCE8F5');
      await this.mainWindow.setWindowSystemBarProperties({ statusBarColor: '#00000000',
        navigationBarColor: '#00000000', statusBarContentColor: '#182F48', navigationBarContentColor: '#182F48' });
      this.updateInsets();
      this.mainWindow.on('avoidAreaChange', this.updateInsets);
    } catch (error) {
      hilog.warn(0x0000, 'EntryAbility', 'Window styling failed: %{public}s', JSON.stringify(error));
    }
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
      this.updateInsets();
    });
  }

  onWindowStageDestroy(): void {
    this.mainWindow?.off('avoidAreaChange', this.updateInsets);
    this.mainWindow = undefined;
  }
}
