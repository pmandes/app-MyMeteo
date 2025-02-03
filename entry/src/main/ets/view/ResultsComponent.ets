import { City, CurrentWeather, Forecast } from '@mymeteo/data';
import { ViewState } from '../pages/Index';
import { categoryViewModel } from '../viewmodel/CategoryViewModel';
import { CityInfoItem } from './ui/CityInfoItem';

@Component
export struct ResultsComponent {
  @Link results: City[];
  @Link selectedCity: City | null;
  @Link savedCities: City[];
  @Link currentWeather: CurrentWeather | null;
  @Link forecast: Forecast | null;
  @Link viewState: ViewState;

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
              .textShadow({ color: Color.White, offsetX: 2, offsetY: 2, radius: 2 })
          }
          .flexGrow(1)

        } else {

          List() {
            ForEach(this.results, (item: City) => {
              ListItem() {
                CityInfoItem({ city: item })
              }.onClick(event => this.handleOnClick(item))
            })
          }.height("89%").scrollBar(BarState.Off)
        }
      }

      if (this.viewState == ViewState.IDLE) {
        if (this.savedCities.length > 0) {
          Text("Search history:")
            .fontColor(Color.White)
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .textShadow({ color: Color.Black, offsetX: 1, offsetY: 1, radius: 1 })
            .alignSelf(ItemAlign.Start)
            .margin({top: 16})

          List() {
            ForEach(this.savedCities, (item: City) => {
              ListItem() {
                CityInfoItem({ city: item })
              }.onClick(event => this.handleOnClick(item))
            })
          }.height("89%").scrollBar(BarState.Off)
        }
      }
    }
  }

  handleOnClick(city: City) {

    this.selectedCity = city;
    const weatherData = categoryViewModel.getWeatherData(city);

    weatherData.then(data => {
      this.currentWeather = data.currentWeather;
      this.forecast = data.forecast;
      this.viewState = ViewState.SHOW_CITY
    });
  }
}