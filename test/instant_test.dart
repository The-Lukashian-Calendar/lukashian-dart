/*
 * Copyright (c) 2018-2026 (5918-5926 in Lukashian years)
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 * 1. Redistributions of source code must retain the above copyright
 *    notice, the above registration notice, this list of conditions
 *    and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, the above registration notice, this list of conditions
 *    and the following disclaimer in the documentation and/or other materials
 *    provided with the distribution.
 * 3. All materials mentioning features or use of this software,
 *    the Lukashian Calendar or the underlying Lukashian Calendar Mechanism,
 *    with or without modification, must refer to the Calendar as "The
 *    Lukashian Calendar" and to the Calendar Mechanism as "The Lukashian
 *    Calendar Mechanism".
 * 4. Renaming of source code, binary form, the Lukashian Calendar or the
 *    Lukashian Calendar Mechanism, with or without modification, is explicitly
 *    disallowed.
 * 5. Any copies, extracts, code excerpts, forks, redistributions
 *    or translations into other languages of source code, binary form,
 *    the functional behaviour of the Lukashian Calendar as defined by source code or
 *    the functional behaviour of the Lukashian Calendar Mechanism as defined by source
 *    code, with or without modification, may not include modifications that
 *    change the functional behaviour of the Lukashian Calendar Mechanism as
 *    implemented by source code.
 *
 * THIS SOFTWARE IS PROVIDED BY COPYRIGHT HOLDER "AS IS" AND ANY
 * EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL COPYRIGHT HOLDER BE LIABLE FOR ANY
 * DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

import 'package:fraction/fraction.dart';
import 'package:test/test.dart';

import 'package:lukashian/lukashian.dart';
import 'helpers/lukashian_assert.dart';
import 'helpers/test_millisecond_store_data_provider.dart';

const int _toCalendarSourceKey = testCalendarKey + 1;
const int _toCalendarTargetKey = testCalendarKey + 2;

void main() {
  setUpAll(() {
    final store = MillisecondStore.store();
    store.loadProvider(testCalendarKey, TestMillisecondStoreDataProvider());
    store.loadProvider(CalendarKeys.earth, TestMillisecondStoreDataProvider());
    store.loadProvider(_toCalendarSourceKey, ConstantOffsetTestProvider(0));
    store.loadProvider(_toCalendarTargetKey, ConstantOffsetTestProvider(1000));
    store.setDefaultCalendarKey(testCalendarKey);
  });

  tearDownAll(() {
    final store = MillisecondStore.store();
    store.clearData(testCalendarKey);
    store.clearData(CalendarKeys.earth);
    store.clearData(_toCalendarSourceKey);
    store.clearData(_toCalendarTargetKey);
  });

  group('Instant', () {
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
      assertInstant(150, testCalendarKey, Instant.ofEpoch(450, testCalendarKey).minusDays(1));
      assertLukashianException(() => Instant.ofEpoch(450, testCalendarKey).minusDays(2));
    });

    test('testPlusDays', () {
      assertInstant(750, testCalendarKey, Instant.ofEpoch(450, testCalendarKey).plusDays(1));
      assertLukashianException(() => Instant.ofEpoch(450, testCalendarKey).plusDays(17));
    });

    test('testAtPreviousDay', () {
      assertInstant(150, testCalendarKey, Instant.ofEpoch(450, testCalendarKey).atPreviousDay());
    });

    test('testAtNextDay', () {
      assertInstant(750, testCalendarKey, Instant.ofEpoch(450, testCalendarKey).atNextDay());
    });

    test('testMinusMilliseconds', () {
      final instant = Instant.ofEpoch(450, testCalendarKey);
      assertLukashianException(() => instant.minusMilliseconds(450));
      assertInstant(1, testCalendarKey, instant.minusMilliseconds(449));
      assertInstant(450, testCalendarKey, instant.minusMilliseconds(0));
      assertInstant(6450, testCalendarKey, instant.minusMilliseconds(-6000));
    });

    test('testMinusSeconds', () {
      assertInstant(1000, testCalendarKey, Instant.ofEpoch(2000, testCalendarKey).minusSeconds(1));
    });

    test('testPlusMilliseconds', () {
      final instant = Instant.ofEpoch(450, testCalendarKey);
      assertLukashianException(() => instant.plusMilliseconds(-450));
      assertInstant(650, testCalendarKey, instant.plusMilliseconds(200));
      assertInstant(6450, testCalendarKey, instant.plusMilliseconds(6000));
      assertInstant(250, testCalendarKey, instant.plusMilliseconds(-200));
    });

    test('testPlusSeconds', () {
      assertInstant(3000, testCalendarKey, Instant.ofEpoch(2000, testCalendarKey).plusSeconds(1));
    });

    test('testMinusBeeps', () {
      final instant = Instant.ofEpoch(1651, testCalendarKey);
      assertLukashianException(() => instant.minusBeeps(55034));
      assertInstant(1, testCalendarKey, instant.minusBeeps(54999));
      assertInstant(1199, testCalendarKey, instant.minusBeeps(15066));
      assertInstant(1200, testCalendarKey, instant.minusBeeps(15010));
      assertInstant(1201, testCalendarKey, instant.minusBeeps(14999));
      assertInstant(1351, testCalendarKey, instant.minusBeeps(10000));
      assertInstant(1499, testCalendarKey, instant.minusBeeps(5066));
      assertInstant(1500, testCalendarKey, instant.minusBeeps(5010));
      assertInstant(1501, testCalendarKey, instant.minusBeeps(4999));
      assertInstant(1621, testCalendarKey, instant.minusBeeps(1000));
      assertInstant(1649, testCalendarKey, instant.minusBeeps(66));
      assertInstant(1651, testCalendarKey, instant.minusBeeps(0));
      assertInstant(1652, testCalendarKey, instant.minusBeeps(-34));
      assertInstant(1681, testCalendarKey, instant.minusBeeps(-1000));
      assertInstant(1799, testCalendarKey, instant.minusBeeps(-4934));
      assertInstant(1800, testCalendarKey, instant.minusBeeps(-4999));
      assertInstant(1801, testCalendarKey, instant.minusBeeps(-5000));
      assertInstant(1951, testCalendarKey, instant.minusBeeps(-10000));
      assertInstant(2099, testCalendarKey, instant.minusBeeps(-14934));
      assertInstant(2100, testCalendarKey, instant.minusBeeps(-14999));
      assertInstant(2101, testCalendarKey, instant.minusBeeps(-15000));
      assertInstant(2551, testCalendarKey, instant.minusBeeps(-30000));
    });

    test('testPlusBeeps', () {
      final instant = Instant.ofEpoch(1651, testCalendarKey);
      assertLukashianException(() => instant.plusBeeps(-55034));
      assertInstant(1, testCalendarKey, instant.plusBeeps(-54999));
      assertInstant(1199, testCalendarKey, instant.plusBeeps(-15066));
      assertInstant(1200, testCalendarKey, instant.plusBeeps(-15010));
      assertInstant(1201, testCalendarKey, instant.plusBeeps(-14999));
      assertInstant(1351, testCalendarKey, instant.plusBeeps(-10000));
      assertInstant(1499, testCalendarKey, instant.plusBeeps(-5066));
      assertInstant(1500, testCalendarKey, instant.plusBeeps(-5010));
      assertInstant(1501, testCalendarKey, instant.plusBeeps(-4999));
      assertInstant(1621, testCalendarKey, instant.plusBeeps(-1000));
      assertInstant(1649, testCalendarKey, instant.plusBeeps(-66));
      assertInstant(1651, testCalendarKey, instant.plusBeeps(0));
      assertInstant(1652, testCalendarKey, instant.plusBeeps(34));
      assertInstant(1681, testCalendarKey, instant.plusBeeps(1000));
      assertInstant(1799, testCalendarKey, instant.plusBeeps(4934));
      assertInstant(1800, testCalendarKey, instant.plusBeeps(4999));
      assertInstant(1801, testCalendarKey, instant.plusBeeps(5000));
      assertInstant(1951, testCalendarKey, instant.plusBeeps(10000));
      assertInstant(2099, testCalendarKey, instant.plusBeeps(14934));
      assertInstant(2100, testCalendarKey, instant.plusBeeps(14999));
      assertInstant(2101, testCalendarKey, instant.plusBeeps(15000));
      assertInstant(2551, testCalendarKey, instant.plusBeeps(30000));
    });

    test('testIsBefore', () {
      expect(Instant.ofEpoch(1, testCalendarKey).isBefore(Instant.ofEpoch(2, testCalendarKey)), isTrue);
      expect(Instant.ofEpoch(1, testCalendarKey).isBefore(Instant.ofEpoch(1, testCalendarKey)), isFalse);
      expect(Instant.ofEpoch(2, testCalendarKey).isBefore(Instant.ofEpoch(1, testCalendarKey)), isFalse);
      assertLukashianException(() => Instant.ofEpoch(1).isBefore(Instant.ofEpoch(2, CalendarKeys.earth)));
    });

    test('testIsSameOrBefore', () {
      expect(Instant.ofEpoch(1, testCalendarKey).isSameOrBefore(Instant.ofEpoch(2, testCalendarKey)), isTrue);
      expect(Instant.ofEpoch(1, testCalendarKey).isSameOrBefore(Instant.ofEpoch(1, testCalendarKey)), isTrue);
      expect(Instant.ofEpoch(2, testCalendarKey).isSameOrBefore(Instant.ofEpoch(1, testCalendarKey)), isFalse);
      assertLukashianException(() => Instant.ofEpoch(1).isSameOrBefore(Instant.ofEpoch(2, CalendarKeys.earth)));
    });

    test('testIsAfter', () {
      expect(Instant.ofEpoch(1, testCalendarKey).isAfter(Instant.ofEpoch(2, testCalendarKey)), isFalse);
      expect(Instant.ofEpoch(1, testCalendarKey).isAfter(Instant.ofEpoch(1, testCalendarKey)), isFalse);
      expect(Instant.ofEpoch(2, testCalendarKey).isAfter(Instant.ofEpoch(1, testCalendarKey)), isTrue);
      assertLukashianException(() => Instant.ofEpoch(1).isAfter(Instant.ofEpoch(2, CalendarKeys.earth)));
    });

    test('testIsSameOrAfter', () {
      expect(Instant.ofEpoch(1, testCalendarKey).isSameOrAfter(Instant.ofEpoch(2, testCalendarKey)), isFalse);
      expect(Instant.ofEpoch(1, testCalendarKey).isSameOrAfter(Instant.ofEpoch(1, testCalendarKey)), isTrue);
      expect(Instant.ofEpoch(2, testCalendarKey).isSameOrAfter(Instant.ofEpoch(1, testCalendarKey)), isTrue);
      assertLukashianException(() => Instant.ofEpoch(1).isSameOrAfter(Instant.ofEpoch(2, CalendarKeys.earth)));
    });

    test('testIsIn', () {
      expect(Instant.ofEpoch(1, testCalendarKey).isInYear(Year.of(1)), isTrue);
      expect(Instant.ofEpoch(500, testCalendarKey).isInYear(Year.of(1)), isTrue);
      expect(Instant.ofEpoch(1000, testCalendarKey).isInYear(Year.of(1)), isTrue);
      expect(Instant.ofEpoch(1001, testCalendarKey).isInYear(Year.of(1)), isFalse);
      expect(Instant.ofEpoch(1500, testCalendarKey).isInYear(Year.of(1)), isFalse);
      expect(Instant.ofEpoch(1, testCalendarKey).isInDay(Day.ofEpoch(1, testCalendarKey)), isTrue);
      expect(Instant.ofEpoch(150, testCalendarKey).isInDay(Day.ofEpoch(1, testCalendarKey)), isTrue);
      expect(Instant.ofEpoch(300, testCalendarKey).isInDay(Day.ofEpoch(1, testCalendarKey)), isTrue);
      expect(Instant.ofEpoch(301, testCalendarKey).isInDay(Day.ofEpoch(1, testCalendarKey)), isFalse);
      expect(Instant.ofEpoch(450, testCalendarKey).isInDay(Day.ofEpoch(1, testCalendarKey)), isFalse);
      assertLukashianException(() => Instant.ofEpoch(1).isInDay(Day.ofEpoch(2, CalendarKeys.earth)));
      assertLukashianException(() => Instant.ofEpoch(1).isInYear(Year.of(2, CalendarKeys.earth)));
    });

    test('testIsNotIn', () {
      expect(Instant.ofEpoch(1, testCalendarKey).isNotInYear(Year.of(1)), isFalse);
      expect(Instant.ofEpoch(500, testCalendarKey).isNotInYear(Year.of(1)), isFalse);
      expect(Instant.ofEpoch(1000, testCalendarKey).isNotInYear(Year.of(1)), isFalse);
      expect(Instant.ofEpoch(1001, testCalendarKey).isNotInYear(Year.of(1)), isTrue);
      expect(Instant.ofEpoch(1500, testCalendarKey).isNotInYear(Year.of(1)), isTrue);
      expect(Instant.ofEpoch(1, testCalendarKey).isNotInDay(Day.ofEpoch(1, testCalendarKey)), isFalse);
      expect(Instant.ofEpoch(150, testCalendarKey).isNotInDay(Day.ofEpoch(1, testCalendarKey)), isFalse);
      expect(Instant.ofEpoch(300, testCalendarKey).isNotInDay(Day.ofEpoch(1, testCalendarKey)), isFalse);
      expect(Instant.ofEpoch(301, testCalendarKey).isNotInDay(Day.ofEpoch(1, testCalendarKey)), isTrue);
      expect(Instant.ofEpoch(450, testCalendarKey).isNotInDay(Day.ofEpoch(1, testCalendarKey)), isTrue);
      assertLukashianException(() => Instant.ofEpoch(1).isNotInDay(Day.ofEpoch(2, CalendarKeys.earth)));
      assertLukashianException(() => Instant.ofEpoch(1).isNotInYear(Year.of(2, CalendarKeys.earth)));
    });

    test('testGetEpochMilliseconds', () {
      expect(Instant.ofEpoch(1, testCalendarKey).getEpochMilliseconds(), 1);
      expect(Instant.ofEpoch(10000, testCalendarKey).getEpochMilliseconds(), 10000);
      expect(Instant.ofEpoch(39000, testCalendarKey).getEpochMilliseconds(), 39000);
    });

    test('testGetMillisecond', () {
      expect(Instant.ofEpoch(1, testCalendarKey).getMillisecond(), 1);
      expect(Instant.ofEpoch(10000, testCalendarKey).getMillisecond(), 10000);
      expect(Instant.ofEpoch(39000, testCalendarKey).getMillisecond(), 39000);
    });

    test('testGetDay', () {
      assertDay(1, testCalendarKey, Instant.ofEpoch(1, testCalendarKey).getDay());
      assertDay(1, testCalendarKey, Instant.ofEpoch(150, testCalendarKey).getDay());
      assertDay(1, testCalendarKey, Instant.ofEpoch(300, testCalendarKey).getDay());
      assertDay(2, testCalendarKey, Instant.ofEpoch(301, testCalendarKey).getDay());
      assertDay(15, testCalendarKey, Instant.ofEpoch(4498, testCalendarKey).getDay());
      assertDay(15, testCalendarKey, Instant.ofEpoch(4499, testCalendarKey).getDay());
      assertDay(15, testCalendarKey, Instant.ofEpoch(4500, testCalendarKey).getDay());
      assertDay(16, testCalendarKey, Instant.ofEpoch(4501, testCalendarKey).getDay());
      assertDay(16, testCalendarKey, Instant.ofEpoch(4798, testCalendarKey).getDay());
      assertDay(16, testCalendarKey, Instant.ofEpoch(4799, testCalendarKey).getDay());
      assertDay(17, testCalendarKey, Instant.ofEpoch(4800, testCalendarKey).getDay());
      assertDay(17, testCalendarKey, Instant.ofEpoch(4801, testCalendarKey).getDay());
      assertDay(17, testCalendarKey, Instant.ofEpoch(4899, testCalendarKey).getDay());
      assertDay(17, testCalendarKey, Instant.ofEpoch(4900, testCalendarKey).getDay());
      assertDay(18, testCalendarKey, Instant.ofEpoch(4901, testCalendarKey).getDay());
      assertDay(18, testCalendarKey, Instant.ofEpoch(38999, testCalendarKey).getDay());
      assertDay(18, testCalendarKey, Instant.ofEpoch(39000, testCalendarKey).getDay());
    });

    test('testGetYear', () {
      assertYear(1, testCalendarKey, Instant.ofEpoch(1, testCalendarKey).getYear());
      assertYear(1, testCalendarKey, Instant.ofEpoch(999, testCalendarKey).getYear());
      assertYear(1, testCalendarKey, Instant.ofEpoch(1000, testCalendarKey).getYear());
      assertYear(2, testCalendarKey, Instant.ofEpoch(1001, testCalendarKey).getYear());
      assertYear(3, testCalendarKey, Instant.ofEpoch(2999, testCalendarKey).getYear());
      assertYear(3, testCalendarKey, Instant.ofEpoch(3000, testCalendarKey).getYear());
      assertYear(4, testCalendarKey, Instant.ofEpoch(3001, testCalendarKey).getYear());
      assertYear(5, testCalendarKey, Instant.ofEpoch(4498, testCalendarKey).getYear());
      assertYear(5, testCalendarKey, Instant.ofEpoch(4499, testCalendarKey).getYear());
      assertYear(6, testCalendarKey, Instant.ofEpoch(4500, testCalendarKey).getYear());
      assertYear(6, testCalendarKey, Instant.ofEpoch(4501, testCalendarKey).getYear());
      assertYear(6, testCalendarKey, Instant.ofEpoch(4798, testCalendarKey).getYear());
      assertYear(6, testCalendarKey, Instant.ofEpoch(4799, testCalendarKey).getYear());
      assertYear(6, testCalendarKey, Instant.ofEpoch(4800, testCalendarKey).getYear());
      assertYear(7, testCalendarKey, Instant.ofEpoch(4801, testCalendarKey).getYear());
      assertYear(8, testCalendarKey, Instant.ofEpoch(38999, testCalendarKey).getYear());
      assertYear(8, testCalendarKey, Instant.ofEpoch(39000, testCalendarKey).getYear());
      assertLukashianException(() => Instant.ofEpoch(39001, testCalendarKey).getYear());
    });

    test('testGetProportionOfDay', () {
      expect(Instant.ofEpoch(1, testCalendarKey).getProportionOfDay(), Fraction(0, 1));
      expect(Instant.ofEpoch(151, testCalendarKey).getProportionOfDay(), Fraction(5, 10));
      expect(Instant.ofEpoch(299, testCalendarKey).getProportionOfDay(), Fraction(149, 150));
      expect(Instant.ofEpoch(300, testCalendarKey).getProportionOfDay(), Fraction(299, 300));
      expect(Instant.ofEpoch(301, testCalendarKey).getProportionOfDay(), Fraction(0, 1));
      expect(Instant.ofEpoch(451, testCalendarKey).getProportionOfDay(), Fraction(5, 10));
      expect(Instant.ofEpoch(599, testCalendarKey).getProportionOfDay(), Fraction(149, 150));
      expect(Instant.ofEpoch(600, testCalendarKey).getProportionOfDay(), Fraction(299, 300));
      expect(Instant.ofEpoch(601, testCalendarKey).getProportionOfDay(), Fraction(0, 1));
    });

    test('testGetBeeps', () {
      expect(Instant.ofEpoch(1, testCalendarKey).getBeeps(), 0);
      expect(Instant.ofEpoch(151, testCalendarKey).getBeeps(), 5000);
      expect(Instant.ofEpoch(299, testCalendarKey).getBeeps(), 9933);
      expect(Instant.ofEpoch(300, testCalendarKey).getBeeps(), 9966);
      expect(Instant.ofEpoch(301, testCalendarKey).getBeeps(), 0);
      expect(Instant.ofEpoch(451, testCalendarKey).getBeeps(), 5000);
      expect(Instant.ofEpoch(599, testCalendarKey).getBeeps(), 9933);
      expect(Instant.ofEpoch(600, testCalendarKey).getBeeps(), 9966);
      expect(Instant.ofEpoch(601, testCalendarKey).getBeeps(), 0);
    });

    test('testGetUnixEpochMilliseconds', () {
      final now = DateTime.now().millisecondsSinceEpoch;
      expect(Instant.ofUnixEpochMilliseconds(now).getUnixEpochMilliseconds(), now);
    });

    test('testToDateTime', () {
      final now = DateTime.now().millisecondsSinceEpoch;
      expect(Instant.ofUnixEpochMilliseconds(now).toDateTime().millisecondsSinceEpoch, now);
    });

    test('testToCalendar', () {
      final instant = Instant.ofEpoch(450, _toCalendarSourceKey);
      final converted = instant.toCalendar(_toCalendarTargetKey);
      expect(converted.getEpochMilliseconds() - instant.getEpochMilliseconds(), 1000);
      expect(converted.getCalendarKey(), _toCalendarTargetKey);
    });

    test('testDifferenceWith', () {
      expect(Instant.ofEpoch(1, testCalendarKey).differenceWith(Instant.ofEpoch(1, testCalendarKey)), 0);
      expect(Instant.ofEpoch(1, testCalendarKey).differenceWith(Instant.ofEpoch(2, testCalendarKey)), -1);
      expect(Instant.ofEpoch(1, testCalendarKey).differenceWith(Instant.ofEpoch(3, testCalendarKey)), -2);
      expect(Instant.ofEpoch(1, testCalendarKey).differenceWith(Instant.ofEpoch(4, testCalendarKey)), -3);
      expect(Instant.ofEpoch(4, testCalendarKey).differenceWith(Instant.ofEpoch(1, testCalendarKey)), 3);
      expect(Instant.ofEpoch(4, testCalendarKey).differenceWith(Instant.ofEpoch(2, testCalendarKey)), 2);
      expect(Instant.ofEpoch(4, testCalendarKey).differenceWith(Instant.ofEpoch(3, testCalendarKey)), 1);
      expect(Instant.ofEpoch(4, testCalendarKey).differenceWith(Instant.ofEpoch(4, testCalendarKey)), 0);
      assertLukashianException(
        () => Instant.ofEpoch(4, testCalendarKey).differenceWith(Instant.ofEpoch(4, CalendarKeys.earth)),
      );
      assertLukashianException(
        () => Instant.ofEpoch(4, testCalendarKey).differenceInBeepsWith(Instant.ofEpoch(4, CalendarKeys.earth)),
      );
    });

    test('testOf', () {
      assertLukashianException(() => Instant.ofEpoch(0, testCalendarKey));
      assertLukashianException(() => Instant.of(Day.ofEpoch(2, testCalendarKey), Fraction(-1, 1)));
      assertLukashianException(() => Instant.of(Day.ofEpoch(2, testCalendarKey), Fraction(1, 1)));
      assertLukashianException(() => Instant.of(Day.ofEpoch(2, testCalendarKey), Fraction(2, 1)));
      assertLukashianException(() => Instant.ofBeeps(Day.ofEpoch(2, testCalendarKey), -1));
      assertLukashianException(() => Instant.ofBeeps(Day.ofEpoch(2, testCalendarKey), 10000));
      assertLukashianException(() => Instant.ofBeeps(Day.ofEpoch(2, testCalendarKey), 20000));

      assertInstant(1, testCalendarKey, Instant.of(Day.ofEpoch(1, testCalendarKey), Fraction(0, 1)));
      assertInstant(4, testCalendarKey, Instant.of(Day.ofEpoch(1, testCalendarKey), Fraction(1, 100)));
      assertInstant(151, testCalendarKey, Instant.of(Day.ofEpoch(1, testCalendarKey), Fraction(5, 10)));
      assertInstant(298, testCalendarKey, Instant.of(Day.ofEpoch(1, testCalendarKey), Fraction(99, 100)));
      assertInstant(300, testCalendarKey, Instant.of(Day.ofEpoch(1, testCalendarKey), Fraction(997, 1000)));
      assertInstant(300, testCalendarKey, Instant.of(Day.ofEpoch(1, testCalendarKey), Fraction(999999999, 1000000000)));

      assertInstant(1, testCalendarKey, Instant.ofBeeps(Day.ofEpoch(1, testCalendarKey), 0));
      assertInstant(4, testCalendarKey, Instant.ofBeeps(Day.ofEpoch(1, testCalendarKey), 100));
      assertInstant(151, testCalendarKey, Instant.ofBeeps(Day.ofEpoch(1, testCalendarKey), 5000));
      assertInstant(298, testCalendarKey, Instant.ofBeeps(Day.ofEpoch(1, testCalendarKey), 9900));
      assertInstant(300, testCalendarKey, Instant.ofBeeps(Day.ofEpoch(1, testCalendarKey), 9970));
      assertInstant(300, testCalendarKey, Instant.ofBeeps(Day.ofEpoch(1, testCalendarKey), 9999));

      assertInstant(301, testCalendarKey, Instant.of(Day.ofEpoch(2, testCalendarKey), Fraction(0, 1)));
      assertInstant(304, testCalendarKey, Instant.of(Day.ofEpoch(2, testCalendarKey), Fraction(1, 100)));
      assertInstant(451, testCalendarKey, Instant.of(Day.ofEpoch(2, testCalendarKey), Fraction(5, 10)));
      assertInstant(598, testCalendarKey, Instant.of(Day.ofEpoch(2, testCalendarKey), Fraction(99, 100)));
      assertInstant(600, testCalendarKey, Instant.of(Day.ofEpoch(2, testCalendarKey), Fraction(997, 1000)));
      assertInstant(600, testCalendarKey, Instant.of(Day.ofEpoch(2, testCalendarKey), Fraction(999999999, 1000000000)));

      assertInstant(301, testCalendarKey, Instant.ofBeeps(Day.ofEpoch(2, testCalendarKey), 0));
      assertInstant(304, testCalendarKey, Instant.ofBeeps(Day.ofEpoch(2, testCalendarKey), 100));
      assertInstant(451, testCalendarKey, Instant.ofBeeps(Day.ofEpoch(2, testCalendarKey), 5000));
      assertInstant(598, testCalendarKey, Instant.ofBeeps(Day.ofEpoch(2, testCalendarKey), 9900));
      assertInstant(600, testCalendarKey, Instant.ofBeeps(Day.ofEpoch(2, testCalendarKey), 9970));
      assertInstant(600, testCalendarKey, Instant.ofBeeps(Day.ofEpoch(2, testCalendarKey), 9999));

      assertInstant(151, testCalendarKey, Instant.ofYearDay(Year.of(1), 1, Fraction(5, 10)));
      assertInstant(151, testCalendarKey, Instant.ofYearDayFraction(1, 1, Fraction(5, 10)));

      assertInstant(151, testCalendarKey, Instant.ofYearDayBeeps(Year.of(1), 1, 5000));
      assertInstant(151, testCalendarKey, Instant.ofYearDayBeepsKey(1, 1, 5000));

      assertInstant(1, CalendarKeys.earth, Instant.ofEpoch(1, CalendarKeys.earth));
      assertInstant(1, CalendarKeys.earth, Instant.ofYearDayFraction(1, 1, Fraction(0, 1), CalendarKeys.earth));
      assertInstant(1, CalendarKeys.earth, Instant.ofYearDayBeepsKey(1, 1, 0, CalendarKeys.earth));
      expect(Instant.ofDateTime(DateTime.now(), CalendarKeys.earth).getCalendarKey(), CalendarKeys.earth);
    });

    test('testOfUnixEpochMilliseconds', () {
      expect(Instant.ofUnixEpochMilliseconds(DateTime.now().millisecondsSinceEpoch), isNotNull);
    });

    test('testOfDateTime', () {
      expect(Instant.ofDateTime(DateTime.now()), isNotNull);
    });

    test('testNow', () {
      expect(Instant.now().getCalendarKey(), testCalendarKey);
      expect(Instant.now(CalendarKeys.earth).getCalendarKey(), CalendarKeys.earth);
    });

    test('testCompareTo', () {
      expect(Instant.ofEpoch(1, testCalendarKey).compareTo(Instant.ofEpoch(1, testCalendarKey)), 0);
      expect(Instant.ofEpoch(1, testCalendarKey).compareTo(Instant.ofEpoch(2, testCalendarKey)), -1);
      expect(Instant.ofEpoch(1, testCalendarKey).compareTo(Instant.ofEpoch(3, testCalendarKey)), -1);
      expect(Instant.ofEpoch(1, testCalendarKey).compareTo(Instant.ofEpoch(4, testCalendarKey)), -1);
      expect(Instant.ofEpoch(4, testCalendarKey).compareTo(Instant.ofEpoch(1, testCalendarKey)), 1);
      expect(Instant.ofEpoch(4, testCalendarKey).compareTo(Instant.ofEpoch(2, testCalendarKey)), 1);
      expect(Instant.ofEpoch(4, testCalendarKey).compareTo(Instant.ofEpoch(3, testCalendarKey)), 1);
      expect(Instant.ofEpoch(4, testCalendarKey).compareTo(Instant.ofEpoch(4, testCalendarKey)), 0);
      assertLukashianException(() => Instant.ofEpoch(8).compareTo(Instant.ofEpoch(4, CalendarKeys.earth)));
    });

    test('testHashCode', () {
      expect(Instant.ofEpoch(2, testCalendarKey).hashCode, Instant.ofEpoch(2, testCalendarKey).hashCode);
      expect(Instant.ofEpoch(2, testCalendarKey).hashCode, isNot(Instant.ofEpoch(2, CalendarKeys.earth).hashCode));
      expect(Instant.ofEpoch(2, testCalendarKey).hashCode, isNot(Instant.ofEpoch(3, testCalendarKey).hashCode));
    });

    test('testEquals', () {
      expect(Instant.ofEpoch(1, testCalendarKey) == Instant.ofEpoch(1, testCalendarKey), isTrue);
      expect(Instant.ofEpoch(1, testCalendarKey) == Instant.ofEpoch(1, CalendarKeys.earth), isFalse);
      expect(Instant.ofEpoch(1, testCalendarKey) == Instant.ofEpoch(2, testCalendarKey), isFalse);
      expect(Instant.ofEpoch(1, testCalendarKey) == Year.of(1), isFalse);
      expect(
        Instant.ofYearDayFraction(1, 1, Fraction(600000000, 1000000000)) ==
            Instant.ofYearDayFraction(1, 1, Fraction(600000000, 1000000000)),
        isTrue,
      );
      expect(
        Instant.ofYearDayFraction(1, 1, Fraction(600000000, 1000000000)) ==
            Instant.ofYearDayFraction(1, 1, Fraction(600000001, 1000000000)),
        isTrue,
      );
    });

    test('testToString', () {
      expect(Instant.ofEpoch(2, testCalendarKey).toString(), '[Instant: 1-1 0033]');
    });
  });
}
