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
- 44 host regression tests pass against production code with substituted platform APIs. Refresh checks cover bypassing a fresh cache, preserving cached and displayed weather/timestamps on failure, stopping the spinner, forwarding the mobile refresh flag, ignoring a late response after leaving the page, and formatting retrieval time in the device time zone.
- Mobile startup tests cover location permission denial/errors, successful location weather, GPS/geocoding/weather failures, selecting the latest usable saved weather, unreadable records, empty history, unavailable database and protection of manual search from a late location response.
- Background tests run the production handlers in both products and cover weather-code families, waiting for image readiness, the 2.4-second fade, keeping the previous background until completion, skipping fades within the same family and ignoring stale animation completion callbacks.
- Mobile startup opened current weather and forecast for the existing emulator's location (Covent Garden); the clear weather background rendered behind both cards. A refresh updated the retrieval time without restarting the background transition. A captured pull gesture confirmed the white spinner is visible below the search overlay.
- A Springfield search verified native text entry/submission, the compact 64vp search overlay, white 15vp query text with a soft shadow, and translucent result cards matching the weather panels. Both results and history use the same shared city item and reserve side space for its shadow.
- Spinner visibility is tied to active dragging/refreshing and cleared in `finally` after success or failure. Idle custom-header geometry can no longer leave an animated indicator below the search panel.
- The shared weather images also render on Huawei_Wearable, cropped to its viewport with a soft blue overlay for text contrast. Current location weather, units and the existing PoC flow remain intact.
- Wearable content reserves 36vp on each side and 32vp at the top/bottom. Build and deployment passed; the existing 466px Huawei_Wearable viewport displays the city, coordinates, all weather parameters, temperature and units without clipping.
- Volla X23 connected over USB reports API 23 (Release). The latest signed mobile HAP installed and launched without uninstalling or clearing data. On-device inspection confirmed current weather, the weekly forecast, the cloudy background, matching status/search glass and no idle refresh spinner. Further device interaction was interrupted when the USB connection disappeared; offline-refresh verification on Volla is pending reconnection.
- Both signed HAPs build using SDK 6.1.0.32 (API 23). Their packaged metadata declares `minAPIVersion: 20` and `targetAPIVersion: 23`.
- Deployment and ability startup succeeded on the existing API 20 emulators: Pura 80 Pro and Huawei_Wearable.
- Mobile city search returned Warszawa; selecting it loaded the forecast.
- Wearable permission denial leaves the application open with a readable error and Retry.
- Granting foreground location access successfully obtained the device location and weather.
- Emulator checks caught ArkUI dropping custom getters from component output. Both weather views now read directly from their current `@Prop` data; emulator display verification confirms numeric temperature, wind, pressure, humidity and units in both products.
- Mobile weather and forecast panels use a darker translucent blue background and a bounded soft shadow; the full-width scroll content reserves side insets for the blur.
- Mobile system bars overlay the gradient with glass panels; the scrollable content passes beneath them. A long Springfield search verified that the search panel collapses on upward scrolling and returns on downward scrolling, retaining the query.
- Pulling down on the Warszawa weather screen fetched data despite the fresh cache and changed the retrieval timestamp below the forecast. The timestamp follows the device locale and time zone.
- Softened text shadows with a translucent dark blue, no horizontal offset and a small blur in both UIs.
- Replaced the green mobile and red wearable startup backgrounds with light blue colors matching their existing UIs.
- Emulator 6.1 does not support the CLI geolocation injection command; the existing device location was used.

## Limits

This is a foreground PoC. Wearable cold start requires device location and a network
connection for reverse geocoding. There is no background update service or phone/watch
synchronization. Development HAPs are for local testing, not store distribution.
