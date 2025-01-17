import { CommonConstants } from '../common/constants/CommonConstants';
import CategoryViewModel from '../viewmodel/CategoryViewModel';
import { City } from '../model/WeatherModel';
import { ViewState } from '../pages/Index';
import { AppError } from '../common/AppError';

@Component
export struct SearchBarComponent {

  private static readonly SEARCH_DELAY_MS: number = 500;

  @Link cities: City[]
  @Link viewState: ViewState
  @Link error: AppError
  @State submitValue: string = ''
  @State changeValue: string = ''
  controller: SearchController = new SearchController()
  lastSearchTime: number = 0
  searchTimeout: number = 0

  build() {

    Column() {

      Search({ value: this.changeValue, placeholder: CommonConstants.SEARCH_PLACEHOLDER, controller: this.controller })
        .enableKeyboardOnFocus(true)
        .height($r('app.float.search_height'))
        .border({ radius: $r('app.float.search_radius') })
        .shadow(ShadowStyle.OUTER_DEFAULT_SM)
        .backgroundColor(0xFFFFFF)
        .placeholderFont({
          size: $r('app.float.search_text_size'),
          weight: CommonConstants.SEARCH_WEIGHT,
          family: CommonConstants.SEARCH_FONT_FAMILY,
          style: FontStyle.Normal
        })
        .textFont({ size: $r('app.float.search_text_size') })
        .placeholderColor($r('app.color.search_placeholder'))
        .margin({
          top: $r('app.float.search_margin_top'),
          bottom: $r('app.float.search_margin_bottom')
        })
        .onChange((value: string) => this.handleOnChange(value))
        .onSubmit((value: string) => this.handleOnSubmit(value))
    }
  }

  handleOnChange(value: string): void {
    this.changeValue = value;

    if (value.trim().length < 3) {
      return;
    }

    const currentTime = Date.now();
    if (currentTime - this.lastSearchTime < SearchBarComponent.SEARCH_DELAY_MS) {
      clearTimeout(this.searchTimeout);
      this.searchTimeout = setTimeout(() => this.handleOnSubmit(value), SearchBarComponent.SEARCH_DELAY_MS);

    } else {
      this.handleOnSubmit(value);
    }

    this.lastSearchTime = currentTime;
  }

  handleOnSubmit(value: string): void {

    if (value.trim() === '') {
      return
    }

    console.debug('onSubmit: ', value);

    this.submitValue = value;
    this.viewState = ViewState.LOADING;

    CategoryViewModel.searchCity(value)
      .then(cities => {

        console.info('Cities: ', JSON.stringify(cities));

        this.cities = cities || [];

        if (this.cities.length === 0) {
          this.viewState = ViewState.IDLE;
        } else {
          this.viewState = ViewState.SHOW_RESULTS;
        }
      })
      .catch((error: AppError) => {

        console.error('Search city error:', error);

        this.error = error;
        this.viewState = ViewState.ERROR;
      });
  }
}