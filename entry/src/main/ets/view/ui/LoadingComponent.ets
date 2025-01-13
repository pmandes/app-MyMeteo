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
          .textShadow({
            color: '#000000',
            offsetX: 2,
            offsetY: 2,
            radius: 2
          })
          .margin({bottom: 8})

        LoadingProgress()
          .color(Color.White)
          .height(128)
      }
    }
    .flexGrow(1)
  }
}