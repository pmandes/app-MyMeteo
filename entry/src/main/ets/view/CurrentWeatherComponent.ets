import { TemperatureIcon } from './ui/TemperatureIcon';
import { WeatherIcon } from './ui/WeatherIcon';
import { CoordinateType, toDMS } from '../common/CoordinatesConverter';
import { City, CurrentWeather, Current, CurrentUnits, Forecast } from '../model/WeatherModel';

@Component
export struct CurrentWeatherComponent {
  @Prop city?: City
  @Prop currentWeather?: CurrentWeather
  current?: Current = this.currentWeather?.current;
  units?: CurrentUnits = this.currentWeather?.current_units;

  build() {

    Column() {

      Text(`${this.city?.name}`)
        .fontSize(28)
        .fontWeight(FontWeight.Bold)
        .fontColor(Color.White)
        .textShadow({
          color: '#88000000',
          offsetX: 3,
          offsetY: 3,
          radius: 5
        })

      Row() {
        Image($r('app.media.ic_location_pointer'))
          .fillColor(Color.White)
          .width(16)
          .height(16)
          .margin({right: 4});

        Text(toDMS(this.city?.lat, CoordinateType.LATITUDE) + ", "
          + toDMS(this.city?.lon, CoordinateType.LONGITUDE))
          .fontSize(12)
          .fontColor(Color.White)
          .textShadow({
            color: 0x88000000,
            offsetX: 1,
            offsetY: 1,
            radius: 1})
      }.padding({top: 6, bottom: 6})

      Row() {
        Column() {

          Row() {
            Image($r('app.media.ic_small_wind')).width(16).margin({right: 4});
            Text($r('app.string.wind')).fontColor(Color.White).fontSize(14).fontWeight(FontWeight.Bold)
          }.margin({bottom: 2})

          Text($r('app.string.wind_speed_10m', `${this.current?.wind_speed_10m} ${this.units?.wind_speed_10m}`)).fontColor(Color.White).fontSize(12).margin({left: 21})
          Text($r('app.string.wind_direction_10m', `${this.current?.wind_direction_10m}${this.units?.wind_direction_10m}`)).fontColor(Color.White).fontSize(12).margin({left: 21})
          Text($r('app.string.wind_gusts_10m', `${this.current?.wind_gusts_10m} ${this.units?.wind_gusts_10m}`)).fontColor(Color.White).fontSize(12).margin({left: 21})

          Row() {
            Image($r('app.media.ic_small_pressure')).width(16).margin({right: 4})
            Text($r('app.string.pressure')).fontColor(Color.White).fontSize(14).fontWeight(FontWeight.Bold)
          }.margin({top: 8, bottom: 2})

          Text(`${this.current?.surface_pressure} ${this.units?.surface_pressure}`).fontColor(Color.White).fontSize(12).margin({left: 21})

          Row() {
            Image($r('app.media.ic_small_humidity')).width(16).margin({right: 4})
            Text($r('app.string.humidity')).fontColor(Color.White).fontSize(14).fontWeight(FontWeight.Bold)
          }.margin({top: 8, bottom: 2})

          Text($r('app.string.relative_humidity_2m', `${this.current?.relative_humidity_2m}${this.units?.relative_humidity_2m}`)).fontColor(Color.White).fontSize(12).margin({left: 21})

        }.layoutWeight(0.5)
        .alignItems(HorizontalAlign.Start)
        .margin({top: 8})

        Column() {
          WeatherIcon({
            weatherCode: this.current?.weather_code,
            isDay: this.current?.is_day === 1 ? true : false
          }).width(128).height(128)

          Row() {
            TemperatureIcon({
              temp: this.current?.temperature_2m
            }).width(32);

            Text(`${this.current?.temperature_2m}`)
              .fontSize(36)
              .fontColor(Color.White)
              .textShadow({
                color: '#000000',
                offsetX: 2,
                offsetY: 2,
                radius: 2
              })

            Text(`${this.units?.temperature_2m}`)
              .fontSize(16)
              .fontColor(Color.White)
              .textShadow({
                color: '#000000',
                offsetX: 2,
                offsetY: 2,
                radius: 2
              }).margin({top: -13, left: 3})
          }

        }.layoutWeight(0.5).alignItems(HorizontalAlign.Center)

      }

      //Text(JSON.stringify(this.currentWeather)).fontSize(8).fontColor(Color.Gray);
    }
    .alignItems(HorizontalAlign.Start)
    .borderRadius(20)
    .backgroundColor(0x22000000)
    .shadow(ShadowStyle.OUTER_DEFAULT_SM)
    .padding(16)
    .width("95%")
    .margin({
      top: 16
    })
  }
}
