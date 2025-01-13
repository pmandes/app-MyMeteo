import { CommonConstants } from '../common/constants/CommonConstants';
import CategoryViewModel from '../viewmodel/CategoryViewModel';
import { City } from '../model/WeatherModel';
import { ViewState } from '../pages/CategoryPage';

@Component
export struct SearchBarComponent {

  @Link cities: City[];
  @Link viewState: ViewState;

  build() {

    Column() {

      Search({ placeholder: CommonConstants.SEARCH_PLACEHOLDER })
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
        .onSubmit((value: string) => {

          this.viewState = ViewState.LOADING
          const result = CategoryViewModel.searchCity(value)

          result.then(cities => {
            this.cities = (cities || [])
            this.viewState = ViewState.SHOW_RESULTS
          })
        })
    }
  }
}