import { AppError } from '../../common/AppError';

@Component
export struct ErrorComponent {

  @Prop error: AppError;

  build() {

    Flex({
      alignItems: ItemAlign.Center,
      justifyContent: FlexAlign.Center
    }) {

      Column() {

        Text("Error:")
          .fontColor('#fff87171')
          .fontSize(18)
          .margin({bottom: 8})

        Text(this.error?.msg)
          .fontSize(14)
          .fontColor('#fff87171')

      }.padding(16)
      .backgroundColor('#aaffffff')
      .border({ radius: $r('app.float.error_box_radius') })
      .shadow(ShadowStyle.OUTER_DEFAULT_SM)
      .alignItems(HorizontalAlign.Start)
    }
    .flexGrow(1)
  }
}