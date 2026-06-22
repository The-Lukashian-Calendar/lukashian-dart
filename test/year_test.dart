/*
 * Copyright (c) 2018-2026 (5918-5926 in Lukashian years)
 * All rights reserved.
 *
 * The Lukashian Calendar and The Lukashian Calendar Mechanism are registered
 * at the Benelux Office for Intellectual Property, registration number 120712.
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

import 'package:lukashian/lukashian.dart';
import 'package:test/test.dart';

import 'helpers/lukashian_assert.dart';
import 'helpers/test_millisecond_store_data_provider.dart';

void main() {
  setUpAll(() {
    final store = MillisecondStore.store();
    store.loadProvider(testCalendarKey, TestMillisecondStoreDataProvider());
    store.loadProvider(CalendarKeys.earth, TestMillisecondStoreDataProvider());
    store.setDefaultCalendarKey(testCalendarKey);
  });

  group('Year', () {
    test('testMinusYears', () {
      final year = Year.of(2);

      assertLukashianException(() => year.minusYears(3));
      assertLukashianException(() => year.minusYears(2));
      assertYear(1, testCalendarKey, year.minusYears(1));
      assertYear(2, testCalendarKey, year.minusYears(0));
      assertYear(3, testCalendarKey, year.minusYears(-1));
      assertYear(4, testCalendarKey, year.minusYears(-2));
      assertLukashianException(() => year.minusYears(-7));
    });

    test('testPlusYears', () {
      final year = Year.of(2);

      assertLukashianException(() => year.plusYears(7));
      assertYear(4, testCalendarKey, year.plusYears(2));
      assertYear(3, testCalendarKey, year.plusYears(1));
      assertYear(2, testCalendarKey, year.plusYears(0));
      assertYear(1, testCalendarKey, year.plusYears(-1));
      assertLukashianException(() => year.plusYears(-2));
      assertLukashianException(() => year.plusYears(-3));
    });

    test('testPrevious', () {
      assertYear(1, testCalendarKey, Year.of(2).previous());
    });

    test('testNext', () {
      assertYear(3, testCalendarKey, Year.of(2).next());
    });

    test('testAtDay', () {
      assertLukashianException(() => Year.of(1).atDay(-1));
      assertLukashianException(() => Year.of(1).atDay(0));
      assertDay(1, testCalendarKey, Year.of(1).atDay(1));
      assertDay(2, testCalendarKey, Year.of(1).atDay(2));
      assertDay(3, testCalendarKey, Year.of(1).atDay(3));
      assertDay(4, testCalendarKey, Year.of(1).atDay(4));
      assertLukashianException(() => Year.of(1).atDay(5));
      assertDay(5, testCalendarKey, Year.of(2).atDay(1));
      assertDay(6, testCalendarKey, Year.of(2).atDay(2));
      assertDay(7, testCalendarKey, Year.of(2).atDay(3));
      assertLukashianException(() => Year.of(2).atDay(4));
      assertDay(8, testCalendarKey, Year.of(3).atDay(1));
      assertDay(9, testCalendarKey, Year.of(3).atDay(2));
      assertDay(10, testCalendarKey, Year.of(3).atDay(3));
      assertLukashianException(() => Year.of(3).atDay(4));
      assertDay(11, testCalendarKey, Year.of(4).atDay(1));
      assertDay(12, testCalendarKey, Year.of(4).atDay(2));
      assertDay(13, testCalendarKey, Year.of(4).atDay(3));
      assertDay(14, testCalendarKey, Year.of(4).atDay(4));
      assertLukashianException(() => Year.of(4).atDay(5));
      assertDay(15, testCalendarKey, Year.of(5).atDay(1));
      assertLukashianException(() => Year.of(5).atDay(2));
      assertDay(16, testCalendarKey, Year.of(6).atDay(1));
      assertDay(17, testCalendarKey, Year.of(6).atDay(2));
      assertLukashianException(() => Year.of(6).atDay(3));
      assertDay(18, testCalendarKey, Year.of(7).atDay(1));
      assertLukashianException(() => Year.of(7).atDay(2));
      assertLukashianException(() => Year.of(8).atDay(1));
    });

    test('testFirstDay', () {
      assertDay(1, testCalendarKey, Year.of(1).firstDay());
      assertDay(5, testCalendarKey, Year.of(2).firstDay());
      assertDay(8, testCalendarKey, Year.of(3).firstDay());
      assertDay(11, testCalendarKey, Year.of(4).firstDay());
      assertDay(15, testCalendarKey, Year.of(5).firstDay());
      assertDay(16, testCalendarKey, Year.of(6).firstDay());
      assertDay(18, testCalendarKey, Year.of(7).firstDay());
      assertLukashianException(() => Year.of(8).firstDay());

      assertYear(1, testCalendarKey, Year.of(1).firstDay().getYear());
      assertYear(2, testCalendarKey, Year.of(2).firstDay().getYear());
      assertYear(3, testCalendarKey, Year.of(3).firstDay().getYear());
      assertYear(4, testCalendarKey, Year.of(4).firstDay().getYear());
      assertYear(5, testCalendarKey, Year.of(5).firstDay().getYear());
      assertYear(6, testCalendarKey, Year.of(6).firstDay().getYear());
      assertYear(7, testCalendarKey, Year.of(7).firstDay().getYear());
    });

    test('testLastDay', () {
      assertDay(4, testCalendarKey, Year.of(1).lastDay());
      assertDay(7, testCalendarKey, Year.of(2).lastDay());
      assertDay(10, testCalendarKey, Year.of(3).lastDay());
      assertDay(14, testCalendarKey, Year.of(4).lastDay());
      assertDay(15, testCalendarKey, Year.of(5).lastDay());
      assertDay(17, testCalendarKey, Year.of(6).lastDay());
      assertDay(18, testCalendarKey, Year.of(7).lastDay());
      assertLukashianException(() => Year.of(8).lastDay());

      assertYear(1, testCalendarKey, Year.of(1).lastDay().getYear());
      assertYear(2, testCalendarKey, Year.of(2).lastDay().getYear());
      assertYear(3, testCalendarKey, Year.of(3).lastDay().getYear());
      assertYear(4, testCalendarKey, Year.of(4).lastDay().getYear());
      assertYear(5, testCalendarKey, Year.of(5).lastDay().getYear());
      assertYear(6, testCalendarKey, Year.of(6).lastDay().getYear());
      assertYear(7, testCalendarKey, Year.of(7).lastDay().getYear());
    });

    test('testFirstInstant', () {
      assertInstant(1, testCalendarKey, Year.of(1).firstInstant());
      assertInstant(1001, testCalendarKey, Year.of(2).firstInstant());
      assertInstant(2001, testCalendarKey, Year.of(3).firstInstant());
      assertInstant(3001, testCalendarKey, Year.of(4).firstInstant());
      assertInstant(4001, testCalendarKey, Year.of(5).firstInstant());
      assertInstant(4500, testCalendarKey, Year.of(6).firstInstant());
      assertInstant(4801, testCalendarKey, Year.of(7).firstInstant());
      assertInstant(5001, testCalendarKey, Year.of(8).firstInstant());

      assertYear(1, testCalendarKey, Year.of(1).firstInstant().getYear());
      assertYear(2, testCalendarKey, Year.of(2).firstInstant().getYear());
      assertYear(3, testCalendarKey, Year.of(3).firstInstant().getYear());
      assertYear(4, testCalendarKey, Year.of(4).firstInstant().getYear());
      assertYear(5, testCalendarKey, Year.of(5).firstInstant().getYear());
      assertYear(6, testCalendarKey, Year.of(6).firstInstant().getYear());
      assertYear(7, testCalendarKey, Year.of(7).firstInstant().getYear());
      assertYear(8, testCalendarKey, Year.of(8).firstInstant().getYear());
    });

    test('testLastInstant', () {
      assertInstant(1000, testCalendarKey, Year.of(1).lastInstant());
      assertInstant(2000, testCalendarKey, Year.of(2).lastInstant());
      assertInstant(3000, testCalendarKey, Year.of(3).lastInstant());
      assertInstant(4000, testCalendarKey, Year.of(4).lastInstant());
      assertInstant(4499, testCalendarKey, Year.of(5).lastInstant());
      assertInstant(4800, testCalendarKey, Year.of(6).lastInstant());
      assertInstant(5000, testCalendarKey, Year.of(7).lastInstant());

      assertYear(1, testCalendarKey, Year.of(1).lastInstant().getYear());
      assertYear(2, testCalendarKey, Year.of(2).lastInstant().getYear());
      assertYear(3, testCalendarKey, Year.of(3).lastInstant().getYear());
      assertYear(4, testCalendarKey, Year.of(4).lastInstant().getYear());
      assertYear(5, testCalendarKey, Year.of(5).lastInstant().getYear());
      assertYear(6, testCalendarKey, Year.of(6).lastInstant().getYear());
      assertYear(7, testCalendarKey, Year.of(7).lastInstant().getYear());
    });

    test('testIsBefore', () {
      expect(Year.of(1).isBefore(Year.of(2)), isTrue);
      expect(Year.of(1).isBefore(Year.of(1)), isFalse);
      expect(Year.of(2).isBefore(Year.of(1)), isFalse);
      assertLukashianException(() => Year.of(1).isBefore(Year.of(2, CalendarKeys.earth)));
    });

    test('testIsSameOrBefore', () {
      expect(Year.of(1).isSameOrBefore(Year.of(2)), isTrue);
      expect(Year.of(1).isSameOrBefore(Year.of(1)), isTrue);
      expect(Year.of(2).isSameOrBefore(Year.of(1)), isFalse);
      assertLukashianException(() => Year.of(1).isSameOrBefore(Year.of(2, CalendarKeys.earth)));
    });

    test('testIsAfter', () {
      expect(Year.of(1).isAfter(Year.of(2)), isFalse);
      expect(Year.of(1).isAfter(Year.of(1)), isFalse);
      expect(Year.of(2).isAfter(Year.of(1)), isTrue);
      assertLukashianException(() => Year.of(1).isAfter(Year.of(2, CalendarKeys.earth)));
    });

    test('testIsSameOrAfter', () {
      expect(Year.of(1).isSameOrAfter(Year.of(2)), isFalse);
      expect(Year.of(1).isSameOrAfter(Year.of(1)), isTrue);
      expect(Year.of(2).isSameOrAfter(Year.of(1)), isTrue);
      assertLukashianException(() => Year.of(1).isSameOrAfter(Year.of(2, CalendarKeys.earth)));
    });

    test('testContains', () {
      final year = Year.of(2);

      expect(year.containsInstant(year.firstInstant()), isTrue);
      expect(year.containsInstant(year.lastInstant()), isTrue);

      expect(Year.of(1).containsDay(Day.ofEpoch(1, testCalendarKey)), isTrue);
      expect(Year.of(1).containsDay(Day.ofEpoch(4, testCalendarKey)), isTrue);
      expect(Year.of(1).containsDay(Day.ofEpoch(5, testCalendarKey)), isFalse);

      expect(Year.of(1).containsInstant(Instant.ofEpoch(1, testCalendarKey)), isTrue);
      expect(Year.of(1).containsInstant(Instant.ofEpoch(999, testCalendarKey)), isTrue);
      expect(Year.of(1).containsInstant(Instant.ofEpoch(1000, testCalendarKey)), isTrue);
      expect(Year.of(1).containsInstant(Instant.ofEpoch(1001, testCalendarKey)), isFalse);

      expect(Year.of(3).containsInstant(Instant.ofEpoch(2999, testCalendarKey)), isTrue);
      expect(Year.of(3).containsInstant(Instant.ofEpoch(3000, testCalendarKey)), isTrue);
      expect(Year.of(3).containsInstant(Instant.ofEpoch(3001, testCalendarKey)), isFalse);

      expect(Year.of(4).containsInstant(Instant.ofEpoch(2999, testCalendarKey)), isFalse);
      expect(Year.of(4).containsInstant(Instant.ofEpoch(3000, testCalendarKey)), isFalse);
      expect(Year.of(4).containsInstant(Instant.ofEpoch(3001, testCalendarKey)), isTrue);
      expect(Year.of(4).containsInstant(Instant.ofEpoch(4000, testCalendarKey)), isTrue);
      expect(Year.of(4).containsInstant(Instant.ofEpoch(4001, testCalendarKey)), isFalse);

      assertLukashianException(() => Year.of(1).containsDay(Day.ofEpoch(2, CalendarKeys.earth)));
      assertLukashianException(() => Year.of(1).containsInstant(Instant.ofEpoch(2, CalendarKeys.earth)));
    });

    test('testContainsNot', () {
      final year = Year.of(2);

      expect(year.containsNotInstant(year.firstInstant()), isFalse);
      expect(year.containsNotInstant(year.lastInstant()), isFalse);

      expect(Year.of(1).containsNotDay(Day.ofEpoch(1, testCalendarKey)), isFalse);
      expect(Year.of(1).containsNotDay(Day.ofEpoch(4, testCalendarKey)), isFalse);
      expect(Year.of(1).containsNotDay(Day.ofEpoch(5, testCalendarKey)), isTrue);

      expect(Year.of(1).containsNotInstant(Instant.ofEpoch(1, testCalendarKey)), isFalse);
      expect(Year.of(1).containsNotInstant(Instant.ofEpoch(999, testCalendarKey)), isFalse);
      expect(Year.of(1).containsNotInstant(Instant.ofEpoch(1000, testCalendarKey)), isFalse);
      expect(Year.of(1).containsNotInstant(Instant.ofEpoch(1001, testCalendarKey)), isTrue);

      expect(Year.of(3).containsNotInstant(Instant.ofEpoch(2999, testCalendarKey)), isFalse);
      expect(Year.of(3).containsNotInstant(Instant.ofEpoch(3000, testCalendarKey)), isFalse);
      expect(Year.of(3).containsNotInstant(Instant.ofEpoch(3001, testCalendarKey)), isTrue);

      expect(Year.of(4).containsNotInstant(Instant.ofEpoch(2999, testCalendarKey)), isTrue);
      expect(Year.of(4).containsNotInstant(Instant.ofEpoch(3000, testCalendarKey)), isTrue);
      expect(Year.of(4).containsNotInstant(Instant.ofEpoch(3001, testCalendarKey)), isFalse);
      expect(Year.of(4).containsNotInstant(Instant.ofEpoch(4000, testCalendarKey)), isFalse);
      expect(Year.of(4).containsNotInstant(Instant.ofEpoch(4001, testCalendarKey)), isTrue);

      assertLukashianException(() => Year.of(1).containsNotDay(Day.ofEpoch(2, CalendarKeys.earth)));
      assertLukashianException(() => Year.of(1).containsNotInstant(Instant.ofEpoch(2, CalendarKeys.earth)));
    });

    test('testLengthInMilliseconds', () {
      expect(Year.of(1).lengthInMilliseconds(), 1000);
      expect(Year.of(2).lengthInMilliseconds(), 1000);
      expect(Year.of(3).lengthInMilliseconds(), 1000);
      expect(Year.of(4).lengthInMilliseconds(), 1000);
      expect(Year.of(5).lengthInMilliseconds(), 499);
      expect(Year.of(6).lengthInMilliseconds(), 301);
      expect(Year.of(7).lengthInMilliseconds(), 200);
      expect(Year.of(8).lengthInMilliseconds(), 35000);
    });

    test('testGetNumberOfDays', () {
      expect(Year.of(1).getNumberOfDays(), 4);
      expect(Year.of(2).getNumberOfDays(), 3);
      expect(Year.of(3).getNumberOfDays(), 3);
      expect(Year.of(4).getNumberOfDays(), 4);
      expect(Year.of(5).getNumberOfDays(), 1);
      expect(Year.of(6).getNumberOfDays(), 2);
      expect(Year.of(7).getNumberOfDays(), 1);
      assertLukashianException(() => Year.of(8).getNumberOfDays());
    });

    test('testGetYearNumber', () {
      expect(Year.of(2).getYearNumber(), 2);
    });

    test('testGetEpochMilliseconds', () {
      expect(Year.of(1).getEpochMilliseconds(), 1000);
      expect(Year.of(2).getEpochMilliseconds(), 2000);
      expect(Year.of(3).getEpochMilliseconds(), 3000);
      expect(Year.of(4).getEpochMilliseconds(), 4000);
      expect(Year.of(5).getEpochMilliseconds(), 4499);
      expect(Year.of(6).getEpochMilliseconds(), 4800);
      expect(Year.of(7).getEpochMilliseconds(), 5000);
      expect(Year.of(8).getEpochMilliseconds(), 40000);
    });

    test('testGetEpochMillisecondsPreviousYear', () {
      expect(Year.of(1).getEpochMillisecondsPreviousYear(), 0);
      expect(Year.of(2).getEpochMillisecondsPreviousYear(), 1000);
      expect(Year.of(3).getEpochMillisecondsPreviousYear(), 2000);
      expect(Year.of(4).getEpochMillisecondsPreviousYear(), 3000);
      expect(Year.of(5).getEpochMillisecondsPreviousYear(), 4000);
      expect(Year.of(6).getEpochMillisecondsPreviousYear(), 4499);
      expect(Year.of(7).getEpochMillisecondsPreviousYear(), 4800);
      expect(Year.of(8).getEpochMillisecondsPreviousYear(), 5000);
    });

    test('testGetEpochMillisecondsAtStartOfYear', () {
      expect(Year.of(1).getEpochMillisecondsAtStartOfYear(), 1);
      expect(Year.of(2).getEpochMillisecondsAtStartOfYear(), 1001);
      expect(Year.of(3).getEpochMillisecondsAtStartOfYear(), 2001);
      expect(Year.of(4).getEpochMillisecondsAtStartOfYear(), 3001);
      expect(Year.of(5).getEpochMillisecondsAtStartOfYear(), 4001);
      expect(Year.of(6).getEpochMillisecondsAtStartOfYear(), 4500);
      expect(Year.of(7).getEpochMillisecondsAtStartOfYear(), 4801);
      expect(Year.of(8).getEpochMillisecondsAtStartOfYear(), 5001);
    });

    test('testDifferenceWith', () {
      expect(Year.of(1).differenceWith(Year.of(1)), 0);
      expect(Year.of(1).differenceWith(Year.of(2)), -1);
      expect(Year.of(1).differenceWith(Year.of(3)), -2);
      expect(Year.of(1).differenceWith(Year.of(4)), -3);
      expect(Year.of(4).differenceWith(Year.of(1)), 3);
      expect(Year.of(4).differenceWith(Year.of(2)), 2);
      expect(Year.of(4).differenceWith(Year.of(3)), 1);
      expect(Year.of(4).differenceWith(Year.of(4)), 0);
      assertLukashianException(() => Year.of(8).differenceWith(Year.of(4, CalendarKeys.earth)));
    });

    test('testNow', () {
      expect(Year.now().getCalendarKey(), testCalendarKey);
      expect(Year.now(CalendarKeys.earth).getCalendarKey(), CalendarKeys.earth);
    });

    test('testCompareTo', () {
      expect(Year.of(1).compareTo(Year.of(1)), 0);
      expect(Year.of(1).compareTo(Year.of(2)), -1);
      expect(Year.of(1).compareTo(Year.of(3)), -2);
      expect(Year.of(1).compareTo(Year.of(4)), -3);
      expect(Year.of(4).compareTo(Year.of(1)), 3);
      expect(Year.of(4).compareTo(Year.of(2)), 2);
      expect(Year.of(4).compareTo(Year.of(3)), 1);
      expect(Year.of(4).compareTo(Year.of(4)), 0);
      assertLukashianException(() => Year.of(8).compareTo(Year.of(4, CalendarKeys.earth)));
    });

    test('testHashCode', () {
      expect(Year.of(2, testCalendarKey).hashCode, Year.of(2, testCalendarKey).hashCode);
      expect(Year.of(2, testCalendarKey).hashCode, isNot(Year.of(2, CalendarKeys.earth).hashCode));
      expect(Year.of(2, testCalendarKey).hashCode, isNot(Year.of(3, testCalendarKey).hashCode));
    });

    test('testEquals', () {
      expect(Year.of(1, testCalendarKey) == Year.of(1, testCalendarKey), isTrue);
      expect(Year.of(1, testCalendarKey) == Year.of(1, CalendarKeys.earth), isFalse);
      expect(Year.of(1, testCalendarKey) == Year.of(2, testCalendarKey), isFalse);
      expect(Year.of(1, testCalendarKey) == Day.ofEpoch(1, testCalendarKey), isFalse);
    });

    test('testToString', () {
      expect(Year.of(2).toString(), '[Year: 2]');
    });
  });
}
