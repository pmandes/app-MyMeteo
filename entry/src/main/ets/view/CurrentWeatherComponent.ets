import { TemperatureIcon } from './ui/TemperatureIcon';
import { WeatherIcon } from './ui/WeatherIcon';
import { CoordinateType, toDMS } from '@mymeteo/common';
import { City, CurrentWeather } from '@mymeteo/data';

@Component
export struct CurrentWeatherComponent {
  @Prop city: City
  @Prop currentWeather: CurrentWeather
  build() {

    Column() {

      Text(`${this.city?.name}`)
        .fontSize(28)
        .fontWeight(FontWeight.Bold)
        .fontColor(Color.White)
        .textShadow({ color: '#33182431', offsetX: 0, offsetY: 1, radius: 3 })

      Row() {
        Image($r('app.media.ic_location_pointer'))
          .fillColor(Color.White)
          .width(16)
          .height(16)
          .margin({ right: 4 });

        Text(toDMS(this.city?.lat, CoordinateType.LATITUDE) + ", "
          + toDMS(this.city?.lon, CoordinateType.LONGITUDE))
          .fontSize(12)
          .fontColor(Color.White)
          .textShadow({ color: '#33182431', offsetX: 0, offsetY: 1, radius: 3 })
      }.padding({ top: 6, bottom: 6 })

      if (this.currentWeather) {

        Row() {
          Column() {

            Row() {
              Image($r('app.media.ic_small_wind')).width(16).margin({ right: 4 });
              Text($r('app.string.wind')).fontColor(Color.White).fontSize(14).fontWeight(FontWeight.Bold)
            }.margin({ bottom: 2 })

            Text($r('app.string.wind_speed_10m', `${this.currentWeather?.current?.wind_speed_10m} ${this.currentWeather?.current_units?.wind_speed_10m}`))
              .fontColor(Color.White)
              .fontSize(12)
              .margin({ left: 21 })
            Text($r('app.string.wind_direction_10m', `${this.currentWeather?.current?.wind_direction_10m}${this.currentWeather?.current_units?.wind_direction_10m}`))
              .fontColor(Color.White)
              .fontSize(12)
              .margin({ left: 21 })
            Text($r('app.string.wind_gusts_10m', `${this.currentWeather?.current?.wind_gusts_10m} ${this.currentWeather?.current_units?.wind_gusts_10m}`))
              .fontColor(Color.White)
              .fontSize(12)
              .margin({ left: 21 })

            Row() {
              Image($r('app.media.ic_small_pressure')).width(16).margin({ right: 4 })
              Text($r('app.string.pressure')).fontColor(Color.White).fontSize(14).fontWeight(FontWeight.Bold)
            }.margin({ top: 8, bottom: 2 })

            Text(`${this.currentWeather?.current?.surface_pressure} ${this.currentWeather?.current_units?.surface_pressure}`)
              .fontColor(Color.White)
              .fontSize(12)
              .margin({ left: 21 })

            Row() {
              Image($r('app.media.ic_small_humidity')).width(16).margin({ right: 4 })
              Text($r('app.string.humidity')).fontColor(Color.White).fontSize(14).fontWeight(FontWeight.Bold)
            }.margin({ top: 8, bottom: 2 })

            Text($r('app.string.relative_humidity_2m', `${this.currentWeather?.current?.relative_humidity_2m}${this.currentWeather?.current_units?.relative_humidity_2m}`))
              .fontColor(Color.White)
              .fontSize(12)
              .margin({ left: 21 })

          }.width("50%")
          .alignItems(HorizontalAlign.Start)
          .margin({ top: 8 })

          Column() {
            WeatherIcon({
              weatherCode: this.currentWeather?.current?.weather_code,
              isDay: this.currentWeather?.current?.is_day === 1 ? true : false
            }).width(128).height(128)

            Row() {
              TemperatureIcon({
                temp: this.currentWeather?.current?.temperature_2m
              }).width(32);

              Text(`${this.currentWeather?.current?.temperature_2m}`)
                .fontSize(36)
                .fontColor(Color.White)
                .textShadow({ color: '#33182431', offsetX: 0, offsetY: 1, radius: 3 })

              Text(`${this.currentWeather?.current_units?.temperature_2m}`)
                .fontSize(16)
                .fontColor(Color.White)
                .textShadow({ color: '#33182431', offsetX: 0, offsetY: 1, radius: 3 }).margin({ top: -13, left: 3 })
            }

          }.width("50%").alignItems(HorizontalAlign.Center)
        }.width("100%")

      } else {
        Text($r('app.string.no_weather_data'))
          .fontColor(Color.White)
          .fontSize(12)
          .margin({top: 16, left: 4})
      }

      //Text(JSON.stringify(this.currentWeather)).fontSize(8).fontColor(Color.Gray);
    }
    .alignItems(HorizontalAlign.Start)
    .borderRadius(20)
    .backgroundColor(0x4D102A43)
    .shadow({ radius: 8, color: '#24182431', offsetX: 0, offsetY: 4 })
    .padding(16)
    .width("100%")
    .margin({
      top: 16
    })
  }
}
