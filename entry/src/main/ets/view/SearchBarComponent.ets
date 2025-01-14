import { CommonConstants } from '../common/constants/CommonConstants';
import CategoryViewModel from '../viewmodel/CategoryViewModel';
import { City } from '../model/WeatherModel';
import { ViewState } from '../pages/Index';
import hilog from '@ohos.hilog';

@Component
export struct SearchBarComponent {

  @Link cities: City[]
  @Link viewState: ViewState
  @State submitValue: string = ''
  @State changeValue: string = ''
  controller: SearchController = new SearchController()

  build() {

    Column() {

      Search({ value: this.changeValue, placeholder: CommonConstants.SEARCH_PLACEHOLDER, controller: this.controller })
        .enableKeyboardOnFocus(true)
        .searchButton('SEARCH')
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
        .onChange((value: string) => {

          hilog.info(0x0000, 'SearchBarComponent', '%{public}s %{public}s ', 'onChange: ', value);

          this.changeValue = value

        })
        .onSubmit((value: string) => {

          hilog.info(0x0000, 'SearchBarComponent', '%{public}s %{public}s ', 'onSubmit: ', value);

          this.submitValue = value

          this.viewState = ViewState.LOADING
          const result = CategoryViewModel.searchCity(value)

          result.then(cities => {
            console.error('then: ', JSON.stringify(cities))

            this.cities = (cities || [])

            if (this.cities.length == 0) {
              this.viewState = ViewState.IDLE
            } else {
              this.viewState = ViewState.SHOW_RESULTS
            }
          })
        })
    }
  }
}