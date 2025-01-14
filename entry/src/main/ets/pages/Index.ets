import { SearchBarComponent } from '../view/SearchBarComponent';
import { ResultsComponent } from '../view/ResultsComponent';
import { CityDetailsComponent } from '../view/CityDetailsComponent';
import { LoadingComponent } from '../view/ui/LoadingComponent';
import { City, CurrentWeather, Forecast } from '../model/WeatherModel';

export enum ViewState {
  IDLE,
  LOADING,
  SHOW_RESULTS,
  SHOW_CITY
}

@Entry
@Component
struct Index {

  @State viewState: ViewState = ViewState.IDLE;
  @State cities: City[] = [];
  @State selectedCity?: City = undefined;
  @State currentWeather?: CurrentWeather = undefined;
  @State forecast?: Forecast = undefined;

  build() {

    Column() {

      SearchBarComponent({
        viewState: this.viewState,
        cities: this.cities
      }).margin({ top: 32 });

      if (this.viewState == ViewState.IDLE || this.viewState == ViewState.SHOW_RESULTS) {

        ResultsComponent({
          viewState: this.viewState,
          results: this.cities,
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

      }

    }.margin( { bottom: 64  } ).padding( 16 )
    .linearGradient({
      direction: GradientDirection.RightBottom,
      colors: [[$r('app.color.background_start'), 0.0], [$r('app.color.background_end'), 1.0]]
    })
    .height('100%')
  }
}
