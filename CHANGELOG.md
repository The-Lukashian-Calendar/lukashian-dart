## 1.0.0

- Initial release of the Dart implementation of The Lukashian Calendar.
- Core types: `Year`, `Day`, `Instant`, `Formatter`, `DayFormat`,
  `LukashianException`, `CalendarObject`.
- `MillisecondStore` and `MillisecondStoreData` with pluggable
  `MillisecondStoreDataProvider`s.
- Standard Earth and Mars HTTP providers (`lukashian.org`), plus generic HTTP and
  file providers.
- Calendar keys: `earth`, `earthHttpLukashianOrg`, `mars`,
  `marsHttpLukashianOrg`. Computed Earth/Mars providers are stubs; use the HTTP
  or file providers to load official data.
- Differences from the Java reference are documented in `README.md` under
  "Deviations from the Java reference implementation".
