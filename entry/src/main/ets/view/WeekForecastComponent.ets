import { ForecastDayItem } from './ui/ForecastDayItem';
import { Forecast } from '@mymeteo/data';

@Component
export struct WeekForecastComponent {
  @Prop forecast: Forecast

  build() {

    Column() {

      if (this.forecast != null) {

        List() {
          ForEach(this.forecast?.daily?.time, (date: number, index: number) => {

            ListItem() {

              ForecastDayItem({
                date: date,
                precipitationProbability: this.forecast?.daily?.precipitation_probability_max?.[index] ?? 0,
                weatherCode: this.forecast?.daily?.weather_code?.[index] ?? 0,
                maxTemp: this.forecast?.daily?.temperature_2m_max?.[index] ?? 0,
                minTemp: this.forecast?.daily?.temperature_2m_min?.[index] ?? 0,
                isDay: true,
                tempUnit: this.forecast?.daily_units?.temperature_2m_max ?? "-"
              })

            }.width("100%")
          })
        }.width("100%")
      }
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