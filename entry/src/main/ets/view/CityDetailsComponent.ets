import { City, CurrentWeather, Forecast } from '@mymeteo/data';
import { CurrentWeatherComponent } from './CurrentWeatherComponent';
import { WeekForecastComponent } from './WeekForecastComponent';

@Component
export struct CityDetailsComponent {
  @Link city: City;
  @Link currentWeather: CurrentWeather;
  @Link forecast: Forecast;
  @Prop updatedAt: string = '';

  build() {
    Column() {
      if (this.city) {
        CurrentWeatherComponent({ city: this.city, currentWeather: this.currentWeather })
        if (this.forecast) {
          WeekForecastComponent({ forecast: this.forecast })
        }
        if (this.updatedAt) {
          Text('Last updated: ' + this.updatedAt)
            .id('weather-updated-at')
            .fontSize(13)
            .fontColor('#E6FFFFFF')
            .textShadow({ color: '#33182431', offsetX: 0, offsetY: 1, radius: 3 })
            .textAlign(TextAlign.Center)
            .width('100%')
            .margin({ top: 20, bottom: 12 })
        }
      }
    }.width('100%').padding({ left: 12, right: 12, bottom: 12 })
  }
}
