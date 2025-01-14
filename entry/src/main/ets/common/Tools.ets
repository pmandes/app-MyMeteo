import l18n  from '@ohos.i18n';

export function getDayOfWeek(unixTimestamp: number): string {
  const locale = l18n.System.getSystemLocale()
  const date = new Date(unixTimestamp * 1000);
  return new Intl.DateTimeFormat(locale, { weekday: 'long' }).format(date);
}