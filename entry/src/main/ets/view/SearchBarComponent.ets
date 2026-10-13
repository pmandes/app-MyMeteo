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
  @State editing: boolean = false;
  onEditingChange: (editing: boolean) => void = () => {};
  onSearchStart: () => void = () => {};
  controller: SearchController = new SearchController();

  build() {
    Column() {
      Stack({ alignContent: Alignment.Start }) {
      Search({ value: this.changeValue, placeholder: CommonConstants.SEARCH_PLACEHOLDER, controller: this.controller })
        .id('city-search')
        .width('100%').height(46)
        .margin(0)
        .border({ radius: 18, width: 1, color: '#60FFFFFF' })
        .backgroundColor('#10FFFFFF')
        .placeholderFont({ size: 15, weight: FontWeight.Normal, family: 'sans-serif' })
        .textFont({ size: 15, weight: FontWeight.Normal, family: 'sans-serif' })
        .fontColor(this.editing ? Color.White : Color.Transparent)
        .placeholderColor(this.editing ? '#E6FFFFFF' : Color.Transparent)
        .caretStyle({ color: Color.White, width: 1.5 })
        .searchIcon({ size: 20, color: '#E6FFFFFF' })
        .cancelButton({ style: CancelButtonStyle.INPUT, icon: { size: 18, color: '#E6FFFFFF' } })
        .onChange((value: string) => { this.changeValue = value; })
        .onEditChange((editing: boolean) => { this.editing = editing; this.onEditingChange(editing); })
        .onSubmit((value: string) => this.handleOnSubmit(value))
        if (!this.editing) {
          // Search has no text-shadow API; decorate only its unfocused text.
          // The native field retains focus, editing, selection and accessibility.
          Text(this.changeValue || CommonConstants.SEARCH_PLACEHOLDER)
            .fontSize(15).fontWeight(FontWeight.Normal).fontFamily('sans-serif')
            .fontColor(this.changeValue ? Color.White : '#E6FFFFFF')
            .textShadow({ color: '#66182431', offsetX: 0, offsetY: 1, radius: 2 })
            .width('100%').padding({ left: 42, right: 40 })
            .maxLines(1).textOverflow({ overflow: TextOverflow.Ellipsis })
            .hitTestBehavior(HitTestMode.None).accessibilityLevel('no')
        }
      }.width('100%').height(46)
    }
    .width('100%').height(CommonConstants.SEARCH_PANEL_HEIGHT)
    .padding({ left: 12, right: 12, top: 9, bottom: 9 })
    .backgroundColor(CommonConstants.SEARCH_GLASS_COLOR)
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
    this.onSearchStart();
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
