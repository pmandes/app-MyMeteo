import { common, Permissions } from '@kit.AbilityKit';
import { PermissionManager } from '@mymeteo/common';
import { AppError, City, CurrentWeather } from '@mymeteo/data';
import { CurrentWeatherComponent } from '../view/CurrentWeatherComponent';
import { weatherViewModel } from '../viewmodel/WeatherViewModel';

@Entry
@Component
struct Index {
  @State currentWeather: CurrentWeather | null = null;
  @State city: City | null = null;
  @State loading: boolean = true;
  @State error: string = '';

  aboutToAppear(): void {
    this.fetchWeather();
  }

  build() {
    Column() {
      if (this.loading) {
        LoadingProgress().width(32).height(32).color(Color.White)
        Text('Loading weather…').fontColor(Color.White).fontSize(14)
      } else if (this.error) {
        Text(this.error).fontColor(Color.White).fontSize(14).textAlign(TextAlign.Center)
          .padding({ left: 28, right: 28 })
        Button('Retry').margin({ top: 12 }).onClick(() => this.fetchWeather())
      } else if (this.currentWeather && this.city) {
        CurrentWeatherComponent({ city: this.city, currentWeather: this.currentWeather })
      }
    }
    .justifyContent(FlexAlign.Center)
    .linearGradient({ direction: GradientDirection.RightBottom, colors: [['#ffcad8ea', 0.0], ['#ff2f6ba7', 1.0]] })
    .width('100%').height('100%')
  }

  async fetchWeather(): Promise<void> {
    this.loading = true;
    this.error = '';
    try {
      const context = this.getUIContext().getHostContext() as common.UIAbilityContext;
      const permissions: Permissions[] = ['ohos.permission.APPROXIMATELY_LOCATION', 'ohos.permission.LOCATION'];
      if (!await new PermissionManager().requestPermissions(context, permissions)) {
        throw new AppError(1200, 'Allow location access to display local weather.');
      }
      const city = await weatherViewModel.getLocation();
      const data = await weatherViewModel.getWeatherData(city);
      if (!data.currentWeather || !data.currentWeather.current) {
        throw new AppError(1003, 'Weather data is unavailable. Try again.');
      }
      this.city = city;
      this.currentWeather = data.currentWeather;
    } catch (error) {
      this.error = (error as Error).message || 'Unable to load weather. Try again.';
    } finally {
      this.loading = false;
    }
  }
}
