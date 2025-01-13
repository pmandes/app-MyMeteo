
export function inRange(value: number, min: number, max: number): boolean {
  return value >= min && value <= max;
};

@Component
export struct TemperatureIcon {

  @Prop temp?: number;

  build() {

    Column() {

      if (this.temp != null) {

        if (this.temp < -10) {
          Image($r('app.media.ic_temp_cold_3'))
        } else if (inRange(this.temp, -10, -5)) {
          Image($r('app.media.ic_temp_cold_2'))
        } else if (inRange(this.temp, -5, 0)) {
          Image($r('app.media.ic_temp_cold_1'))
        } else if (inRange(this.temp, 0, 15)) {
          Image($r('app.media.ic_temp_hot_1'))
        } else if (inRange(this.temp, 15, 30)) {
          Image($r('app.media.ic_temp_hot_2'))
        } else {
          Image($r('app.media.ic_temp_hot_3'))
        }
      }
    }
  }
}

