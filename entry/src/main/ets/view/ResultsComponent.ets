import hilog from '@ohos.hilog';

import { City, CurrentWeather, Forecast } from '../model/WeatherModel';
import { ViewState } from '../pages/CategoryPage';
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

          }.onClick(event => {

            const cw = CategoryViewModel.getCurrentWeather(item)
            const f = CategoryViewModel.getForecast(item)

            this.selectedCity = item;

            cw.then(currentWeather => {
              this.currentWeather = currentWeather;
            });

            f.then(forecast => {
              this.forecast = forecast;
              this.viewState = ViewState.SHOW_CITY
            });
          })
        })
      }.height("90%").scrollBar(BarState.Off)
    }
  }
}