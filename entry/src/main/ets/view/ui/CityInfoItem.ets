import { City, CurrentWeather } from '@mymeteo/data';
import { CoordinateType, toDMS } from '@mymeteo/common';
import { curves } from '@kit.ArkUI';
import { WeatherIcon } from './WeatherIcon';
import { TemperatureIcon } from './TemperatureIcon';

@Component
export struct CityInfoItem {

  @Prop city: City;
  @Prop currentWeather: CurrentWeather | null = null;

  private effect: TransitionEffect =
    // Apply the default opacity transition effect and specify springMotion (0.6, 0.8) as the curve.
    TransitionEffect.OPACITY.animation({ curve: curves.springMotion(0.4, 0.8) })
      // Combine with a scale transition effect, whose animation settings follow TransitionEffect above, that is, springMotion(0.6, 0.8).
      //.combine(TransitionEffect.scale({ x: 0, y: 0 }))
        // Apply a rotation transition effect, whose animation settings follow TransitionEffect above, that is, springMotion(0.6, 0.8).
      //.combine(TransitionEffect.rotate({ angle: 0 }))
        // Apply a translation transition effect, whose animation settings are specified by animation, which is springMotion().
      //.combine(TransitionEffect.translate({ y: 150 }).animation({ curve: curves.springMotion() }))
        // Apply a movement transition effect, whose animation settings follow TransitionEffect above, that is, springMotion().
      .combine(TransitionEffect.move(TransitionEdge.END))

  build() {
    Row() {
      Column() {

        //Text(JSON.stringify(this.city)).fontSize(8).fontColor(Color.Gray);

        Text(this.city.name)
          .fontSize(17)
          .fontWeight(FontWeight.Bold)
          .fontColor(Color.White)
          .textShadow({ color: '#33182431', offsetX: 0, offsetY: 1, radius: 3 })
          .margin({bottom: 6});

        Text(this.city.display_name)
          .fontSize(14)
          .fontColor('#E6FFFFFF')
          .textShadow({ color: '#33182431', offsetX: 0, offsetY: 1, radius: 3 });

        Row() {
          Image($r('app.media.ic_location_pointer'))
            .width(16)
            .height(16)
            .fillColor(Color.White)
            .margin({right: 4});

          Text(toDMS(this.city.lat, CoordinateType.LATITUDE) + ", "
            + toDMS(this.city.lon, CoordinateType.LONGITUDE))
            .fontSize(12)
            .fontColor('#E6FFFFFF')
            .textShadow({ color: '#33182431', offsetX: 0, offsetY: 1, radius: 3 });
        }.padding({top: 6, bottom: 6})

      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)

      if (this.currentWeather?.current) {
        Column({ space: 4 }) {
          if (Number.isFinite(this.currentWeather.current.weather_code)) {
            WeatherIcon({ weatherCode: this.currentWeather.current.weather_code,
              isDay: this.currentWeather.current.is_day !== 0 })
              .width(48).height(48)
          }
          if (Number.isFinite(this.currentWeather.current.temperature_2m)) {
            Row({ space: 3 }) {
              TemperatureIcon({ temp: this.currentWeather.current.temperature_2m }).width(14).height(24)
              Text(`${this.currentWeather.current.temperature_2m}${this.currentWeather.current_units?.temperature_2m || '°C'}`)
                .id(`history-temperature-${this.city.place_id}`)
                .fontSize(14).fontColor(Color.White)
                .textShadow({ color: '#66000000', offsetX: 0, offsetY: 1, radius: 3 })
            }
          }
        }.id(`history-weather-${this.city.place_id}`).width(72).margin({ left: 8 })
      }
    }
    .backgroundColor(0x4D102A43)
    .borderRadius(20)
    .shadow({ radius: 8, color: '#24182431', offsetX: 0, offsetY: 4 })
    .padding(16)
    .margin({top: 16})
    .width("100%")
    .transition(this.effect)

  }
}
