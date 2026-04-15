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

const int _toCalendarSourceKey = testCalendarKey + 1;
const int _toCalendarTargetKey = testCalendarKey + 2;

void main() {
  setUpAll(() async {
    final store = MillisecondStore.store();
    store.registerProvider(testCalendarKey, TestMillisecondStoreDataProvider());
    store.registerProvider(
      CalendarKeys.earth,
      TestMillisecondStoreDataProvider(),
    );
    store.registerProvider(_toCalendarSourceKey, ConstantOffsetTestProvider(0));
    store.registerProvider(
      _toCalendarTargetKey,
      ConstantOffsetTestProvider(1000),
    );
    store.setDefaultCalendarKey(testCalendarKey);
    await store.ensureLoaded(testCalendarKey);
    await store.ensureLoaded(CalendarKeys.earth);
    await store.ensureLoaded(_toCalendarSourceKey);
    await store.ensureLoaded(_toCalendarTargetKey);
  });

  group('LukashianInstant', () {
    test('testMinusYears', () {
      final instant = Instant.ofEpoch(4050, testCalendarKey);
      assertLukashianException(() => instant.minusYears(1));
      assertLukashianException(() => instant.minusYears(4));
      assertInstant(1050, testCalendarKey, instant.minusYears(3));
    });

    test('testPlusYears', () {
      final instant = Instant.ofEpoch(1050, testCalendarKey);
      assertLukashianException(() => instant.plusYears(1));
      assertInstant(4050, testCalendarKey, instant.plusYears(3));
    });

    test('testMinusDays', () {
      assertInstant(
        150,
        testCalendarKey,
        Instant.ofEpoch(450, testCalendarKey).minusDays(1),
      );
      assertLukashianException(
        () => Instant.ofEpoch(450, testCalendarKey).minusDays(2),
      );
    });

    test('testPlusDays', () {
      assertInstant(
        750,
        testCalendarKey,
        Instant.ofEpoch(450, testCalendarKey).plusDays(1),
      );
      assertLukashianException(
        () => Instant.ofEpoch(450, testCalendarKey).plusDays(17),
      );
    });

    test('testAtPreviousDay', () {
      assertInstant(
        150,
        testCalendarKey,
        Instant.ofEpoch(450, testCalendarKey).atPreviousDay(),
      );
    });

    test('testAtNextDay', () {
      assertInstant(
        750,
        testCalendarKey,
        Instant.ofEpoch(450, testCalendarKey).atNextDay(),
      );
    });

    test('testMinusMilliseconds', () {
      final instant = Instant.ofEpoch(450, testCalendarKey);
      assertLukashianException(() => instant.minusMilliseconds(450));
      assertInstant(1, testCalendarKey, instant.minusMilliseconds(449));
      assertInstant(450, testCalendarKey, instant.minusMilliseconds(0));
      assertInstant(6450, testCalendarKey, instant.minusMilliseconds(-6000));
    });

    test('testMinusSeconds', () {
      assertInstant(
        1000,
        testCalendarKey,
        Instant.ofEpoch(2000, testCalendarKey).minusSeconds(1),
      );
    });

    test('testPlusMilliseconds', () {
      final instant = Instant.ofEpoch(450, testCalendarKey);
      assertLukashianException(() => instant.plusMilliseconds(-450));
      assertInstant(650, testCalendarKey, instant.plusMilliseconds(200));
      assertInstant(6450, testCalendarKey, instant.plusMilliseconds(6000));
      assertInstant(250, testCalendarKey, instant.plusMilliseconds(-200));
    });

    test('testPlusSeconds', () {
      assertInstant(
        3000,
        testCalendarKey,
        Instant.ofEpoch(2000, testCalendarKey).plusSeconds(1),
      );
    });

    test('testMinusBeeps', () {
      final instant = Instant.ofEpoch(1651, testCalendarKey);
      assertLukashianException(() => instant.minusBeeps(55034));
      assertInstant(1, testCalendarKey, instant.minusBeeps(54999));
      assertInstant(1651, testCalendarKey, instant.minusBeeps(0));
      assertInstant(1951, testCalendarKey, instant.minusBeeps(-10000));
    });

    test('testPlusBeeps', () {
      final instant = Instant.ofEpoch(1651, testCalendarKey);
      assertInstant(1651, testCalendarKey, instant.plusBeeps(0));
      assertInstant(2551, testCalendarKey, instant.plusBeeps(30000));
    });

    test('testIsBefore', () {
      expect(
        Instant.ofEpoch(
          1,
          testCalendarKey,
        ).isBefore(Instant.ofEpoch(2, testCalendarKey)),
        isTrue,
      );
      expect(
        Instant.ofEpoch(
          1,
          testCalendarKey,
        ).isBefore(Instant.ofEpoch(1, testCalendarKey)),
        isFalse,
      );
      expect(
        Instant.ofEpoch(
          2,
          testCalendarKey,
        ).isBefore(Instant.ofEpoch(1, testCalendarKey)),
        isFalse,
      );
      assertLukashianException(
        () =>
            Instant.ofEpoch(1).isBefore(Instant.ofEpoch(2, CalendarKeys.earth)),
      );
    });

    test('testIsSameOrBefore', () {
      expect(
        Instant.ofEpoch(
          1,
          testCalendarKey,
        ).isSameOrBefore(Instant.ofEpoch(2, testCalendarKey)),
        isTrue,
      );
      expect(
        Instant.ofEpoch(
          1,
          testCalendarKey,
        ).isSameOrBefore(Instant.ofEpoch(1, testCalendarKey)),
        isTrue,
      );
      assertLukashianException(
        () => Instant.ofEpoch(
          1,
        ).isSameOrBefore(Instant.ofEpoch(2, CalendarKeys.earth)),
      );
    });

    test('testIsAfter', () {
      expect(
        Instant.ofEpoch(
          1,
          testCalendarKey,
        ).isAfter(Instant.ofEpoch(2, testCalendarKey)),
        isFalse,
      );
      expect(
        Instant.ofEpoch(
          2,
          testCalendarKey,
        ).isAfter(Instant.ofEpoch(1, testCalendarKey)),
        isTrue,
      );
      assertLukashianException(
        () =>
            Instant.ofEpoch(1).isAfter(Instant.ofEpoch(2, CalendarKeys.earth)),
      );
    });

    test('testIsSameOrAfter', () {
      expect(
        Instant.ofEpoch(
          1,
          testCalendarKey,
        ).isSameOrAfter(Instant.ofEpoch(2, testCalendarKey)),
        isFalse,
      );
      expect(
        Instant.ofEpoch(
          2,
          testCalendarKey,
        ).isSameOrAfter(Instant.ofEpoch(1, testCalendarKey)),
        isTrue,
      );
      assertLukashianException(
        () => Instant.ofEpoch(
          1,
        ).isSameOrAfter(Instant.ofEpoch(2, CalendarKeys.earth)),
      );
    });

    test('testIsIn', () {
      expect(Instant.ofEpoch(1, testCalendarKey).isIn(Year.of(1)), isTrue);
      expect(Instant.ofEpoch(1000, testCalendarKey).isIn(Year.of(1)), isTrue);
      expect(Instant.ofEpoch(1001, testCalendarKey).isIn(Year.of(1)), isFalse);
      expect(
        Instant.ofEpoch(
          1,
          testCalendarKey,
        ).isIn(Day.ofEpoch(1, testCalendarKey)),
        isTrue,
      );
      expect(
        Instant.ofEpoch(
          301,
          testCalendarKey,
        ).isIn(Day.ofEpoch(1, testCalendarKey)),
        isFalse,
      );
      assertLukashianException(
        () => Instant.ofEpoch(1).isIn(Day.ofEpoch(2, CalendarKeys.earth)),
      );
      assertLukashianException(
        () => Instant.ofEpoch(1).isIn(Year.of(2, CalendarKeys.earth)),
      );
    });

    test('testIsNotIn', () {
      expect(
        Instant.ofEpoch(1001, testCalendarKey).isNotIn(Year.of(1)),
        isTrue,
      );
      expect(
        Instant.ofEpoch(
          301,
          testCalendarKey,
        ).isNotIn(Day.ofEpoch(1, testCalendarKey)),
        isTrue,
      );
    });

    test('testGetEpochMilliseconds', () {
      expect(Instant.ofEpoch(1, testCalendarKey).getEpochMilliseconds(), 1);
      expect(
        Instant.ofEpoch(39000, testCalendarKey).getEpochMilliseconds(),
        39000,
      );
    });

    test('testGetMillisecond', () {
      expect(Instant.ofEpoch(1, testCalendarKey).getMillisecond(), 1);
    });

    test('testGetDay', () {
      assertDay(
        1,
        testCalendarKey,
        Instant.ofEpoch(1, testCalendarKey).getDay(),
      );
      assertDay(
        2,
        testCalendarKey,
        Instant.ofEpoch(301, testCalendarKey).getDay(),
      );
      assertDay(
        17,
        testCalendarKey,
        Instant.ofEpoch(4800, testCalendarKey).getDay(),
      );
      assertDay(
        18,
        testCalendarKey,
        Instant.ofEpoch(39000, testCalendarKey).getDay(),
      );
    });

    test('testGetYear', () {
      assertYear(
        1,
        testCalendarKey,
        Instant.ofEpoch(1, testCalendarKey).getYear(),
      );
      assertYear(
        2,
        testCalendarKey,
        Instant.ofEpoch(1001, testCalendarKey).getYear(),
      );
      assertYear(
        8,
        testCalendarKey,
        Instant.ofEpoch(39000, testCalendarKey).getYear(),
      );
      assertLukashianException(
        () => Instant.ofEpoch(39001, testCalendarKey).getYear(),
      );
    });

    test('testGetProportionOfDay', () {
      expect(
        Instant.ofEpoch(1, testCalendarKey).getProportionOfDay(),
        Fraction(0, 1),
      );
      expect(
        Instant.ofEpoch(151, testCalendarKey).getProportionOfDay(),
        Fraction(5, 10),
      );
      expect(
        Instant.ofEpoch(300, testCalendarKey).getProportionOfDay(),
        Fraction(299, 300),
      );
      expect(
        Instant.ofEpoch(301, testCalendarKey).getProportionOfDay(),
        Fraction(0, 1),
      );
    });

    test('testGetBeeps', () {
      expect(Instant.ofEpoch(1, testCalendarKey).getBeeps(), 0);
      expect(Instant.ofEpoch(151, testCalendarKey).getBeeps(), 5000);
      expect(Instant.ofEpoch(300, testCalendarKey).getBeeps(), 9966);
    });

    test('testGetUnixEpochMilliseconds', () {
      final now = DateTime.now().millisecondsSinceEpoch;
      expect(
        Instant.ofUnixEpochMilliseconds(now).getUnixEpochMilliseconds(),
        now,
      );
    });

    test('testToDateTime', () {
      final now = DateTime.now().millisecondsSinceEpoch;
      expect(
        Instant.ofUnixEpochMilliseconds(
          now,
        ).toDateTime().millisecondsSinceEpoch,
        now,
      );
    });

    test('testToCalendar', () {
      final instant = Instant.ofEpoch(450, _toCalendarSourceKey);
      final converted = instant.toCalendar(_toCalendarTargetKey);
      expect(
        converted.getEpochMilliseconds() - instant.getEpochMilliseconds(),
        1000,
      );
      expect(converted.getCalendarKey(), _toCalendarTargetKey);
    });

    test('testDifferenceWith', () {
      expect(
        Instant.ofEpoch(
          1,
          testCalendarKey,
        ).differenceWith(Instant.ofEpoch(1, testCalendarKey)),
        0,
      );
      expect(
        Instant.ofEpoch(
          1,
          testCalendarKey,
        ).differenceWith(Instant.ofEpoch(4, testCalendarKey)),
        -3,
      );
      expect(
        Instant.ofEpoch(
          4,
          testCalendarKey,
        ).differenceWith(Instant.ofEpoch(1, testCalendarKey)),
        3,
      );
      assertLukashianException(
        () => Instant.ofEpoch(
          4,
          testCalendarKey,
        ).differenceWith(Instant.ofEpoch(4, CalendarKeys.earth)),
      );
    });

    test('testOf', () {
      assertLukashianException(() => Instant.ofEpoch(0, testCalendarKey));
      assertLukashianException(
        () => Instant.of(Day.ofEpoch(2, testCalendarKey), Fraction(-1, 1)),
      );
      assertLukashianException(
        () => Instant.of(Day.ofEpoch(2, testCalendarKey), Fraction(1, 1)),
      );
      assertLukashianException(
        () => Instant.ofBeeps(Day.ofEpoch(2, testCalendarKey), -1),
      );
      assertLukashianException(
        () => Instant.ofBeeps(Day.ofEpoch(2, testCalendarKey), 10000),
      );

      assertInstant(
        1,
        testCalendarKey,
        Instant.of(Day.ofEpoch(1, testCalendarKey), Fraction(0, 1)),
      );
      assertInstant(
        151,
        testCalendarKey,
        Instant.of(Day.ofEpoch(1, testCalendarKey), Fraction(5, 10)),
      );
      assertInstant(
        300,
        testCalendarKey,
        Instant.of(
          Day.ofEpoch(1, testCalendarKey),
          Fraction(999999999, 1000000000),
        ),
      );

      assertInstant(
        1,
        testCalendarKey,
        Instant.ofBeeps(Day.ofEpoch(1, testCalendarKey), 0),
      );
      assertInstant(
        151,
        testCalendarKey,
        Instant.ofBeeps(Day.ofEpoch(1, testCalendarKey), 5000),
      );
      assertInstant(
        300,
        testCalendarKey,
        Instant.ofBeeps(Day.ofEpoch(1, testCalendarKey), 9999),
      );

      assertInstant(
        151,
        testCalendarKey,
        Instant.ofYearDay(Year.of(1), 1, Fraction(5, 10)),
      );
      assertInstant(
        151,
        testCalendarKey,
        Instant.ofYearDayFraction(1, 1, Fraction(5, 10)),
      );

      assertInstant(
        151,
        testCalendarKey,
        Instant.ofYearDayBeeps(Year.of(1), 1, 5000),
      );
      assertInstant(
        151,
        testCalendarKey,
        Instant.ofYearDayBeepsKey(1, 1, 5000),
      );

      assertInstant(
        1,
        CalendarKeys.earth,
        Instant.ofEpoch(1, CalendarKeys.earth),
      );
      assertInstant(
        1,
        CalendarKeys.earth,
        Instant.ofYearDayFraction(1, 1, Fraction(0, 1), CalendarKeys.earth),
      );
      expect(
        Instant.ofDateTime(DateTime.now(), CalendarKeys.earth).getCalendarKey(),
        CalendarKeys.earth,
      );
    });

    test('testOfUnixEpochMilliseconds', () {
      expect(
        Instant.ofUnixEpochMilliseconds(DateTime.now().millisecondsSinceEpoch),
        isNotNull,
      );
    });

    test('testOfDateTime', () {
      expect(Instant.ofDateTime(DateTime.now()), isNotNull);
    });

    test('testNow', () {
      expect(Instant.now().getCalendarKey(), testCalendarKey);
      expect(
        Instant.now(CalendarKeys.earth).getCalendarKey(),
        CalendarKeys.earth,
      );
    });

    test('testCompareTo', () {
      expect(
        Instant.ofEpoch(
          1,
          testCalendarKey,
        ).compareTo(Instant.ofEpoch(1, testCalendarKey)),
        0,
      );
      expect(
        Instant.ofEpoch(
          1,
          testCalendarKey,
        ).compareTo(Instant.ofEpoch(4, testCalendarKey)),
        -1,
      );
      expect(
        Instant.ofEpoch(
          4,
          testCalendarKey,
        ).compareTo(Instant.ofEpoch(1, testCalendarKey)),
        1,
      );
      assertLukashianException(
        () => Instant.ofEpoch(
          8,
        ).compareTo(Instant.ofEpoch(4, CalendarKeys.earth)),
      );
    });

    test('testHashCode', () {
      expect(
        Instant.ofEpoch(2, testCalendarKey).hashCode,
        Instant.ofEpoch(2, testCalendarKey).hashCode,
      );
      expect(
        Instant.ofEpoch(2, testCalendarKey).hashCode,
        isNot(Instant.ofEpoch(2, CalendarKeys.earth).hashCode),
      );
    });

    test('testEquals', () {
      expect(
        Instant.ofEpoch(1, testCalendarKey) ==
            Instant.ofEpoch(1, testCalendarKey),
        isTrue,
      );
      expect(
        Instant.ofEpoch(1, testCalendarKey) ==
            Instant.ofEpoch(1, CalendarKeys.earth),
        isFalse,
      );
      expect(
        Instant.ofEpoch(1, testCalendarKey) ==
            Instant.ofEpoch(2, testCalendarKey),
        isFalse,
      );
      expect(Instant.ofEpoch(1, testCalendarKey) == Year.of(1), isFalse);
      expect(
        Instant.ofYearDayFraction(1, 1, Fraction(600000000, 1000000000)) ==
            Instant.ofYearDayFraction(1, 1, Fraction(600000000, 1000000000)),
        isTrue,
      );
    });

    test('testToString', () {
      expect(
        Instant.ofEpoch(2, testCalendarKey).toString(),
        '[Instant: 1-1 0033]',
      );
    });
  });
}
