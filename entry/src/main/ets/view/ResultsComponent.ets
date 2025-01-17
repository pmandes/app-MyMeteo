import { City, CurrentWeather, Forecast } from '../model/WeatherModel';
import { ViewState } from '../pages/Index';
import CategoryViewModel from '../viewmodel/CategoryViewModel';
import { CityInfoItem } from './ui/CityInfoItem';

@Component
export struct ResultsComponent {
  @Link results: City[];
  @Link selectedCity: City | null;
  @Link currentWeather: CurrentWeather | null;
  @Link forecast: Forecast | null;
  @Link viewState: ViewState;

  build() {

    if (!this.results || this.results.length === 0) {

      Flex({
        alignItems: ItemAlign.Center,
        justifyContent: FlexAlign.Center
      }) {
        Text("No results...")
          .fontColor(Color.White)
          .textShadow({
            color: '#000000',
            offsetX: 2,
            offsetY: 2,
            radius: 2
          })
      }
      .flexGrow(1)

    } else {

      List() {
        ForEach(this.results, (item: City) => {

          ListItem() {

            CityInfoItem({ city: item })

          }.onClick(event => this.handleOnClick(item))

        })
      }.height("90%").scrollBar(BarState.Off)
    }
  }

  handleOnClick(city: City) {

    this.selectedCity = city;
    const weatherData = CategoryViewModel.getWeatherData(city);

    weatherData.then(data => {
      this.currentWeather = data.currentWeather;
      this.forecast = data.forecast;
      this.viewState = ViewState.SHOW_CITY
    });
  }
}