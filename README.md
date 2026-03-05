# lukashian

A Dart implementation of **The Lukashian Calendar** — a calendar that is exceptionally simple, highly accurate and radically different. It provides a universal mechanism for every planet, moon or space station we'll ever inhabit and is the calendar of choice for the upcoming Mars Settlement.

For more on the calendar itself, see [lukashian.org](https://www.lukashian.org).

## Features

- **Core types**: `Year`, `Day`, `LukashianInstant` (epoch-based, comparable, calendar-key aware)
- **Formatting**: `Formatter` and `DayFormat` for years, days, instants and time-of-day (e.g. beeps)
- **Multiple calendars**: Register and switch between Earth, Mars, or your own data via `MillisecondStore` and `MillisecondStoreDataProvider`
- **External data**: Load calendar data from files or HTTP (including official [lukashian.org](https://www.lukashian.org) endpoints) using `FileMillisecondStoreDataProvider`, `HttpMillisecondStoreDataProvider`, `StandardEarthHttpMillisecondStoreDataProvider`, and `StandardMarsHttpMillisecondStoreDataProvider`

## Getting started

Add the dependency:

```yaml
dependencies:
  lukashian: ^1.0.0
```

Then ensure a calendar is loaded before using the default calendar. For example, register an HTTP provider and call `ensureLoaded`:

```dart
import 'package:lukashian/lukashian.dart';

void main() async {
  final store = MillisecondStore.store();
  store.registerProvider(CalendarKeys.earthHttpLukashianOrg, StandardEarthHttpMillisecondStoreDataProvider());
  store.setDefaultCalendarKey(CalendarKeys.earthHttpLukashianOrg);
  await store.ensureLoaded(CalendarKeys.earthHttpLukashianOrg);

  final now = LukashianInstant.now();
  print(Formatter.formatInstant(now)); // e.g. "5919-43 3300"
}
```

## Usage

### Instants, days and years

```dart
// Current instant (uses default calendar)
final now = LukashianInstant.now();

// From epoch millisecond or day
final instant = LukashianInstant.ofEpoch(1_000_000);
final day = Day.ofEpoch(42);

// From year and day
final y = Year.of(5919);
final d = Day.of(y, 43);
final inst = LukashianInstant.ofYearDayBeepsKey(5919, 43, 3300);

// Arithmetic and comparison
final tomorrow = now.plusDays(1);
final inSameYear = now.getYear() == y;
```

### Formatting

```dart
Formatter.formatYear(Year.of(5919));           // "5919"
Formatter.formatDay(day, DayFormat.yearFirst); // "5919-43"
Formatter.formatInstant(now);                  // "5919-43 3300" (day + beeps)
Formatter.formatInstant(now, dayFormat: DayFormat.epoch, formatter: (f) => f.toString());
```

### Using different calendar instances

Use a specific calendar key when creating values, or set the default:

```dart
// Explicit key (e.g. Mars)
final onMars = LukashianInstant.now(CalendarKeys.marsHttpLukashianOrg);

// Set default so all future now() / of() use that calendar
MillisecondStore.store().setDefaultCalendarKey(CalendarKeys.marsHttpLukashianOrg);
await MillisecondStore.store().ensureLoaded(CalendarKeys.marsHttpLukashianOrg);
```

Calendar keys: `CalendarKeys.earth`, `CalendarKeys.earthHttpLukashianOrg`, `CalendarKeys.mars`, `CalendarKeys.marsHttpLukashianOrg`. The `earth` and `mars` keys are for computed providers (stubs in this port throw `UnimplementedError`); use the `*HttpLukashianOrg` providers to load from lukashian.org.

### Loading from files or HTTP

```dart
// Earth from lukashian.org
store.registerProvider(CalendarKeys.earthHttpLukashianOrg, StandardEarthHttpMillisecondStoreDataProvider());

// Mars from lukashian.org
store.registerProvider(CalendarKeys.marsHttpLukashianOrg, StandardMarsHttpMillisecondStoreDataProvider());

// Custom URL or local directory (base must end with / or path separator)
store.registerProvider(99, HttpMillisecondStoreDataProvider.withDefaults('https://example.com/calendar/'));
store.registerProvider(98, FileMillisecondStoreDataProvider.withDefaults('/path/to/calendar/'));
await store.ensureLoaded(99);
```

Binary format: 8 bytes per value, big-endian (same as the Java reference). Extensions default to `unixEpochOffset`, `yearEpochMilliseconds`, `dayEpochMilliseconds`.

### Example CLI

The [example/lukashian_example.dart](example/lukashian_example.dart) script is a small CLI that converts an Earth date (or the current date) to the Lukashian date using the official lukashian.org HTTP endpoint. Run it from the package root:

```bash
# Current date/time, Earth calendar
dart run example/lukashian_example.dart

# Specific date (ISO 8601), Earth calendar (default)
dart run example/lukashian_example.dart 2025-03-04

# Mars calendar
dart run example/lukashian_example.dart --calendar mars 2025-03-04

# Help
dart run example/lukashian_example.dart --help
```

Options: `-c` / `--calendar` (`earth` or `mars`), `-h` / `--help`. Optional positional argument: one ISO 8601 date; if omitted, the current instant is used.

## For future implementation

- **Computed providers**: Full implementations of `StandardEarthMillisecondStoreDataProvider` and `StandardMarsMillisecondStoreDataProvider` (Equation of Time and Mars sol calculations), so `CalendarKeys.earth` and `CalendarKeys.mars` work without network or file data.
- **Web support**: An HTTP implementation that works on the web (e.g. conditional imports or a platform-agnostic HTTP client), since the current `HttpMillisecondStoreDataProvider` uses `dart:io` and is VM-only.
- **Parsing**: Parse formatted strings back into `Year`, `Day`, or `LukashianInstant` where unambiguous.
- **Documentation**: API docs (e.g. `dart doc`) and additional examples.

## Additional information

- This package is a port of the [Java reference implementation](https://central.sonatype.com/artifact/org.lukashian/lukashian). The Dart API uses `LukashianInstant` to avoid clashing with `DateTime`, and async `MillisecondStoreDataProvider` methods (`Future<...>`). Computed Earth/Mars providers are stubs; use the HTTP (or file) providers to load official data from lukashian.org.
- The Lukashian Calendar and The Lukashian Calendar Mechanism are registered at the Benelux Office for Intellectual Property (registration number 120712). See the project license for redistribution and naming requirements.
