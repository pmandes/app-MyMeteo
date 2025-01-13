import { i18n } from '@kit.LocalizationKit';

export function getDayOfWeek(unixTimestamp: number): string {
  const locale = i18n.System.getSystemLocale()
  const date = new Date(unixTimestamp * 1000);
  return new Intl.DateTimeFormat(locale, { weekday: 'long' }).format(date);
}