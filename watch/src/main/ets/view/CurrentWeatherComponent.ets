import { TemperatureIcon } from './ui/TemperatureIcon';
import { WeatherIcon } from './ui/WeatherIcon';
import { CoordinateType, toDMS } from '@mymeteo/common';
import { City, CurrentWeather } from '@mymeteo/data';

@Component
@Preview
export struct CurrentWeatherComponent {

  @Prop city: City
  @Prop currentWeather: CurrentWeather

  build() {

    Column() {

      Text(`${this.city?.name}`)
        .width('100%').textAlign(TextAlign.Center).maxLines(1).textOverflow({ overflow: TextOverflow.Ellipsis })
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontColor(Color.White)
        .textShadow({ color: '#33182431', offsetX: 0, offsetY: 1, radius: 3 })

      Row() {

        Image($r('app.media.ic_location_pointer'))
          .fillColor(Color.White)
          .width(8)
          .height(8)
          .margin({ right: 4 });

        Text(toDMS(this.city?.lat, CoordinateType.LATITUDE) + ", "
          + toDMS(this.city?.lon, CoordinateType.LONGITUDE))
          .fontSize(8)
          .fontColor(Color.White)
          .textShadow({ color: '#33182431', offsetX: 0, offsetY: 1, radius: 3 })

      }.width("100%").justifyContent(FlexAlign.Center).padding({ top: 6, bottom: 6 })

      if (this.currentWeather) {

        Row() {

          // LEFT COLUMN

          Column() {

            Row() {
              Image($r('app.media.ic_small_wind')).width(16).margin({ right: 4 });
              Text($r('app.string.wind')).fontColor(Color.White).fontSize(10).fontWeight(FontWeight.Bold)
            }.margin({ bottom: 2 })

            Text($r('app.string.wind_speed_10m', `${this.currentWeather?.current?.wind_speed_10m} ${this.currentWeather?.current_units?.wind_speed_10m}`))
              .fontColor(Color.White)
              .fontSize(8)
              .margin({ left: 21 })

            Text($r('app.string.wind_direction_10m',
              `${this.currentWeather?.current?.wind_direction_10m}${this.currentWeather?.current_units?.wind_direction_10m}`))
              .fontColor(Color.White)
              .fontSize(8)
              .margin({ left: 21 })

            Text($r('app.string.wind_gusts_10m', `${this.currentWeather?.current?.wind_gusts_10m} ${this.currentWeather?.current_units?.wind_gusts_10m}`))
              .fontColor(Color.White)
              .fontSize(8)
              .margin({ left: 21 })

            Row() {
              Image($r('app.media.ic_small_pressure')).width(16).margin({ right: 4 })
              Text($r('app.string.pressure')).fontColor(Color.White).fontSize(10).fontWeight(FontWeight.Bold)
            }.margin({ top: 8, bottom: 2 })

            Text(`${this.currentWeather?.current?.surface_pressure} ${this.currentWeather?.current_units?.surface_pressure}`)
              .fontColor(Color.White)
              .fontSize(8)
              .margin({ left: 21 })

            Row() {
              Image($r('app.media.ic_small_humidity')).width(16).margin({ right: 4 })
              Text($r('app.string.humidity')).fontColor(Color.White).fontSize(10).fontWeight(FontWeight.Bold)
            }.margin({ top: 8, bottom: 2 })

            Text($r('app.string.relative_humidity_2m',
              `${this.currentWeather?.current?.relative_humidity_2m}${this.currentWeather?.current_units?.relative_humidity_2m}`))
              .fontColor(Color.White)
              .fontSize(8)
              .margin({ left: 21 })

          }.width("60%").alignItems(HorizontalAlign.Start)
          //.backgroundColor(Color.Red)

          // RIGHT COLUMN

          Column() {

            WeatherIcon({
              weatherCode: this.currentWeather?.current?.weather_code,
              isDay: this.currentWeather?.current?.is_day === 1 ? true : false
            }).width("100%").height(80)
              //.borderColor(Color.Black).borderWidth(2)

            Row() {

              TemperatureIcon({
                temp: this.currentWeather?.current?.temperature_2m
              }).width(16).height(32);

              Text(`${this.currentWeather?.current?.temperature_2m}`)
                .fontSize(18)
                .fontColor(Color.White)
                .textShadow({ color: '#33182431', offsetX: 0, offsetY: 1, radius: 3 })

              Text(`${this.currentWeather?.current_units?.temperature_2m}`)
                .fontSize(8)
                .fontColor(Color.White)
                .textShadow({ color: '#33182431', offsetX: 0, offsetY: 1, radius: 3 }).margin({ top: -10, left: 3 })
            }

          }.width("40%").alignItems(HorizontalAlign.Center)
          //.backgroundColor(Color.Green)

        }.width("100%").alignItems(VerticalAlign.Top)
        //.backgroundColor(Color.Blue)

      } else {
        Text($r('app.string.no_weather_data'))
          .fontColor(Color.White)
          .fontSize(8)
          .margin({ top: 16, left: 4 })
      }

      //Text(JSON.stringify(this.currentWeather)).fontSize(8).fontColor(Color.Gray);
    }
    .alignItems(HorizontalAlign.Start)
    //.borderRadius(50)
    //.backgroundColor(0x22000000)
    //.shadow(ShadowStyle.OUTER_DEFAULT_SM)
    .padding({ top: 32, bottom: 32, left: 36, right: 36 })
    .width("100%").height("100%")
  }
}
