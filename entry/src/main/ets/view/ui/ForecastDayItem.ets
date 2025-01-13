import { getDayOfWeek } from '../../common/Tools';
import { WeatherIcon } from './WeatherIcon';

@Component
export struct ForecastDayItem {

  @Prop date: number;
  @Prop precipitationProbability: number;
  @Prop weatherCode: number;
  @Prop maxTemp: number;
  @Prop minTemp: number;
  @Prop isDay: boolean;
  @Prop tempUnit: string;

  build() {
    Row() {

      Text(`${getDayOfWeek(this.date)}`)
        .fontSize(15)
        .fontColor(Color.White)
        .fontWeight(FontWeight.Bold)
        .textShadow({
          color: '#88000000',
          offsetX: 2,
          offsetY: 2,
          radius: 2
        })
        .width("35%");

      Image($r('app.media.ic_small_rain')).height(16).margin({right: 2});

      Text(`${this.precipitationProbability}%`)
        .fontColor(Color.White)
        .fontSize(12)
        .width("12%")
        .textAlign(TextAlign.Start)

      WeatherIcon({
        weatherCode: this.weatherCode,
        isDay: this.isDay
      }).width(40)
        .height(40)
        .margin({ right: 6 })
        .align(Alignment.End)

      Row() {
        Text(`${this.maxTemp}`)
          .textAlign(TextAlign.End)
          .fontColor(Color.White)
          .fontSize(12);

        Text(`${this.tempUnit}`)
          .fontColor(Color.White)
          .fontSize(8)
          .margin({top: -2, left: 2})

      }.justifyContent(FlexAlign.Center)
      .width("15%")

      Row() {
        Text(`${this.minTemp}`)
          .fontColor('#FFC8C8C8')
          .fontSize(12);

        Text(`${this.tempUnit}`)
          .fontColor('#FFC8C8C8')
          .fontSize(8)
          .margin({top: -2, left: 2})

      }.justifyContent(FlexAlign.Center)
      .width("15%")

    }.width("100%").alignItems(VerticalAlign.Center).height(40)

  }
}