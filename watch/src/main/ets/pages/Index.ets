import { common, Permissions } from '@kit.AbilityKit';
import { PermissionManager, backgroundForWeather, WeatherBackground } from '@mymeteo/common';
import { AppError, City, CurrentWeather } from '@mymeteo/data';
import { CurrentWeatherComponent } from '../view/CurrentWeatherComponent';
import { weatherViewModel } from '../viewmodel/WeatherViewModel';

@Entry
@Component
struct Index {
  @State @Watch('onWeatherChange') currentWeather: CurrentWeather | null = null;
  @State city: City | null = null;
  @State loading: boolean = true;
  @State error: string = '';
  @State currentBackground: WeatherBackground = WeatherBackground.NONE;
  @State previousBackground: WeatherBackground = WeatherBackground.NONE;
  @State backgroundOpacity: number = 0;
  private backgroundPending: boolean = false;
  private backgroundGeneration: number = 0;

  aboutToAppear(): void {
    this.fetchWeather();
  }

  aboutToDisappear(): void {
    this.backgroundGeneration++;
  }

  onWeatherChange(): void {
    const next = backgroundForWeather(this.currentWeather?.current?.weather_code);
    if (next === this.currentBackground) { return; }
    this.backgroundGeneration++;
    this.previousBackground = this.currentBackground;
    this.currentBackground = next;
    this.backgroundOpacity = 0;
    this.backgroundPending = true;
    if (next === WeatherBackground.NONE) { this.fadeInBackground(); }
  }

  fadeInBackground(): void {
    if (!this.backgroundPending) { return; }
    this.backgroundPending = false;
    const generation = this.backgroundGeneration;
    this.getUIContext().animateTo({ duration: 2400, curve: Curve.EaseInOut, onFinish: () => {
      if (generation === this.backgroundGeneration) {
        this.previousBackground = WeatherBackground.NONE;
      }
    } }, () => { this.backgroundOpacity = 1; });
  }

  weatherBackgroundResource(background: WeatherBackground): Resource {
    switch (background) {
      case WeatherBackground.CLEAR: return $r('app.media.weather_bg_clear');
      case WeatherBackground.RAIN: return $r('app.media.weather_bg_rain');
      case WeatherBackground.SNOW: return $r('app.media.weather_bg_snow');
      default: return $r('app.media.weather_bg_cloudy');
    }
  }

  build() {
    Stack() {
      Column() {}.width('100%').height('100%')
        .linearGradient({ direction: GradientDirection.RightBottom,
          colors: [['#ffcad8ea', 0.0], ['#ff2f6ba7', 1.0]] })

      if (this.previousBackground !== WeatherBackground.NONE) {
        Image(this.weatherBackgroundResource(this.previousBackground)).width('100%').height('100%')
          .objectFit(ImageFit.Cover).opacity(1 - (this.currentBackground === WeatherBackground.NONE ? this.backgroundOpacity : 0))
          .hitTestBehavior(HitTestMode.None)
      }
      if (this.currentBackground !== WeatherBackground.NONE) {
        Image(this.weatherBackgroundResource(this.currentBackground)).id('weather-background').width('100%').height('100%')
          .objectFit(ImageFit.Cover).opacity(this.backgroundOpacity)
          .onComplete((event) => { if (event?.loadingStatus === 1) { this.fadeInBackground(); } })
          .hitTestBehavior(HitTestMode.None)
      }
      // Soft blue glass keeps small white labels legible over the pastel sky.
      Column() {}.width('100%').height('100%').backgroundColor('#4D102A43')
        .hitTestBehavior(HitTestMode.None)
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
    .width('100%').height('100%')
    }.width('100%').height('100%')
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
