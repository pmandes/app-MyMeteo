import { SearchBarComponent } from '../view/SearchBarComponent';
import { ResultsComponent } from '../view/ResultsComponent';
import { CityDetailsComponent } from '../view/CityDetailsComponent';
import { LoadingComponent } from '../view/ui/LoadingComponent';
import { AppError, City, CurrentWeather, Forecast } from '@mymeteo/data';
import { ErrorComponent } from '../view/ui/ErrorComponent';
import { weatherViewModel, WeatherViewModel } from '../viewmodel/WeatherViewModel';
import { formatWeatherUpdate } from '../common/WeatherTime';

export enum ViewState {
  IDLE, LOADING, ERROR, SHOW_RESULTS, SHOW_CITY
}

@Entry
@Component
struct Index {
  @State viewModel: WeatherViewModel = weatherViewModel;
  @State @Watch('onViewStateChange') viewState: ViewState = ViewState.IDLE;
  @State cities: City[] = [];
  @State savedCities: City[] = [];
  @State selectedCity?: City = undefined;
  @State currentWeather?: CurrentWeather = undefined;
  @State forecast?: Forecast = undefined;
  @State error?: AppError = undefined;
  @State updatedAt: string = '';
  @State refreshing: boolean = false;
  @State searchCollapse: number = 0;
  @StorageLink('myMeteoTopPx') topPx: number = 0;
  @StorageLink('myMeteoBottomPx') bottomPx: number = 0;
  @StorageLink('myMeteoLeftPx') leftPx: number = 0;
  @StorageLink('myMeteoRightPx') rightPx: number = 0;
  private scroller: Scroller = new Scroller();
  private searchEditing: boolean = false;
  private refreshGeneration: number = 0;

  aboutToAppear(): void {
    this.fetchSavedCities();
  }

  aboutToDisappear(): void {
    this.refreshGeneration++;
  }

  onViewStateChange(): void {
    this.refreshGeneration++;
    this.refreshing = false;
    this.searchCollapse = 0;
    this.scroller.scrollTo({ xOffset: 0, yOffset: 0 });
  }

  handleScroll(yOffset: number, state: ScrollState): void {
    if (this.searchEditing || this.scroller.currentOffset().yOffset <= 0) {
      this.searchCollapse = 0;
    } else if (state !== ScrollState.Idle) {
      this.searchCollapse = Math.max(0, Math.min(72, this.searchCollapse + yOffset));
    }
  }

  async refreshWeather(): Promise<void> {
    const city = this.selectedCity;
    if (!city || this.viewState !== ViewState.SHOW_CITY) {
      this.refreshing = false;
      return;
    }
    const generation = this.refreshGeneration;
    try {
      const data = await this.viewModel.getWeatherData(city, true);
      if (generation === this.refreshGeneration && this.viewState === ViewState.SHOW_CITY &&
        data.currentWeather && data.forecast) {
        this.currentWeather = data.currentWeather;
        this.forecast = data.forecast;
        this.updatedAt = formatWeatherUpdate(data.lastUpdated);
      }
    } catch (error) {
      // Keep the displayed weather and its original timestamp on refresh failure.
      console.warn('Weather refresh failed; keeping previous data.');
    } finally {
      if (generation === this.refreshGeneration) {
        this.refreshing = false;
      }
    }
  }

  @Builder
  content() {
    Scroll(this.scroller) {
      Column() {
        if (this.viewState === ViewState.IDLE || this.viewState === ViewState.SHOW_RESULTS) {
          ResultsComponent({ viewState: this.viewState, results: this.cities, savedCities: this.savedCities,
            selectedCity: this.selectedCity, currentWeather: this.currentWeather, forecast: this.forecast,
            error: this.error, updatedAt: this.updatedAt })
        } else if (this.viewState === ViewState.SHOW_CITY) {
          CityDetailsComponent({ city: this.selectedCity, currentWeather: this.currentWeather,
            forecast: this.forecast, updatedAt: this.updatedAt })
        } else if (this.viewState === ViewState.LOADING) {
          LoadingComponent()
        } else if (this.viewState === ViewState.ERROR) {
          ErrorComponent({ error: this.error })
        }
      }
      .width('100%')
      .padding({ top: this.getUIContext().px2vp(this.topPx) + 72,
        bottom: this.getUIContext().px2vp(this.bottomPx) + 16,
        left: this.getUIContext().px2vp(this.leftPx) + 8,
        right: this.getUIContext().px2vp(this.rightPx) + 8 })
    }
    .id('weather-content').width('100%').height('100%').scrollBar(BarState.Off)
    .align(Alignment.Top)
    .onDidScroll((xOffset: number, yOffset: number, state: ScrollState) => this.handleScroll(yOffset, state))
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
      Column() {}
        .width('100%').height('100%')
        .linearGradient({ direction: GradientDirection.RightBottom,
          colors: [[$r('app.color.background_start'), 0], [$r('app.color.background_end'), 1]] })

      if (this.viewState === ViewState.SHOW_CITY) {
        Refresh({ refreshing: $$this.refreshing, offset: this.getUIContext().px2vp(this.topPx) + 72 }) {
          this.content()
        }
        .id('weather-refresh').width('100%').height('100%')
        .refreshOffset(64).pullToRefresh(true)
        .onRefreshing(() => { this.refreshWeather(); })
      } else {
        this.content()
      }

      Stack({ alignContent: Alignment.Top }) {
        SearchBarComponent({ viewState: this.viewState, cities: this.cities, error: this.error,
          onEditingChange: (editing: boolean) => {
            this.searchEditing = editing;
            if (editing) { this.searchCollapse = 0; }
          } })
          .translate({ y: -this.searchCollapse })
      }
      .id('search-overlay').width('100%').height(72 - this.searchCollapse).clip(true)
      .margin({ top: this.getUIContext().px2vp(this.topPx) })
      .padding({ left: this.getUIContext().px2vp(this.leftPx), right: this.getUIContext().px2vp(this.rightPx) })

      Column() {
        Row() {}.id('status-glass').width('100%').height(this.getUIContext().px2vp(this.topPx))
          .backgroundColor('#40FFFFFF').backdropBlur(20)
          .border({ width: { bottom: 1 }, color: '#55FFFFFF' })
          .hitTestBehavior(HitTestMode.None)
        Blank().hitTestBehavior(HitTestMode.None)
        Row() {}.id('navigation-glass').width('100%').height(this.getUIContext().px2vp(this.bottomPx))
          .backgroundColor('#40FFFFFF').backdropBlur(20)
          .border({ width: { top: 1 }, color: '#55FFFFFF' })
          .hitTestBehavior(HitTestMode.None)
      }.width('100%').height('100%').hitTestBehavior(HitTestMode.None)
    }
    .width('100%').height('100%')
    .expandSafeArea([SafeAreaType.SYSTEM, SafeAreaType.CUTOUT],
      [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM, SafeAreaEdge.START, SafeAreaEdge.END])
  }

  onBackPress(): boolean | void {
    if (this.viewState === ViewState.SHOW_CITY) {
      this.viewState = this.cities.length ? ViewState.SHOW_RESULTS : ViewState.IDLE;
      if (!this.cities.length) { this.fetchSavedCities(); }
      return true;
    }
    if (this.viewState === ViewState.SHOW_RESULTS) {
      this.fetchSavedCities();
      this.viewState = ViewState.IDLE;
      return true;
    }
    return false;
  }

  async fetchSavedCities(): Promise<void> {
    try {
      this.savedCities = await weatherViewModel.getSavedCities();
    } catch (error) {
      this.error = error instanceof AppError ? error : new AppError(1100, 'Unable to load saved cities.');
      this.viewState = ViewState.ERROR;
    }
  }
}
