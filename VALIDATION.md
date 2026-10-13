# Wearable PoC and shared core review

## Scope

The existing wearable PoC is completed without adding a new weather feature.
The mobile product remains `default`; the wearable product is `watch`.
Both products use API 23 for compilation/targeting and API 20 as their minimum.

## Review findings addressed

- Replaced global repository lookup at module-load time with explicit injection before UI startup.
- Removed GPS calls from ability initialization; the wearable page requests permissions first.
- Permission denial returns a result to the UI instead of terminating the ability.
- GPS, reverse-geocoding, network and missing-data errors remain visible with the existing flow available for retry.
- Normalized Nominatim's string coordinates and validated city/weather responses.
- Restored the documented 15-minute cache lifetime and stale-cache fallback when refresh fails.
- Removed the unused, unimplemented location method from the database datasource interface.
- Preserved `is_day` and `weather_code` when writing the weather cache.
- Derived weather display values from current props rather than retaining the first prop snapshot.
- Released HTTP resources on success and all failure paths; added 10-second connection/read timeouts.
- Closed RDB result sets even when row mapping throws.
- Corrected the database context import and removed the duplicate wearable float resource.
- Isolated the wearable HAP from the mobile build through product/module mappings.

## Verification

- [GitHub Actions verification of the merge](https://github.com/pmandes/app-MyMeteo/actions/runs/38399555081) passed core tests and both product builds, producing signed mobile and watch HAP artifacts.
- 19 host regression tests pass against production core classes with substituted platform APIs.
- Both signed HAPs build using SDK 6.1.0.32 (API 23). Their packaged metadata declares `minAPIVersion: 20` and `targetAPIVersion: 23`.
- Deployment and ability startup succeeded on the existing API 20 emulators: Pura 80 Pro and Huawei_Wearable.
- Mobile city search returned Warszawa; selecting it loaded the forecast.
- Wearable permission denial leaves the application open with a readable error and Retry.
- Granting foreground location access successfully obtained the device location and weather.
- Emulator checks caught ArkUI dropping custom getters from component output. Both weather views now read directly from their current `@Prop` data; emulator display verification confirms numeric temperature, wind, pressure, humidity and units in both products.
- Mobile weather and forecast panels use a darker translucent blue background and a bounded soft shadow; the full-width scroll content reserves side insets for the blur.
- Softened text shadows with a translucent dark blue, no horizontal offset and a small blur in both UIs.
- Replaced the green mobile and red wearable startup backgrounds with light blue colors matching their existing UIs.
- Emulator 6.1 does not support the CLI geolocation injection command; the existing device location was used.

## Limits

This is a foreground PoC. Wearable cold start requires device location and a network
connection for reverse geocoding. There is no background update service or phone/watch
synchronization. Development HAPs are for local testing, not store distribution.
