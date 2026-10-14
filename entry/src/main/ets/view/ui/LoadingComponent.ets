@Component
export struct LoadingComponent {
  build() {

    Flex({
      alignItems: ItemAlign.Center,
      justifyContent: FlexAlign.Center
    }) {

      Column() {

        Text("Retrieving data...")
          .fontColor(Color.White)
          .textShadow({ color: '#33182431', offsetX: 0, offsetY: 1, radius: 3 })
          .margin({bottom: 8})

        LoadingProgress()
          .color(Color.White)
          .height(128)
      }
    }
    .width('100%')
    .height('100%')
  }
}