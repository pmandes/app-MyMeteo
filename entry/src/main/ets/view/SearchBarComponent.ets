import { CommonConstants } from '../common/constants/CommonConstants';
import { weatherViewModel } from '../viewmodel/WeatherViewModel';
import { AppError, City } from '@mymeteo/data';
import { ViewState } from '../pages/Index';

@Component
export struct SearchBarComponent {
  @Link cities: City[];
  @Link viewState: ViewState;
  @Link error: AppError;
  @State changeValue: string = '';
  onEditingChange: (editing: boolean) => void = () => {};
  controller: SearchController = new SearchController();

  build() {
    Column() {
      Search({ value: this.changeValue, placeholder: CommonConstants.SEARCH_PLACEHOLDER, controller: this.controller })
        .id('city-search')
        .height(52)
        .margin(0)
        .border({ radius: 18, width: 1, color: '#60FFFFFF' })
        .backgroundColor('#24FFFFFF')
        .placeholderFont({ size: 17, weight: FontWeight.Normal, family: 'sans-serif' })
        .textFont({ size: 18, weight: FontWeight.Medium, family: 'sans-serif' })
        .fontColor('#182F48')
        .placeholderColor('#596D82')
        .searchIcon({ size: 21, color: '#405D78' })
        .onChange((value: string) => { this.changeValue = value; })
        .onEditChange((editing: boolean) => this.onEditingChange(editing))
        .onSubmit((value: string) => this.handleOnSubmit(value))
    }
    .width('100%').height(72).padding({ left: 12, right: 12, top: 10, bottom: 10 })
    .backgroundColor('#40FFFFFF')
    .backdropBlur(20)
    .border({ width: { bottom: 1 }, color: '#55FFFFFF' })
    .shadow({ radius: 8, color: '#18182431', offsetX: 0, offsetY: 3 })
  }

  handleOnSubmit(value: string): void {
    const query = value.trim();
    if (!query) {
      return;
    }
    this.getUIContext().getFocusController().clearFocus();
    this.onEditingChange(false);
    this.viewState = ViewState.LOADING;
    weatherViewModel.searchCity(query)
      .then(cities => {
        this.cities = cities || [];
        this.viewState = this.cities.length ? ViewState.SHOW_RESULTS : ViewState.IDLE;
      })
      .catch((error: AppError) => {
        this.error = error;
        this.viewState = ViewState.ERROR;
      });
  }
}
