import { AppError, City, CurrentWeather, Forecast } from '@mymeteo/data';
import { ViewState } from '../pages/Index';
import { weatherViewModel } from '../viewmodel/WeatherViewModel';
import { CityInfoItem } from './ui/CityInfoItem';
import { formatWeatherUpdate } from '../common/WeatherTime';

@Component
export struct ResultsComponent {
  @Link results: City[];
  @Link selectedCity: City | null;
  @Link savedCities: City[];
  @Link currentWeather: CurrentWeather | null;
  @Link forecast: Forecast | null;
  @Link viewState: ViewState;
  @Link error: AppError;
  @Link updatedAt: string;

  build() {

    Column() {

      if (this.viewState == ViewState.SHOW_RESULTS) {
        if (!this.results || this.results.length === 0) {
          Flex({
            alignItems: ItemAlign.Center,
            justifyContent: FlexAlign.Center
          }) {
            Text("No results...")
              .fontColor(Color.White)
              .textShadow({ color: '#33182431', offsetX: 0, offsetY: 1, radius: 3 })
          }
          .flexGrow(1)

        } else {

          Column() {
            ForEach(this.results, (item: City) => {
              Column() {
                CityInfoItem({ city: item })
              }.onClick(event => this.handleOnClick(item))
            })
          }.width('100%')
        }
      }

      if (this.viewState == ViewState.IDLE) {
        if (this.savedCities.length > 0) {
          Text("Search history:")
            .fontColor(Color.White)
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .textShadow({ color: '#33182431', offsetX: 0, offsetY: 1, radius: 3 })
            .alignSelf(ItemAlign.Start)
            .margin({top: 16})

          Column() {
            ForEach(this.savedCities, (item: City) => {
              Column() {
                CityInfoItem({ city: item })
              }.onClick(event => this.handleOnClick(item))
            })
          }.width('100%')
        }
      }
    }.width('100%').padding({ left: 12, right: 12, bottom: 12 })
  }

  async handleOnClick(city: City): Promise<void> {
    this.selectedCity = city;
    this.viewState = ViewState.LOADING;
    try {
      const data = await weatherViewModel.getWeatherData(city);
      this.currentWeather = data.currentWeather;
      this.forecast = data.forecast;
      this.updatedAt = formatWeatherUpdate(data.lastUpdated);
      this.viewState = ViewState.SHOW_CITY;
    } catch (error) {
      this.error = error instanceof AppError ? error : new AppError(1001, 'Unable to load weather.');
      this.viewState = ViewState.ERROR;
    }
  }
}
