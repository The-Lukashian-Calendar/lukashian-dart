/*
 * Copyright (c) 2018-2026 (5918-5926 in Lukashian years)
 * All rights reserved.
 * (License header abbreviated.)
 */

import 'package:fraction/fraction.dart';
import 'package:lukashian/lukashian.dart';
import 'package:test/test.dart';

import 'helpers/lukashian_assert.dart';
import 'helpers/test_millisecond_store_data_provider.dart';

void main() {
  setUpAll(() async {
    final store = MillisecondStore.store();
    store.registerProvider(testCalendarKey, TestMillisecondStoreDataProvider());
    store.registerProvider(
      CalendarKeys.earth,
      TestMillisecondStoreDataProvider(),
    );
    store.setDefaultCalendarKey(testCalendarKey);
    await store.ensureLoaded(testCalendarKey);
    await store.ensureLoaded(CalendarKeys.earth);
  });

  group('Day', () {
    test('testMinusYears', () {
      final day = Day.ofYearDay(4, 4);
      assertLukashianException(() => day.minusYears(1));
      assertLukashianException(() => day.minusYears(4));
      assertDay(4, testCalendarKey, day.minusYears(3));
    });

    test('testPlusYears', () {
      final day = Day.ofYearDay(1, 4);
      assertLukashianException(() => day.plusYears(1));
      assertDay(14, testCalendarKey, day.plusYears(3));
    });

    test('testMinusDays', () {
      final day = Day.ofEpoch(2, testCalendarKey);
      assertLukashianException(() => day.minusDays(3));
      assertLukashianException(() => day.minusDays(2));
      assertDay(1, testCalendarKey, day.minusDays(1));
      assertDay(2, testCalendarKey, day.minusDays(0));
      assertDay(3, testCalendarKey, day.minusDays(-1));
      assertDay(4, testCalendarKey, day.minusDays(-2));
      assertLukashianException(() => day.minusDays(-17));
    });

    test('testPlusDays', () {
      final day = Day.ofEpoch(2, testCalendarKey);
      assertLukashianException(() => day.plusDays(17));
      assertDay(4, testCalendarKey, day.plusDays(2));
      assertDay(3, testCalendarKey, day.plusDays(1));
      assertDay(2, testCalendarKey, day.plusDays(0));
      assertDay(1, testCalendarKey, day.plusDays(-1));
      assertLukashianException(() => day.plusDays(-2));
      assertLukashianException(() => day.plusDays(-3));
    });

    test('testPrevious', () {
      assertDay(1, testCalendarKey, Day.ofEpoch(2, testCalendarKey).previous());
    });

    test('testNext', () {
      assertDay(3, testCalendarKey, Day.ofEpoch(2, testCalendarKey).next());
    });

    test('testAtTime', () {
      assertLukashianException(
        () => Day.ofEpoch(1, testCalendarKey).atTime(Fraction(-1, 1)),
      );
      assertLukashianException(
        () => Day.ofEpoch(1, testCalendarKey).atTime(Fraction(1, 1)),
      );
      assertLukashianException(
        () => Day.ofEpoch(1, testCalendarKey).atTime(Fraction(2, 1)),
      );

      assertLukashianException(
        () => Day.ofEpoch(1, testCalendarKey).atTimeBeeps(-1),
      );
      assertLukashianException(
        () => Day.ofEpoch(1, testCalendarKey).atTimeBeeps(10000),
      );
      assertLukashianException(
        () => Day.ofEpoch(1, testCalendarKey).atTimeBeeps(20000),
      );

      assertInstant(
        1,
        testCalendarKey,
        Day.ofEpoch(1, testCalendarKey).atTime(Fraction(0, 1)),
      );
      assertInstant(
        151,
        testCalendarKey,
        Day.ofEpoch(1, testCalendarKey).atTime(Fraction(5, 10)),
      );
      assertInstant(
        300,
        testCalendarKey,
        Day.ofEpoch(1, testCalendarKey).atTime(Fraction(999999999, 1000000000)),
      );

      assertInstant(
        1,
        testCalendarKey,
        Day.ofEpoch(1, testCalendarKey).atTimeBeeps(0),
      );
      assertInstant(
        151,
        testCalendarKey,
        Day.ofEpoch(1, testCalendarKey).atTimeBeeps(5000),
      );
      assertInstant(
        300,
        testCalendarKey,
        Day.ofEpoch(1, testCalendarKey).atTimeBeeps(9999),
      );
    });

    test('testFirstInstant', () {
      assertInstant(
        1,
        testCalendarKey,
        Day.ofEpoch(1, testCalendarKey).firstInstant(),
      );
      assertInstant(
        301,
        testCalendarKey,
        Day.ofEpoch(2, testCalendarKey).firstInstant(),
      );
      assertDay(
        1,
        testCalendarKey,
        Day.ofEpoch(1, testCalendarKey).firstInstant().getDay(),
      );
      assertDay(
        2,
        testCalendarKey,
        Day.ofEpoch(2, testCalendarKey).firstInstant().getDay(),
      );
    });

    test('testLastInstant', () {
      assertInstant(
        300,
        testCalendarKey,
        Day.ofEpoch(1, testCalendarKey).lastInstant(),
      );
      assertInstant(
        600,
        testCalendarKey,
        Day.ofEpoch(2, testCalendarKey).lastInstant(),
      );
      assertDay(
        1,
        testCalendarKey,
        Day.ofEpoch(1, testCalendarKey).lastInstant().getDay(),
      );
      assertDay(
        2,
        testCalendarKey,
        Day.ofEpoch(2, testCalendarKey).lastInstant().getDay(),
      );
    });

    test('testIsBefore', () {
      expect(
        Day.ofEpoch(
          1,
          testCalendarKey,
        ).isBefore(Day.ofEpoch(2, testCalendarKey)),
        isTrue,
      );
      expect(
        Day.ofEpoch(
          1,
          testCalendarKey,
        ).isBefore(Day.ofEpoch(5, testCalendarKey)),
        isTrue,
      );
      expect(
        Day.ofEpoch(
          2,
          testCalendarKey,
        ).isBefore(Day.ofEpoch(1, testCalendarKey)),
        isFalse,
      );
      expect(
        Day.ofEpoch(
          5,
          testCalendarKey,
        ).isBefore(Day.ofEpoch(1, testCalendarKey)),
        isFalse,
      );
      expect(
        Day.ofEpoch(
          1,
          testCalendarKey,
        ).isBefore(Day.ofEpoch(1, testCalendarKey)),
        isFalse,
      );
      assertLukashianException(
        () => Day.ofEpoch(1).isBefore(Day.ofEpoch(2, CalendarKeys.earth)),
      );
    });

    test('testIsSameOrBefore', () {
      expect(
        Day.ofEpoch(
          1,
          testCalendarKey,
        ).isSameOrBefore(Day.ofEpoch(2, testCalendarKey)),
        isTrue,
      );
      expect(
        Day.ofEpoch(
          1,
          testCalendarKey,
        ).isSameOrBefore(Day.ofEpoch(5, testCalendarKey)),
        isTrue,
      );
      expect(
        Day.ofEpoch(
          2,
          testCalendarKey,
        ).isSameOrBefore(Day.ofEpoch(1, testCalendarKey)),
        isFalse,
      );
      expect(
        Day.ofEpoch(
          5,
          testCalendarKey,
        ).isSameOrBefore(Day.ofEpoch(1, testCalendarKey)),
        isFalse,
      );
      expect(
        Day.ofEpoch(
          1,
          testCalendarKey,
        ).isSameOrBefore(Day.ofEpoch(1, testCalendarKey)),
        isTrue,
      );
      assertLukashianException(
        () => Day.ofEpoch(1).isSameOrBefore(Day.ofEpoch(2, CalendarKeys.earth)),
      );
    });

    test('testIsAfter', () {
      expect(
        Day.ofEpoch(
          1,
          testCalendarKey,
        ).isAfter(Day.ofEpoch(2, testCalendarKey)),
        isFalse,
      );
      expect(
        Day.ofEpoch(
          2,
          testCalendarKey,
        ).isAfter(Day.ofEpoch(1, testCalendarKey)),
        isTrue,
      );
      expect(
        Day.ofEpoch(
          1,
          testCalendarKey,
        ).isAfter(Day.ofEpoch(1, testCalendarKey)),
        isFalse,
      );
      assertLukashianException(
        () => Day.ofEpoch(1).isAfter(Day.ofEpoch(2, CalendarKeys.earth)),
      );
    });

    test('testIsSameOrAfter', () {
      expect(
        Day.ofEpoch(
          1,
          testCalendarKey,
        ).isSameOrAfter(Day.ofEpoch(2, testCalendarKey)),
        isFalse,
      );
      expect(
        Day.ofEpoch(
          2,
          testCalendarKey,
        ).isSameOrAfter(Day.ofEpoch(1, testCalendarKey)),
        isTrue,
      );
      expect(
        Day.ofEpoch(
          1,
          testCalendarKey,
        ).isSameOrAfter(Day.ofEpoch(1, testCalendarKey)),
        isTrue,
      );
      assertLukashianException(
        () => Day.ofEpoch(1).isSameOrAfter(Day.ofEpoch(2, CalendarKeys.earth)),
      );
    });

    test('testContains', () {
      final day = Day.ofEpoch(2, testCalendarKey);
      expect(day.contains(day.firstInstant()), isTrue);
      expect(day.contains(day.lastInstant()), isTrue);
      expect(
        Day.ofEpoch(
          1,
          testCalendarKey,
        ).contains(Instant.ofEpoch(1, testCalendarKey)),
        isTrue,
      );
      expect(
        Day.ofEpoch(
          1,
          testCalendarKey,
        ).contains(Instant.ofEpoch(300, testCalendarKey)),
        isTrue,
      );
      expect(
        Day.ofEpoch(
          1,
          testCalendarKey,
        ).contains(Instant.ofEpoch(301, testCalendarKey)),
        isFalse,
      );
      expect(
        Day.ofEpoch(
          18,
          testCalendarKey,
        ).contains(Instant.ofEpoch(39000, testCalendarKey)),
        isTrue,
      );
      assertLukashianException(
        () => Day.ofEpoch(1).contains(Instant.ofEpoch(2, CalendarKeys.earth)),
      );
    });

    test('testContainsNot', () {
      final day = Day.ofEpoch(2, testCalendarKey);
      expect(day.containsNot(day.firstInstant()), isFalse);
      expect(day.containsNot(day.lastInstant()), isFalse);
      expect(
        Day.ofEpoch(
          1,
          testCalendarKey,
        ).containsNot(Instant.ofEpoch(301, testCalendarKey)),
        isTrue,
      );
      assertLukashianException(
        () =>
            Day.ofEpoch(1).containsNot(Instant.ofEpoch(2, CalendarKeys.earth)),
      );
    });

    test('testIsIn', () {
      expect(Day.ofEpoch(1, testCalendarKey).isIn(Year.of(1)), isTrue);
      expect(Day.ofEpoch(4, testCalendarKey).isIn(Year.of(1)), isTrue);
      expect(Day.ofEpoch(5, testCalendarKey).isIn(Year.of(1)), isFalse);
      assertLukashianException(
        () => Day.ofEpoch(1).isIn(Year.of(2, CalendarKeys.earth)),
      );
    });

    test('testIsNotIn', () {
      expect(Day.ofEpoch(1, testCalendarKey).isNotIn(Year.of(1)), isFalse);
      expect(Day.ofEpoch(5, testCalendarKey).isNotIn(Year.of(1)), isTrue);
      assertLukashianException(
        () => Day.ofEpoch(1).isNotIn(Year.of(2, CalendarKeys.earth)),
      );
    });

    test('testLengthInMilliseconds', () {
      expect(Day.ofEpoch(1, testCalendarKey).lengthInMilliseconds(), 300);
      expect(Day.ofEpoch(16, testCalendarKey).lengthInMilliseconds(), 299);
      expect(Day.ofEpoch(17, testCalendarKey).lengthInMilliseconds(), 101);
      expect(Day.ofEpoch(18, testCalendarKey).lengthInMilliseconds(), 34100);
    });

    test('testGetEpochDay', () {
      expect(Day.ofEpoch(1, testCalendarKey).getEpochDay(), 1);
      expect(Day.ofEpoch(18, testCalendarKey).getEpochDay(), 18);
    });

    test('testGetEpochMilliseconds', () {
      expect(Day.ofEpoch(1, testCalendarKey).getEpochMilliseconds(), 300);
      expect(Day.ofEpoch(18, testCalendarKey).getEpochMilliseconds(), 39000);
    });

    test('testGetEpochMillisecondsAtStartOfDay', () {
      expect(
        Day.ofEpoch(1, testCalendarKey).getEpochMillisecondsAtStartOfDay(),
        1,
      );
      expect(
        Day.ofEpoch(2, testCalendarKey).getEpochMillisecondsAtStartOfDay(),
        301,
      );
    });

    test('testGetYear', () {
      assertYear(1, testCalendarKey, Day.ofEpoch(1, testCalendarKey).getYear());
      assertYear(2, testCalendarKey, Day.ofEpoch(5, testCalendarKey).getYear());
      assertYear(
        7,
        testCalendarKey,
        Day.ofEpoch(18, testCalendarKey).getYear(),
      );
    });

    test('testGetEndYear', () {
      assertYear(
        1,
        testCalendarKey,
        Day.ofEpoch(1, testCalendarKey).getEndYear(),
      );
      assertYear(
        2,
        testCalendarKey,
        Day.ofEpoch(4, testCalendarKey).getEndYear(),
      );
      assertYear(
        8,
        testCalendarKey,
        Day.ofEpoch(18, testCalendarKey).getEndYear(),
      );
    });

    test('testGetDayNumber', () {
      expect(Day.of(Year.of(1), 1).getDayNumber(), 1);
      expect(Day.of(Year.of(1), 4).getDayNumber(), 4);
      assertLukashianException(() => Day.of(Year.of(1), 5));
      expect(Day.ofEpoch(5, testCalendarKey).getDayNumber(), 1);
      assertLukashianException(() => Day.ofEpoch(0, testCalendarKey));
      assertLukashianException(() => Day.ofEpoch(19, testCalendarKey));
    });

    test('testDifferenceWith', () {
      expect(
        Day.ofEpoch(
          1,
          testCalendarKey,
        ).differenceWith(Day.ofEpoch(1, testCalendarKey)),
        0,
      );
      expect(
        Day.ofEpoch(
          1,
          testCalendarKey,
        ).differenceWith(Day.ofEpoch(4, testCalendarKey)),
        -3,
      );
      expect(
        Day.ofEpoch(
          4,
          testCalendarKey,
        ).differenceWith(Day.ofEpoch(1, testCalendarKey)),
        3,
      );
      assertLukashianException(
        () => Day.ofEpoch(
          4,
          testCalendarKey,
        ).differenceWith(Day.ofEpoch(4, CalendarKeys.earth)),
      );
    });

    test('testOf', () {
      assertDay(1, testCalendarKey, Day.ofYearDay(1, 1));
      assertDay(18, testCalendarKey, Day.ofYearDay(7, 1));
      assertLukashianException(() => Day.ofEpoch(0));
      assertLukashianException(() => Day.ofYearDay(1, 5));
      assertDay(1, CalendarKeys.earth, Day.ofEpoch(1, CalendarKeys.earth));
      assertDay(1, CalendarKeys.earth, Day.ofYearDay(1, 1, CalendarKeys.earth));
    });

    test('testNow', () {
      expect(Day.now().getCalendarKey(), testCalendarKey);
      expect(Day.now(CalendarKeys.earth).getCalendarKey(), CalendarKeys.earth);
    });

    test('testCompareTo', () {
      expect(
        Day.ofEpoch(
          1,
          testCalendarKey,
        ).compareTo(Day.ofEpoch(1, testCalendarKey)),
        0,
      );
      expect(
        Day.ofEpoch(
          1,
          testCalendarKey,
        ).compareTo(Day.ofEpoch(4, testCalendarKey)),
        -3,
      );
      expect(
        Day.ofEpoch(
          4,
          testCalendarKey,
        ).compareTo(Day.ofEpoch(1, testCalendarKey)),
        3,
      );
      assertLukashianException(
        () => Day.ofEpoch(8).compareTo(Day.ofEpoch(4, CalendarKeys.earth)),
      );
    });

    test('testHashCode', () {
      expect(
        Day.ofEpoch(2, testCalendarKey).hashCode,
        Day.ofEpoch(2, testCalendarKey).hashCode,
      );
      expect(
        Day.ofEpoch(2, testCalendarKey).hashCode,
        isNot(Day.ofEpoch(2, CalendarKeys.earth).hashCode),
      );
    });

    test('testEquals', () {
      expect(
        Day.ofEpoch(1, testCalendarKey) == Day.ofEpoch(1, testCalendarKey),
        isTrue,
      );
      expect(
        Day.ofEpoch(1, testCalendarKey) == Day.ofEpoch(1, CalendarKeys.earth),
        isFalse,
      );
      expect(
        Day.ofEpoch(1, testCalendarKey) == Day.ofEpoch(2, testCalendarKey),
        isFalse,
      );
      expect(Day.ofEpoch(1, testCalendarKey) == Year.of(1), isFalse);
    });

    test('testToString', () {
      expect(Day.ofEpoch(2, testCalendarKey).toString(), '[Day: 1-2]');
    });
  });
}
