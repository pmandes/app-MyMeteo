import CategoryViewModel from '../../viewmodel/CategoryViewModel';
import { City } from '../../model/WeatherModel';


@Component
export struct MapComponent {

  @Prop city: City;

  build() {

    Column({ space: 10 }) {
      Image(CategoryViewModel.getMapImage(this.city))
        //.alt($r('app.media.LoadingProgress'))// Use alt to set a placeholder image displayed during image loading.
        .width(375)
        .height(300)
        .syncLoad(true)
        .onComplete(msg => {
          console.info('load image complete')
        })
        .onError(() => {
          console.info('load image fail')
        })

      TextArea({
        text: CategoryViewModel.getMapImageUrl(this.city)
      }).width("100%");

    }.backgroundColor(Color.White)

  }
}