import { i18n } from '@kit.LocalizationKit';

const NOON_SECONDS = 12 * 3600;

/**
 * Weekday of an Open-Meteo daily timestamp, which marks midnight at the forecast location.
 * The location's wall clock is read in UTC, so the device time zone cannot shift the day.
 * Cached forecasts carry no offset: noon of the location day falls on the same UTC date
 * for every offset between -12 h and +12 h.
 */
export function getDayOfWeek(unixTimestamp: number, utcOffsetSeconds?: number): string {
  const locale = i18n.System.getSystemLocale()
  const shift = Number.isFinite(utcOffsetSeconds) ? utcOffsetSeconds as number : NOON_SECONDS;
  const date = new Date((unixTimestamp + shift) * 1000);
  return new Intl.DateTimeFormat(locale, { weekday: 'long', timeZone: 'UTC' }).format(date);
}
