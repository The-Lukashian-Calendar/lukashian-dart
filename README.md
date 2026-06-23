# lukashian

A Dart port of **The Lukashian Calendar** — a calendar that is exceptionally simple, highly accurate and radically different. It provides a universal mechanism for every planet, moon or space station we'll ever inhabit and is the calendar of choice for the upcoming Mars Settlement.

For more on the calendar itself, see [lukashian.org](https://www.lukashian.org). The canonical Java implementation and reference documentation live at [The-Lukashian-Calendar/lukashian](https://github.com/The-Lukashian-Calendar/lukashian). This port aims to map closely to the original java.

## Features

- **Core types**: `Year`, `Day`, `Instant` (epoch-based, comparable, calendar-key aware)
- **Formatting**: `Formatter` and `DayFormat` for years, days, instants and time-of-day (e.g. beeps)
- **Multiple calendars**: Load and switch between Earth, Mars, or your own data via `MillisecondStore`, `MillisecondStoreDataProvider`, and `AsyncMillisecondStoreDataProvider`
- **External data**: Load calendar data from files or HTTP (including official [lukashian.org](https://www.lukashian.org) endpoints) using `FileMillisecondStoreDataProvider`, `HttpMillisecondStoreDataProvider`, `StandardEarthHttpMillisecondStoreDataProvider`, and `StandardMarsHttpMillisecondStoreDataProvider`

## Getting started

Add the dependency:

```yaml
dependencies:
  lukashian: ^1.0.0
```

Then call `init()` once at startup before using the default calendar:

```dart
import 'package:lukashian/lukashian.dart';

void main() async {
  await MillisecondStore.store().init();

  final now = Instant.now();
  print(Formatter.formatInstant(now)); // e.g. "5919-43 3300"
}
```

## Usage

### Instants, days and years

```dart
// Current instant (uses default calendar)
final now = Instant.now();

// From epoch millisecond or day
final instant = Instant.ofEpoch(1_000_000);
final day = Day.ofEpoch(42);

// From year and day
final y = Year.of(5919);
final d = Day.of(y, 43);
final inst = Instant.ofYearDayBeepsKey(5919, 43, 3300);

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
final onMars = Instant.now(CalendarKeys.marsHttpLukashianOrg);

// Set default so all future now() / of() use that calendar
await MillisecondStore.store().init();
MillisecondStore.store().setDefaultCalendarKey(CalendarKeys.marsHttpLukashianOrg);
```

Calendar keys: `CalendarKeys.earth`, `CalendarKeys.earthHttpLukashianOrg`, `CalendarKeys.mars`, `CalendarKeys.marsHttpLukashianOrg`. The `earth` and `mars` keys are for computed providers (stubs in this port throw `UnimplementedError` until [#33](https://github.com/chris-NR/lukashian-dart/issues/33)); use `init()` to load the `*HttpLukashianOrg` calendars from lukashian.org.

### Loading from files or HTTP

```dart
final store = MillisecondStore.store();

// Default HTTP calendars (Earth and Mars from lukashian.org)
await store.init();

// Custom URL or local directory (base must end with / or path separator)
await store.loadAsyncProvider(
  99,
  HttpMillisecondStoreDataProvider.withDefaults('https://example.com/calendar/'),
);
await store.loadAsyncProvider(
  98,
  FileMillisecondStoreDataProvider.withDefaults('/path/to/calendar/'),
);

// Synchronous in-memory provider
store.loadProvider(97, MyMillisecondStoreDataProvider());
```

Binary format: 8 bytes per value, big-endian (same as the Java reference). Extensions default to `unixEpochOffset`, `yearEpochMilliseconds`, `dayEpochMilliseconds`.

### Example CLI

The [example CLI](https://github.com/chris-NR/lukashian-dart/blob/main/example/lukashian_example.dart) converts an Earth date (or the current date) to the Lukashian date using the official lukashian.org HTTP endpoint. Run it from the package root:

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
- **Parsing**: Parse formatted strings back into `Year`, `Day`, or `Instant` where unambiguous.

## Deviations from the Java reference implementation

This package mirrors [org.lukashian:lukashian](https://central.sonatype.com/artifact/org.lukashian/lukashian) (see the `lukashian` Java repo). Intentional differences:

- **Instant type name**: Java uses `org.lukashian.Instant`; Dart exposes `Instant` so it does not clash with `dart:core` `DateTime`. (Some early docs said “LukashianInstant”; the type is `Instant`.)
- **Eager loading and dual provider interfaces**: Java keeps providers in a map and lazily loads via `getData()`. Dart eagerly loads via `MillisecondStore.loadProvider` (sync) or `loadAsyncProvider` (async), stores only `MillisecondStoreData`, and does not retain providers. `MillisecondStoreDataProvider` matches Java (sync methods); async I/O uses `AsyncMillisecondStoreDataProvider`. Call `MillisecondStore.init()` at startup for default HTTP calendars.
- **MillisecondStore access**: Java offers static shortcuts `MillisecondStore.data(key)` and `MillisecondStore.defaultCalendarKey()` on the singleton. Dart uses `MillisecondStore.store()` and instance methods `data`, `getDefaultCalendarKey`, `setDefaultCalendarKey`, `init`, `loadProvider`, and `loadAsyncProvider`.
- **Fraction type**: Java uses Apache `BigFraction`; Dart uses `package:fraction` `Fraction`.
- **Numeric types**: Java uses `long` for epoch milliseconds; Dart uses `int` (64-bit on the VM; be careful on web if values exceed JS safe integer range).
- **Computed Earth/Mars providers**: Java fully implements `StandardEarthMillisecondStoreDataProvider` and `StandardMarsMillisecondStoreDataProvider`. The Dart port ships **stubs** that throw `UnimplementedError`; use `StandardEarthHttpMillisecondStoreDataProvider`, `StandardMarsHttpMillisecondStoreDataProvider`, or your own provider.
- **HTTP client**: Java uses `java.net.http.HttpClient`. Dart uses `dart:io` `HttpClient`, so the HTTP providers are **VM-only**, not web.
- **Interop**: Java provides `toJavaInstant()` / `ofJavaInstant`. Dart provides `Instant.toDateTime` / `Instant.ofDateTime` for UTC `DateTime`.
- **Formatting API**: Java overloads `Formatter.format(...)`. Dart uses named methods such as `Formatter.formatYear`, `formatDay`, `formatInstant`.
- **Combined predicates**: Java overloads membership methods (e.g. `Year.contains(Day)` vs `contains(Instant)`, `Instant.isIn(Year)` vs `isIn(Day)`). Dart uses suffixed names (`containsDay`, `containsInstant`, `isInYear`, `isInDay`, and their negations) because Dart has no method overloading. This preserves Java's compile-time type safety: invalid combinations such as `instant.isIn(anotherInstant)` are rejected by the analyzer.
- **Serialization**: Java core types implement `java.io.Serializable`; Dart has no direct equivalent.

API behavior is otherwise intended to match the Java library; where this port differs, prefer the dartdoc on each declaration.

## Additional information

- The Lukashian Calendar and The Lukashian Calendar Mechanism are registered at the Benelux Office for Intellectual Property (registration number 120712). See the project license for redistribution and naming requirements.
- As an experiment in AI assisted software engineering this port was produced using the Cursor IDE. Claude Opus (4.6/7) was used for planning and Composer/'auto' were used for implementation. Code/PR reviews were performed by CodeRabbit.