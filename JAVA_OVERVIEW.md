# Lukashian Java Source Code Overview

This document provides an overview of the Java source code implementing **The Lukashian Calendar** and **The Lukashian Calendar Mechanism** (Benelux IP registration 120712).

---

## 1. Purpose

The codebase implements an **astronomically accurate calendar** where:

- **Years** and **days** have variable length (they reflect actual solar/tropical years and true solar days).
- Time is measured from a **Lukashian epoch**; values are expressed as epoch milliseconds, epoch days, and year/day numbers.
- **Multiple calendar instances** are supported (e.g. Earth and Mars), each with its own epoch and day/year boundaries.
- **Time-of-day** is represented as a proportion of the current day (0–1) or as **beeps** (1/10000 of a day, similar to basis points).

---

## 2. Directory Structure

```
src/
├── main/java/org/lukashian/           # Core domain & formatting
│   ├── CalendarObject.java           # Base for Year, Day, Instant
│   ├── Year.java
│   ├── Day.java
│   ├── Instant.java
│   ├── Formatter.java
│   └── LukashianException.java
│
└── main/java/org/lukashian/store/     # Calendar data & providers
    ├── MillisecondStore.java         # Singleton: registry of calendar instances
    ├── MillisecondStoreData.java     # Epoch arrays + UNIX conversion
    ├── MillisecondStoreDataProvider.java   # Interface for loading data
    ├── CalendarKeys.java             # Constants: EARTH, MARS, HTTP variants
    └── provider/
        ├── StandardEarthMillisecondStoreDataProvider.java   # Earth: computed
        ├── StandardMarsMillisecondStoreDataProvider.java    # Mars: computed
        └── external/
            ├── ExternalResourceMillisecondStoreDataProvider.java  # Base for file/HTTP
            ├── file/FileMillisecondStoreDataProvider.java
            └── http/
                ├── HttpMillisecondStoreDataProvider.java
                ├── StandardEarthHttpMillisecondStoreDataProvider.java
                └── StandardMarsHttpMillisecondStoreDataProvider.java
```

Tests live under `src/test/java/org/lukashian/` and `org/lukashian/store/`.

---

## 3. Core Domain (`org.lukashian`)

### 3.1 `CalendarObject` (sealed abstract)

- **Subtypes:** `Year`, `Day`, `Instant` (Java `sealed`/`permits`).
- Holds a **calendar key** (`int`) identifying which calendar instance the object belongs to.
- Provides `getCalendarKey()` and `checkSameKeyAs(CalendarObject)` so operations only mix objects from the same calendar.

### 3.2 `Year`

- Immutable value representing a **Lukashian year** (year number ≥ 1).
- Stored: year number, epoch milliseconds at end of year, and at end of previous year (so length is computable).
- **Factory methods:** `Year.of(int year)`, `Year.of(int year, int calendarKey)`, `Year.now()`, `Year.now(int calendarKey)`.
- **Operations:** `plusYears` / `minusYears`, `previous` / `next`, `atDay(int)`, `firstDay()` / `lastDay()`, `firstInstant()` / `lastInstant()`.
- **Queries:** `contains(Day)`, `contains(Instant)`, `getNumberOfDays()`, `lengthInMilliseconds()`, `differenceWith(Year)`.
- A day belongs to the year in which it **starts**; the last day of a year may **end** in the next year.

### 3.3 `Day`

- Immutable value representing a **Lukashian day** (epoch day ≥ 1 and day-within-year).
- Stored: epoch day, epoch milliseconds at end of day and at end of previous day.
- **Factory methods:** `Day.ofEpoch(int epochDay)`, `Day.of(Year, int day)`, `Day.of(int year, int day)`, `Day.now()` (and calendar-key variants).
- **Operations:** `plusDays` / `minusDays`, `previous` / `next`, `atTime(BigFraction)`, `atTime(int beeps)`, `firstInstant()` / `lastInstant()`.
- **Queries:** `getYear()`, `getDayNumber()`, `lengthInMilliseconds()`, `getLengthOfBeepInMilliseconds()`, `differenceWith(Day)`, `contains(Instant)`.

### 3.4 `Instant`

- Immutable value representing a **point in time** (a specific millisecond on the timeline).
- Stored: `Day` + proportion of that day (0 inclusive, 1 exclusive) as `BigFraction`; epoch millisecond is derived when needed.
- **Beeps:** 1 beep = 1/10000 of a day (`BEEPS_PER_DAY = 10000`); used for time-of-day (e.g. 5000 = noon).
- **Factories:** `Instant.of(Day, BigFraction)`, `Instant.of(Day, int beeps)`, `Instant.ofEpoch(long epochMs)`, `Instant.ofUnixEpochMilliseconds(long)`, `Instant.ofJavaInstant(java.time.Instant)`, `Instant.now()` (and calendar-key variants).
- **Operations:** plus/minus years, days, milliseconds, seconds, proportion-of-day, beeps; `toCalendar(int calendarKey)` maps the same moment to another calendar instance.
- **Conversion:** `getUnixEpochMilliseconds()`, `toJavaInstant()` for interoperability.

### 3.5 `Formatter`

- Static helpers to format `Year`, `Day`, and `Instant` as strings.
- **Day formats:** `EPOCH`, `YEAR_FIRST` (e.g. 5919-43), `DAY_FIRST`, `DAY_ONLY`.
- Time-of-day: proportion as string or as 4-digit beeps (e.g. 0500).

### 3.6 `LukashianException`

- Runtime exception for calendar errors.
- `LukashianException.check(boolean, Supplier<String>)` throws with a message when the condition is false.

---

## 4. Store Layer (`org.lukashian.store`)

The store supplies the **numeric definition** of each calendar instance: epoch boundaries and UNIX offset.

### 4.1 `MillisecondStore` (singleton)

- **Role:** Registry of calendar instances. Each instance is identified by an `int` key and backed by a `MillisecondStoreDataProvider`.
- **Default calendar:** Configurable via `setDefaultCalendarKey`; default is Earth (`CalendarKeys.EARTH`).
- **Shortcuts:** `MillisecondStore.defaultCalendarKey()`, `MillisecondStore.data(calendarKey)`.
- **Lifecycle:** Registers built-in providers (Earth, Earth HTTP, Mars, Mars HTTP); data is loaded on first use and cached. `clearData(key)` / `clearAllData()` invalidate cache.

### 4.2 `MillisecondStoreData`

- Built from a `MillisecondStoreDataProvider`; holds:
  - **unixEpochOffsetMilliseconds:** offset from Lukashian epoch to UNIX epoch (so Lukashian epoch ms ↔ UNIX ms).
  - **yearEpochMilliseconds[]:** cumulative epoch ms at end of each year (index = year number − 1).
  - **dayEpochMilliseconds[]:** cumulative epoch ms at end of each epoch day (index = epoch day − 1).
- **UNIX conversion:** Converts between Lukashian epoch milliseconds and UNIX epoch milliseconds, including **leap-second** correction (fixed table from IANA/tz leap-seconds.list).
- **Lookups:** `getEpochMillisecondsForYear`, `getEpochMillisecondsForEpochDay`, `getYearForEpochMilliseconds`, `getEpochDayForEpochMilliseconds`, `getCurrentEpochMilliseconds`, `getUnixEpochMilliseconds`, `getLukashianEpochMilliseconds`.

### 4.3 `MillisecondStoreDataProvider` (interface)

Implementations supply:

- `loadUnixEpochOffsetMilliseconds()`
- `loadYearEpochMilliseconds()`
- `loadDayEpochMilliseconds(long[] yearEpochMilliseconds)`

No caching required; `MillisecondStore` caches the resulting `MillisecondStoreData`.

### 4.4 `CalendarKeys`

- Constants for default instances:
  - `EARTH` (1) — `StandardEarthMillisecondStoreDataProvider`
  - `EARTH_HTTP_LUKASHIAN_ORG` (2) — `StandardEarthHttpMillisecondStoreDataProvider`
  - `MARS` (3) — `StandardMarsMillisecondStoreDataProvider`
  - `MARS_HTTP_LUKASHIAN_ORG` (4) — `StandardMarsHttpMillisecondStoreDataProvider`

---

## 5. Data Providers

### 5.1 Computed providers (no external I/O)

- **StandardEarthMillisecondStoreDataProvider**  
  - Solar (tropical) years Southern Solstice → Southern Solstice; true solar days; Terrestrial Time.  
  - Uses astronomical algorithms (e.g. Jean Meeus) for solstices and Equation of Time; year numbers ~3900 above Gregorian.  
  - Precomputes 7000 years and corresponding days.

- **StandardMarsMillisecondStoreDataProvider**  
  - Same idea for Mars: solar Mars years and true solar Mars days from Southern Solstice.

### 5.2 External resource providers

- **ExternalResourceMillisecondStoreDataProvider** (abstract)  
  - Base for loading three blobs: unix epoch offset (single long), year epoch ms array, day epoch ms array.  
  - Binary format: 8 bytes per long, big-endian (via `ByteBuffer`/`LongBuffer`).  
  - Subclasses implement `loadMillisecondsByteArray(String location)`; location = base + extension (e.g. `unixEpochOffset`, `yearEpochMilliseconds`, `dayEpochMilliseconds`).

- **HttpMillisecondStoreDataProvider**  
  - Loads each blob via HTTP GET (binary); uses default or custom URL extensions.

- **FileMillisecondStoreDataProvider**  
  - Loads each blob from the filesystem (same binary format). Useful for offline use with data from e.g. lukashian.org.

- **StandardEarthHttpMillisecondStoreDataProvider**  
  - Base URL: `https://lukashian.org/millisecondstore/standardearth/`.

- **StandardMarsHttpMillisecondStoreDataProvider**  
  - Base URL: `https://lukashian.org/millisecondstore/standardmars/`.

---

## 6. Design Notes

| Topic | Detail |
|-------|--------|
| **Immutability** | `Year`, `Day`, and `Instant` are immutable; operations return new instances. |
| **Calendar key** | Every domain object carries a calendar key; cross-calendar comparison is rejected. |
| **Epoch semantics** | Intervals are [start, end): start inclusive, end exclusive. First millisecond of the calendar is 1. |
| **Beeps** | 10000 beeps per day; proportion stored as `BigFraction` to avoid rounding drift when converting to/from milliseconds. |
| **Leap seconds** | UNIX ↔ Terrestrial Time conversion in `MillisecondStoreData` uses a fixed leap-second table. |
| **Extensibility** | Custom calendar instances can be registered with `MillisecondStore.registerProvider(key, provider)`. |

---

## 7. Test Layout

- **Domain:** `YearTest`, `DayTest`, `InstantTest`, `FormatterTest`, `InstantRealCalendarTest`, `DayRealCalendarTest`, plus shared `LukashianAssert`.
- **Store:** `MillisecondStoreTest`, `TestMillisecondStoreDataProvider` (likely a test double for the store).

---

## 8. Dependencies (from code)

- **Apache Commons Numbers:** `org.apache.commons.numbers.fraction.BigFraction` for exact rational proportion of day.
- **Java standard:** `java.time.Instant`, `java.io.Serializable`, `java.net.http` (HTTP client), NIO `ByteBuffer`/`LongBuffer`.

This overview summarizes the structure and behavior of the Lukashian Java source under `src/`.
