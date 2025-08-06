import { ViewState } from '../pages/Index';
import { City, CurrentWeather, Forecast } from '@mymeteo/data';
import { CurrentWeatherComponent } from './CurrentWeatherComponent';
import { WeekForecastComponent } from './WeekForecastComponent';
import { curves } from '@kit.ArkUI';

@Component
export struct CityDetailsComponent {
  @State isRefreshing: boolean = false
  @State promptText: string = "Refreshing..."
  @Link city: City;
  @Link currentWeather: CurrentWeather;
  @Link viewState: ViewState;
  @Link forecast: Forecast;

  private effect: TransitionEffect =
    TransitionEffect.OPACITY.animation({ curve: curves.springMotion(0.4, 0.8) })
      .combine(TransitionEffect.move(TransitionEdge.END))

  build() {
      Scroll() {
        Column() {
          if (this.city) {
            CurrentWeatherComponent({ city: this.city, currentWeather: this.currentWeather })

            if (this.forecast)
              WeekForecastComponent({ forecast: this.forecast })

            Blank(100)
          }
        }
      }.height("90%")
      .scrollBar(BarState.Off)
      .align(Alignment.Top)
      .transition(this.effect)
  }
}
