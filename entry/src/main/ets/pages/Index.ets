import { SearchBarComponent } from '../view/SearchBarComponent';
import { ResultsComponent } from '../view/ResultsComponent';
import { CityDetailsComponent } from '../view/CityDetailsComponent';
import { LoadingComponent } from '../view/ui/LoadingComponent';
import { AppError, City, CurrentWeather, Forecast } from '@mymeteo/data';
import { ErrorComponent } from '../view/ui/ErrorComponent';
import { categoryViewModel, CategoryViewModel } from '../viewmodel/CategoryViewModel';


export enum ViewState {
  IDLE,
  LOADING,
  ERROR,
  SHOW_RESULTS,
  SHOW_CITY
}

@Entry
@Component
struct Index {

  @State viewModel: CategoryViewModel = categoryViewModel;

  @State viewState: ViewState = ViewState.IDLE;
  @State cities: City[] = [];
  @State savedCities: City[] = [];
  @State selectedCity?: City = undefined;
  @State currentWeather?: CurrentWeather = undefined;
  @State forecast?: Forecast = undefined;
  @State error?: AppError = undefined;

  aboutToAppear(): void {
    console.debug("Index page is about to appear...");
    this.fetchSavedCities();
  }

  onPageShow(): void {
    console.debug("Index page: onPageShow...");
  }

  build() {

    Column() {

      SearchBarComponent({
        viewState: this.viewState,
        cities: this.cities,
        error: this.error
      }).margin({ top: 8 });

      if (this.viewState == ViewState.IDLE || this.viewState == ViewState.SHOW_RESULTS) {

        ResultsComponent({
          viewState: this.viewState,
          results: this.cities,
          savedCities: this.savedCities,
          selectedCity: this.selectedCity,
          currentWeather: this.currentWeather,
          forecast: this.forecast
        });

      } else if (this.viewState == ViewState.SHOW_CITY) {

        CityDetailsComponent({
          viewState: this.viewState,
          city: this.selectedCity,
          currentWeather: this.currentWeather,
          forecast: this.forecast
        });

      } else if (this.viewState == ViewState.LOADING) {

        LoadingComponent();

      } else if (this.viewState == ViewState.ERROR) {

        ErrorComponent({ error: this.error });
      }

    }.margin( { bottom: 64  } ).padding( 16 )
    .linearGradient({
      direction: GradientDirection.RightBottom,
      colors: [[$r('app.color.background_start'), 0.0], [$r('app.color.background_end'), 1.0]]
    })
    .height('100%')
  }

  onBackPress(): boolean | void {

    console.warn("onBackPress");

    if (this.viewState === ViewState.SHOW_CITY) {

      if (this.cities.length > 0) {
        this.viewState = ViewState.SHOW_RESULTS;
      } else {
        this.viewState = ViewState.IDLE;
      }

      return true;

    } else if (this.viewState === ViewState.SHOW_RESULTS) {

      this.fetchSavedCities();
      this.viewState = ViewState.IDLE;

      return true;

    } else {
      return false;
    }
  }

  async fetchSavedCities() {
    this.savedCities = await categoryViewModel.getSavedCities();
  }
}
