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
    store.registerProvider(CalendarKeys.earth, TestMillisecondStoreDataProvider());
    store.setDefaultCalendarKey(testCalendarKey);
    await store.ensureLoaded(testCalendarKey);
    await store.ensureLoaded(CalendarKeys.earth);
  });

  group('LukashianInstant', () {
    test('testMinusYears', () {
      final instant = LukashianInstant.ofEpoch(4050, testCalendarKey);
      assertLukashianException(() => instant.minusYears(1));
      assertLukashianException(() => instant.minusYears(4));
      assertInstant(1050, testCalendarKey, instant.minusYears(3));
    });

    test('testPlusYears', () {
      final instant = LukashianInstant.ofEpoch(1050, testCalendarKey);
      assertLukashianException(() => instant.plusYears(1));
      assertInstant(4050, testCalendarKey, instant.plusYears(3));
    });

    test('testMinusDays', () {
      assertInstant(150, testCalendarKey, LukashianInstant.ofEpoch(450, testCalendarKey).minusDays(1));
      assertLukashianException(() => LukashianInstant.ofEpoch(450, testCalendarKey).minusDays(2));
    });

    test('testPlusDays', () {
      assertInstant(750, testCalendarKey, LukashianInstant.ofEpoch(450, testCalendarKey).plusDays(1));
      assertLukashianException(() => LukashianInstant.ofEpoch(450, testCalendarKey).plusDays(17));
    });

    test('testAtPreviousDay', () {
      assertInstant(150, testCalendarKey, LukashianInstant.ofEpoch(450, testCalendarKey).atPreviousDay());
    });

    test('testAtNextDay', () {
      assertInstant(750, testCalendarKey, LukashianInstant.ofEpoch(450, testCalendarKey).atNextDay());
    });

    test('testMinusMilliseconds', () {
      final instant = LukashianInstant.ofEpoch(450, testCalendarKey);
      assertLukashianException(() => instant.minusMilliseconds(450));
      assertInstant(1, testCalendarKey, instant.minusMilliseconds(449));
      assertInstant(450, testCalendarKey, instant.minusMilliseconds(0));
      assertInstant(6450, testCalendarKey, instant.minusMilliseconds(-6000));
    });

    test('testMinusSeconds', () {
      assertInstant(1000, testCalendarKey, LukashianInstant.ofEpoch(2000, testCalendarKey).minusSeconds(1));
    });

    test('testPlusMilliseconds', () {
      final instant = LukashianInstant.ofEpoch(450, testCalendarKey);
      assertLukashianException(() => instant.plusMilliseconds(-450));
      assertInstant(650, testCalendarKey, instant.plusMilliseconds(200));
      assertInstant(6450, testCalendarKey, instant.plusMilliseconds(6000));
      assertInstant(250, testCalendarKey, instant.plusMilliseconds(-200));
    });

    test('testPlusSeconds', () {
      assertInstant(3000, testCalendarKey, LukashianInstant.ofEpoch(2000, testCalendarKey).plusSeconds(1));
    });

    test('testMinusBeeps', () {
      final instant = LukashianInstant.ofEpoch(1651, testCalendarKey);
      assertLukashianException(() => instant.minusBeeps(55034));
      assertInstant(1, testCalendarKey, instant.minusBeeps(54999));
      assertInstant(1651, testCalendarKey, instant.minusBeeps(0));
      assertInstant(1951, testCalendarKey, instant.minusBeeps(-10000));
    });

    test('testPlusBeeps', () {
      final instant = LukashianInstant.ofEpoch(1651, testCalendarKey);
      assertInstant(1651, testCalendarKey, instant.plusBeeps(0));
      assertInstant(2551, testCalendarKey, instant.plusBeeps(30000));
    });

    test('testIsBefore', () {
      expect(LukashianInstant.ofEpoch(1, testCalendarKey).isBefore(LukashianInstant.ofEpoch(2, testCalendarKey)), isTrue);
      expect(LukashianInstant.ofEpoch(1, testCalendarKey).isBefore(LukashianInstant.ofEpoch(1, testCalendarKey)), isFalse);
      expect(LukashianInstant.ofEpoch(2, testCalendarKey).isBefore(LukashianInstant.ofEpoch(1, testCalendarKey)), isFalse);
      assertLukashianException(() => LukashianInstant.ofEpoch(1).isBefore(LukashianInstant.ofEpoch(2, CalendarKeys.earth)));
    });

    test('testIsSameOrBefore', () {
      expect(LukashianInstant.ofEpoch(1, testCalendarKey).isSameOrBefore(LukashianInstant.ofEpoch(2, testCalendarKey)), isTrue);
      expect(LukashianInstant.ofEpoch(1, testCalendarKey).isSameOrBefore(LukashianInstant.ofEpoch(1, testCalendarKey)), isTrue);
      assertLukashianException(() => LukashianInstant.ofEpoch(1).isSameOrBefore(LukashianInstant.ofEpoch(2, CalendarKeys.earth)));
    });

    test('testIsAfter', () {
      expect(LukashianInstant.ofEpoch(1, testCalendarKey).isAfter(LukashianInstant.ofEpoch(2, testCalendarKey)), isFalse);
      expect(LukashianInstant.ofEpoch(2, testCalendarKey).isAfter(LukashianInstant.ofEpoch(1, testCalendarKey)), isTrue);
      assertLukashianException(() => LukashianInstant.ofEpoch(1).isAfter(LukashianInstant.ofEpoch(2, CalendarKeys.earth)));
    });

    test('testIsSameOrAfter', () {
      expect(LukashianInstant.ofEpoch(1, testCalendarKey).isSameOrAfter(LukashianInstant.ofEpoch(2, testCalendarKey)), isFalse);
      expect(LukashianInstant.ofEpoch(2, testCalendarKey).isSameOrAfter(LukashianInstant.ofEpoch(1, testCalendarKey)), isTrue);
      assertLukashianException(() => LukashianInstant.ofEpoch(1).isSameOrAfter(LukashianInstant.ofEpoch(2, CalendarKeys.earth)));
    });

    test('testIsIn', () {
      expect(LukashianInstant.ofEpoch(1, testCalendarKey).isIn(Year.of(1)), isTrue);
      expect(LukashianInstant.ofEpoch(1000, testCalendarKey).isIn(Year.of(1)), isTrue);
      expect(LukashianInstant.ofEpoch(1001, testCalendarKey).isIn(Year.of(1)), isFalse);
      expect(LukashianInstant.ofEpoch(1, testCalendarKey).isIn(Day.ofEpoch(1, testCalendarKey)), isTrue);
      expect(LukashianInstant.ofEpoch(301, testCalendarKey).isIn(Day.ofEpoch(1, testCalendarKey)), isFalse);
      assertLukashianException(() => LukashianInstant.ofEpoch(1).isIn(Day.ofEpoch(2, CalendarKeys.earth)));
      assertLukashianException(() => LukashianInstant.ofEpoch(1).isIn(Year.of(2, CalendarKeys.earth)));
    });

    test('testIsNotIn', () {
      expect(LukashianInstant.ofEpoch(1001, testCalendarKey).isNotIn(Year.of(1)), isTrue);
      expect(LukashianInstant.ofEpoch(301, testCalendarKey).isNotIn(Day.ofEpoch(1, testCalendarKey)), isTrue);
    });

    test('testGetEpochMilliseconds', () {
      expect(LukashianInstant.ofEpoch(1, testCalendarKey).getEpochMilliseconds(), 1);
      expect(LukashianInstant.ofEpoch(39000, testCalendarKey).getEpochMilliseconds(), 39000);
    });

    test('testGetMillisecond', () {
      expect(LukashianInstant.ofEpoch(1, testCalendarKey).getMillisecond(), 1);
    });

    test('testGetDay', () {
      assertDay(1, testCalendarKey, LukashianInstant.ofEpoch(1, testCalendarKey).getDay());
      assertDay(2, testCalendarKey, LukashianInstant.ofEpoch(301, testCalendarKey).getDay());
      assertDay(17, testCalendarKey, LukashianInstant.ofEpoch(4800, testCalendarKey).getDay());
      assertDay(18, testCalendarKey, LukashianInstant.ofEpoch(39000, testCalendarKey).getDay());
    });

    test('testGetYear', () {
      assertYear(1, testCalendarKey, LukashianInstant.ofEpoch(1, testCalendarKey).getYear());
      assertYear(2, testCalendarKey, LukashianInstant.ofEpoch(1001, testCalendarKey).getYear());
      assertYear(8, testCalendarKey, LukashianInstant.ofEpoch(39000, testCalendarKey).getYear());
      assertLukashianException(() => LukashianInstant.ofEpoch(39001, testCalendarKey).getYear());
    });

    test('testGetProportionOfDay', () {
      expect(LukashianInstant.ofEpoch(1, testCalendarKey).getProportionOfDay(), Fraction(0, 1));
      expect(LukashianInstant.ofEpoch(151, testCalendarKey).getProportionOfDay(), Fraction(5, 10));
      expect(LukashianInstant.ofEpoch(300, testCalendarKey).getProportionOfDay(), Fraction(299, 300));
      expect(LukashianInstant.ofEpoch(301, testCalendarKey).getProportionOfDay(), Fraction(0, 1));
    });

    test('testGetBeeps', () {
      expect(LukashianInstant.ofEpoch(1, testCalendarKey).getBeeps(), 0);
      expect(LukashianInstant.ofEpoch(151, testCalendarKey).getBeeps(), 5000);
      expect(LukashianInstant.ofEpoch(300, testCalendarKey).getBeeps(), 9966);
    });

    test('testGetUnixEpochMilliseconds', () {
      final now = DateTime.now().millisecondsSinceEpoch;
      expect(LukashianInstant.ofUnixEpochMilliseconds(now).getUnixEpochMilliseconds(), now);
    });

    test('testToDateTime', () {
      final now = DateTime.now().millisecondsSinceEpoch;
      expect(
        LukashianInstant.ofUnixEpochMilliseconds(now).toDateTime().millisecondsSinceEpoch,
        now,
      );
    });

    test('testDifferenceWith', () {
      expect(LukashianInstant.ofEpoch(1, testCalendarKey).differenceWith(LukashianInstant.ofEpoch(1, testCalendarKey)), 0);
      expect(LukashianInstant.ofEpoch(1, testCalendarKey).differenceWith(LukashianInstant.ofEpoch(4, testCalendarKey)), -3);
      expect(LukashianInstant.ofEpoch(4, testCalendarKey).differenceWith(LukashianInstant.ofEpoch(1, testCalendarKey)), 3);
      assertLukashianException(() => LukashianInstant.ofEpoch(4, testCalendarKey).differenceWith(LukashianInstant.ofEpoch(4, CalendarKeys.earth)));
    });

    test('testOf', () {
      assertLukashianException(() => LukashianInstant.ofEpoch(0, testCalendarKey));
      assertLukashianException(() => LukashianInstant.of(Day.ofEpoch(2, testCalendarKey), Fraction(-1, 1)));
      assertLukashianException(() => LukashianInstant.of(Day.ofEpoch(2, testCalendarKey), Fraction(1, 1)));
      assertLukashianException(() => LukashianInstant.ofBeeps(Day.ofEpoch(2, testCalendarKey), -1));
      assertLukashianException(() => LukashianInstant.ofBeeps(Day.ofEpoch(2, testCalendarKey), 10000));

      assertInstant(1, testCalendarKey, LukashianInstant.of(Day.ofEpoch(1, testCalendarKey), Fraction(0, 1)));
      assertInstant(151, testCalendarKey, LukashianInstant.of(Day.ofEpoch(1, testCalendarKey), Fraction(5, 10)));
      assertInstant(300, testCalendarKey, LukashianInstant.of(Day.ofEpoch(1, testCalendarKey), Fraction(999999999, 1000000000)));

      assertInstant(1, testCalendarKey, LukashianInstant.ofBeeps(Day.ofEpoch(1, testCalendarKey), 0));
      assertInstant(151, testCalendarKey, LukashianInstant.ofBeeps(Day.ofEpoch(1, testCalendarKey), 5000));
      assertInstant(300, testCalendarKey, LukashianInstant.ofBeeps(Day.ofEpoch(1, testCalendarKey), 9999));

      assertInstant(151, testCalendarKey, LukashianInstant.ofYearDay(Year.of(1), 1, Fraction(5, 10)));
      assertInstant(151, testCalendarKey, LukashianInstant.ofYearDayFraction(1, 1, Fraction(5, 10)));

      assertInstant(151, testCalendarKey, LukashianInstant.ofYearDayBeeps(Year.of(1), 1, 5000));
      assertInstant(151, testCalendarKey, LukashianInstant.ofYearDayBeepsKey(1, 1, 5000));

      assertInstant(1, CalendarKeys.earth, LukashianInstant.ofEpoch(1, CalendarKeys.earth));
      assertInstant(1, CalendarKeys.earth, LukashianInstant.ofYearDayFraction(1, 1, Fraction(0, 1), CalendarKeys.earth));
      expect(LukashianInstant.ofDateTime(DateTime.now(), CalendarKeys.earth).getCalendarKey(), CalendarKeys.earth);
    });

    test('testOfUnixEpochMilliseconds', () {
      expect(LukashianInstant.ofUnixEpochMilliseconds(DateTime.now().millisecondsSinceEpoch), isNotNull);
    });

    test('testOfDateTime', () {
      expect(LukashianInstant.ofDateTime(DateTime.now()), isNotNull);
    });

    test('testNow', () {
      expect(LukashianInstant.now().getCalendarKey(), testCalendarKey);
      expect(LukashianInstant.now(CalendarKeys.earth).getCalendarKey(), CalendarKeys.earth);
    });

    test('testCompareTo', () {
      expect(LukashianInstant.ofEpoch(1, testCalendarKey).compareTo(LukashianInstant.ofEpoch(1, testCalendarKey)), 0);
      expect(LukashianInstant.ofEpoch(1, testCalendarKey).compareTo(LukashianInstant.ofEpoch(4, testCalendarKey)), -1);
      expect(LukashianInstant.ofEpoch(4, testCalendarKey).compareTo(LukashianInstant.ofEpoch(1, testCalendarKey)), 1);
      assertLukashianException(() => LukashianInstant.ofEpoch(8).compareTo(LukashianInstant.ofEpoch(4, CalendarKeys.earth)));
    });

    test('testHashCode', () {
      expect(LukashianInstant.ofEpoch(2, testCalendarKey).hashCode, LukashianInstant.ofEpoch(2, testCalendarKey).hashCode);
      expect(LukashianInstant.ofEpoch(2, testCalendarKey).hashCode, isNot(LukashianInstant.ofEpoch(2, CalendarKeys.earth).hashCode));
    });

    test('testEquals', () {
      expect(LukashianInstant.ofEpoch(1, testCalendarKey) == LukashianInstant.ofEpoch(1, testCalendarKey), isTrue);
      expect(LukashianInstant.ofEpoch(1, testCalendarKey) == LukashianInstant.ofEpoch(1, CalendarKeys.earth), isFalse);
      expect(LukashianInstant.ofEpoch(1, testCalendarKey) == LukashianInstant.ofEpoch(2, testCalendarKey), isFalse);
      expect(LukashianInstant.ofEpoch(1, testCalendarKey) == Year.of(1), isFalse);
      expect(
        LukashianInstant.ofYearDayFraction(1, 1, Fraction(600000000, 1000000000)) ==
            LukashianInstant.ofYearDayFraction(1, 1, Fraction(600000000, 1000000000)),
        isTrue,
      );
    });

    test('testToString', () {
      expect(LukashianInstant.ofEpoch(2, testCalendarKey).toString(), '[Instant: 1-1 0033]');
    });
  });
}
