import { City, CurrentWeather } from '@mymeteo/data';
import { ViewState } from '../pages/Index';
import { CityInfoItem } from './ui/CityInfoItem';
import { SavedCityWeather } from '../viewmodel/WeatherViewModel';

@Component
export struct ResultsComponent {
  @Prop results: City[];
  @Prop savedCities: City[];
  @Prop savedCityWeather: SavedCityWeather[] = [];
  @Prop viewState: ViewState;
  @Prop historyBusy: boolean = false;
  onCitySelect: (city: City) => void = () => {};
  onDeleteCity: (city: City) => void = () => {};

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
              }.onClick(() => this.onCitySelect(item))
            })
          }.width('100%')
        }
      }

      if (this.viewState == ViewState.IDLE) {
        if (this.savedCities.length > 0) {
          Column() {
            ForEach(this.savedCities, (item: City) => {
              Column() {
                CityInfoItem({ city: item, currentWeather: this.cachedWeather(item) })
              }
              .id(`history-city-${item.place_id}`)
              .enabled(!this.historyBusy)
              .gesture(GestureGroup(GestureMode.Exclusive,
                LongPressGesture({ repeat: false, duration: 600 })
                  .onAction(() => this.confirmDelete(item)),
                TapGesture().onAction(() => this.onCitySelect(item))
              ))
            }, (item: City) => String(item.place_id))
          }.width('100%')
        }
      }
    }.width('100%').padding({ left: 12, right: 12, bottom: 12 })
  }

  cachedWeather(city: City): CurrentWeather | null {
    return this.savedCityWeather.find((saved: SavedCityWeather) => saved.cityId === city.place_id)?.currentWeather ?? null;
  }

  confirmDelete(city: City): void {
    if (this.historyBusy || this.viewState !== ViewState.IDLE) { return; }
    this.getUIContext().showAlertDialog({
      title: 'Delete?',
      message: `Remove ${city.name || city.display_name || 'this city'} from saved cities?`,
      primaryButton: { value: 'Cancel', defaultFocus: true, action: () => {} },
      secondaryButton: { value: 'Delete', fontColor: '#C84040', action: () => this.onDeleteCity(city) }
    });
  }
}
