
@Component
export struct WeatherIcon {

  @Prop weatherCode: number;
  @Prop isDay: boolean = true;

  build() {

    Flex() {

      if (this.weatherCode != null) {

        if (this.isDay) {

          if (this.weatherCode === 0) {
            Image($r('app.media.ic_day_clear')).objectFit(ImageFit.ScaleDown);
          } else if (this.weatherCode === 1) {
            Image($r('app.media.ic_day_clouds1')).objectFit(ImageFit.ScaleDown);
          } else if (this.weatherCode === 2) {
            Image($r('app.media.ic_day_clouds2')).objectFit(ImageFit.ScaleDown);
          } else if ([3, 45, 48].includes(this.weatherCode)) {
            Image($r('app.media.ic_clouds')).objectFit(ImageFit.ScaleDown);
          } else if ([51, 53, 55, 56, 57, 61, 63, 65, 71, 73, 75, 77].includes(this.weatherCode)) {
            Image($r('app.media.ic_day_rain')).objectFit(ImageFit.ScaleDown);
          } else if ([80, 81, 82, 85, 86].includes(this.weatherCode)) {
            Image($r('app.media.ic_rain')).objectFit(ImageFit.ScaleDown);
          } else if ([95].includes(this.weatherCode)) {
            Image($r('app.media.ic_thunderstorm')).objectFit(ImageFit.ScaleDown);
          } else if ([96, 99].includes(this.weatherCode)) {
            Image($r('app.media.ic_rain_thunderstorm')).objectFit(ImageFit.ScaleDown);
          } else {
            Image($r('app.media.ic_day_clouds1')).objectFit(ImageFit.ScaleDown); // default
          }

        } else {

          if (this.weatherCode === 0) {
            Image($r('app.media.ic_night_clear')).objectFit(ImageFit.ScaleDown);
          } else if (this.weatherCode === 1) {
            Image($r('app.media.ic_night_clouds1')).objectFit(ImageFit.ScaleDown);
          } else if (this.weatherCode === 2) {
            Image($r('app.media.ic_night_clouds2')).objectFit(ImageFit.ScaleDown);
          } else if ([3, 45, 48].includes(this.weatherCode)) {
            Image($r('app.media.ic_clouds')).objectFit(ImageFit.ScaleDown);
          } else if ([51, 53, 55, 56, 57, 61, 63, 65, 71, 73, 75, 77].includes(this.weatherCode)) {
            Image($r('app.media.ic_night_rain')).objectFit(ImageFit.ScaleDown);
          } else if ([80, 81, 82, 85, 86].includes(this.weatherCode)) {
            Image($r('app.media.ic_rain')).objectFit(ImageFit.ScaleDown);
          } else if ([95].includes(this.weatherCode)) {
            Image($r('app.media.ic_thunderstorm')).objectFit(ImageFit.ScaleDown);
          } else if ([96, 99].includes(this.weatherCode)) {
            Image($r('app.media.ic_rain_thunderstorm')).objectFit(ImageFit.ScaleDown);
          } else {
            Image($r('app.media.ic_night_clouds1')).objectFit(ImageFit.ScaleDown); // default
          }

          // Image($r('app.media.ic_night_fullmoon')).width(64);
        }
      }
    }.flexGrow(1)
    //.border({width: 1, color: Color.Red})
  }
}