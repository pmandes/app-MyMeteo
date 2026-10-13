export enum WeatherBackground {
  NONE = '', CLEAR = 'clear', CLOUDY = 'cloudy', RAIN = 'rain', SNOW = 'snow'
}

export function backgroundForWeather(code?: number): WeatherBackground {
  if (code === 0 || code === 1) { return WeatherBackground.CLEAR; }
  if (code === 2 || code === 3 || code === 45 || code === 48) { return WeatherBackground.CLOUDY; }
  if ((code !== undefined && code >= 51 && code <= 67) ||
    (code !== undefined && code >= 80 && code <= 82) || code === 95 || code === 96 || code === 99) {
    return WeatherBackground.RAIN;
  }
  if ((code !== undefined && code >= 71 && code <= 77) || code === 85 || code === 86) {
    return WeatherBackground.SNOW;
  }
  return WeatherBackground.NONE;
}
