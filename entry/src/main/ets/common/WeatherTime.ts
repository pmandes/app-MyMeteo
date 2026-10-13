import { i18n } from '@kit.LocalizationKit';

export function formatWeatherUpdate(date: Date | null): string {
  if (!date || !Number.isFinite(date.getTime())) {
    return '';
  }
  try {
    return new Intl.DateTimeFormat(i18n.System.getSystemLocale(), {
      year: 'numeric', month: '2-digit', day: '2-digit',
      hour: '2-digit', minute: '2-digit', second: '2-digit',
      timeZone: i18n.getTimeZone().getID()
    }).format(date);
  } catch (error) {
    return date.toISOString().replace('T', ' ').replace('Z', ' UTC');
  }
}
