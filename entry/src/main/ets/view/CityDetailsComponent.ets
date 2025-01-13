import { ViewState } from '../pages/CategoryPage';
import { City, CurrentWeather, Forecast } from '../model/WeatherModel';
import { CurrentWeatherComponent } from './CurrentWeatherComponent';
import { WeekForecastComponent } from './WeekForecastComponent';

@Component
export struct CityDetailsComponent {
  @State isRefreshing: boolean = false
  @State promptText: string = "Refreshing..."
  @Link city?: City;
  @Link currentWeather?: CurrentWeather;
  @Link viewState: ViewState;
  @Link forecast?: Forecast;

  build() {

    Refresh({ refreshing: $$this.isRefreshing, promptText: this.promptText,  }) {

      Scroll() {

        Column() {

          if (this.city) {

            CurrentWeatherComponent({ city: this.city, currentWeather: this.currentWeather })

            WeekForecastComponent({ forecast: this.forecast })

            Blank(100)
          }
        }

      }.height("90%")
      .scrollBar(BarState.Off)
      .align(Alignment.Top)
    }
    .pullToRefresh(true)
    .refreshOffset(50)
    .onRefreshing(() => {

      setTimeout(() => {
        this.isRefreshing = false
      }, 1000)

      console.log('onRefreshing test')

    })
    .onStateChange((refreshStatus: RefreshStatus) => {

      console.info('Refresh onStatueChange state is ' + refreshStatus)

    })
    .onOffsetChange((value: number) => {

      console.info('Refresh onOffsetChange offset:' + value)

    })
  }
}
