/*
 * Copyright (c) 2018-2026 (5918-5926 in Lukashian years)
 * All rights reserved.
 *
 * Network-dependent tests mirroring Java InstantRealCalendarTest.
 * Requires HTTP access to lukashian.org (via [MillisecondStore.init]).
 */

import 'package:fraction/fraction.dart';
import 'package:test/test.dart';

import 'package:lukashian/lukashian.dart';
import 'helpers/lukashian_assert.dart';
import 'helpers/test_millisecond_store_data_provider.dart';

const int _earthKey = CalendarKeys.earthHttpLukashianOrg;
const int _oneSecondBehindKey = 6;

@Tags(['network'])
void main() {
  final store = MillisecondStore.store();

  setUpAll(() async {
    store.loadProvider(testCalendarKey, TestMillisecondStoreDataProvider());
    store.setDefaultCalendarKey(testCalendarKey);
    await store.init();

    final http = StandardEarthHttpMillisecondStoreDataProvider();
    final years = await http.loadYearEpochMilliseconds();
    final days = await http.loadDayEpochMilliseconds(years);
    final earthOffset = await http.loadUnixEpochOffsetMilliseconds();
    store.loadProvider(
      _oneSecondBehindKey,
      _FixedEarthCalendarProvider(
        unixOffset: earthOffset + 1000,
        years: years,
        days: days,
      ),
    );
  });

  tearDownAll(() {
    store.clearAllData();
  });

  group('InstantRealCalendar', () {
    test('testInstantEquality', () {
      for (var i = 1; i <= 100000; i++) {
        _assertInstantEquality(i);
      }

      final today = Day.now(_earthKey);
      final start = today.getEpochMillisecondsAtStartOfDay();
      final end = today.getEpochMilliseconds();
      for (var i = start - 100000; i <= start + 100000; i++) {
        _assertInstantEquality(i);
      }
      for (var i = end - 100000; i <= end + 100000; i++) {
        _assertInstantEquality(i);
      }

      for (var i = 0; i < 10000; i++) {
        final instant = today.atTimeBeeps(i);
        expect(instant.getBeeps(), i);
      }
    });

    test('testMinusProportionOfDay', () {
      final realInstant = Instant.ofBeeps(Day.ofEpoch(4, _earthKey), 5000);
      _expectInstant(
        Instant.ofBeeps(Day.ofEpoch(4, _earthKey), 0),
        realInstant.minusProportionOfDay(
          Fraction(499999999999999999, 1000000000000000000),
        ),
      );
      _expectInstant(
        Instant.ofBeeps(Day.ofEpoch(3, _earthKey), 5001),
        realInstant.minusProportionOfDay(Fraction(9999, 10000)),
      );
      _expectInstant(
        Instant.ofBeeps(Day.ofEpoch(3, _earthKey), 5000),
        realInstant.minusProportionOfDay(
          Fraction(999999999999999999, 1000000000000000000),
        ),
      );
    });

    test('testMinusBeeps', () {
      final realInstant = Instant.ofBeeps(Day.ofEpoch(4, _earthKey), 5000);
      _expectInstant(
        Instant.ofBeeps(Day.ofEpoch(1, _earthKey), 9999),
        realInstant.minusBeeps(25001),
      );
      _expectInstant(
        Instant.ofBeeps(Day.ofEpoch(2, _earthKey), 0),
        realInstant.minusBeeps(25000),
      );
      _expectInstant(
        Instant.ofBeeps(Day.ofEpoch(2, _earthKey), 1),
        realInstant.minusBeeps(24999),
      );
      _expectInstant(
        Instant.ofBeeps(Day.ofEpoch(2, _earthKey), 5000),
        realInstant.minusBeeps(20000),
      );
      _expectInstant(
        Instant.ofBeeps(Day.ofEpoch(3, _earthKey), 5000),
        realInstant.minusBeeps(10000),
      );
      _expectInstant(
        Instant.ofBeeps(Day.ofEpoch(3, _earthKey), 9999),
        realInstant.minusBeeps(5001),
      );
      _expectInstant(
        Instant.ofBeeps(Day.ofEpoch(4, _earthKey), 0),
        realInstant.minusBeeps(5000),
      );
      _expectInstant(
        Instant.ofBeeps(Day.ofEpoch(4, _earthKey), 1),
        realInstant.minusBeeps(4999),
      );
      _expectInstant(
        Instant.ofBeeps(Day.ofEpoch(4, _earthKey), 4000),
        realInstant.minusBeeps(1000),
      );
      _expectInstant(
        Instant.ofBeeps(Day.ofEpoch(4, _earthKey), 4999),
        realInstant.minusBeeps(1),
      );
      _expectInstant(
        Instant.ofBeeps(Day.ofEpoch(4, _earthKey), 5000),
        realInstant.minusBeeps(0),
      );
    });

    test('testPlusProportionOfDay', () {
      final realInstant = Instant.ofBeeps(Day.ofEpoch(4, _earthKey), 5000);
      expect(
        Day.ofEpoch(4, _earthKey).lastInstant(),
        realInstant.plusProportionOfDay(
          Fraction(499999999999999999, 1000000000000000000),
        ),
      );
      _expectInstant(
        Instant.ofBeeps(Day.ofEpoch(5, _earthKey), 4999),
        realInstant.plusProportionOfDay(Fraction(9999, 10000)),
      );
      _expectInstant(
        Instant.ofBeeps(Day.ofEpoch(5, _earthKey), 5000),
        realInstant.plusProportionOfDay(
          Fraction(999999999999999999, 1000000000000000000),
        ),
      );
    });

    test('testPlusBeeps', () {
      final realInstant = Instant.ofBeeps(Day.ofEpoch(4, _earthKey), 5000);
      _expectInstant(
        Instant.ofBeeps(Day.ofEpoch(7, _earthKey), 1),
        realInstant.plusBeeps(25001),
      );
      _expectInstant(
        Instant.ofBeeps(Day.ofEpoch(7, _earthKey), 0),
        realInstant.plusBeeps(25000),
      );
      _expectInstant(
        Instant.ofBeeps(Day.ofEpoch(6, _earthKey), 9999),
        realInstant.plusBeeps(24999),
      );
      _expectInstant(
        Instant.ofBeeps(Day.ofEpoch(6, _earthKey), 5000),
        realInstant.plusBeeps(20000),
      );
      _expectInstant(
        Instant.ofBeeps(Day.ofEpoch(5, _earthKey), 5000),
        realInstant.plusBeeps(10000),
      );
      _expectInstant(
        Instant.ofBeeps(Day.ofEpoch(5, _earthKey), 1),
        realInstant.plusBeeps(5001),
      );
      _expectInstant(
        Instant.ofBeeps(Day.ofEpoch(5, _earthKey), 0),
        realInstant.plusBeeps(5000),
      );
      _expectInstant(
        Instant.ofBeeps(Day.ofEpoch(4, _earthKey), 9999),
        realInstant.plusBeeps(4999),
      );
      _expectInstant(
        Instant.ofBeeps(Day.ofEpoch(4, _earthKey), 6000),
        realInstant.plusBeeps(1000),
      );
      _expectInstant(
        Instant.ofBeeps(Day.ofEpoch(4, _earthKey), 5001),
        realInstant.plusBeeps(1),
      );
      _expectInstant(
        Instant.ofBeeps(Day.ofEpoch(4, _earthKey), 5000),
        realInstant.plusBeeps(0),
      );
    });

    test('testDifferenceInBeepsWith', () {
      final left = Instant.ofBeeps(Day.ofEpoch(3, _earthKey), 5000);
      expect(
        -24999,
        left.differenceInBeepsWith(
          Instant.ofBeeps(Day.ofEpoch(5, _earthKey), 9999),
        ),
      );
      expect(
        -20001,
        left.differenceInBeepsWith(
          Instant.ofBeeps(Day.ofEpoch(5, _earthKey), 5001),
        ),
      );
      expect(
        -20000,
        left.differenceInBeepsWith(
          Instant.ofBeeps(Day.ofEpoch(5, _earthKey), 5000),
        ),
      );
      expect(
        -19999,
        left.differenceInBeepsWith(
          Instant.ofBeeps(Day.ofEpoch(5, _earthKey), 4999),
        ),
      );
      expect(
        -15000,
        left.differenceInBeepsWith(
          Instant.ofBeeps(Day.ofEpoch(5, _earthKey), 0),
        ),
      );

      expect(
        -14999,
        left.differenceInBeepsWith(
          Instant.ofBeeps(Day.ofEpoch(4, _earthKey), 9999),
        ),
      );
      expect(
        -10001,
        left.differenceInBeepsWith(
          Instant.ofBeeps(Day.ofEpoch(4, _earthKey), 5001),
        ),
      );
      expect(
        -10000,
        left.differenceInBeepsWith(
          Instant.ofBeeps(Day.ofEpoch(4, _earthKey), 5000),
        ),
      );
      expect(
        -9999,
        left.differenceInBeepsWith(
          Instant.ofBeeps(Day.ofEpoch(4, _earthKey), 4999),
        ),
      );
      expect(
        -5000,
        left.differenceInBeepsWith(
          Instant.ofBeeps(Day.ofEpoch(4, _earthKey), 0),
        ),
      );

      expect(
        -4999,
        left.differenceInBeepsWith(
          Instant.ofBeeps(Day.ofEpoch(3, _earthKey), 9999),
        ),
      );
      expect(
        -1000,
        left.differenceInBeepsWith(
          Instant.ofBeeps(Day.ofEpoch(3, _earthKey), 6000),
        ),
      );
      expect(
        -1,
        left.differenceInBeepsWith(
          Instant.ofBeeps(Day.ofEpoch(3, _earthKey), 5001),
        ),
      );
      expect(
        0,
        left.differenceInBeepsWith(
          Instant.ofBeeps(Day.ofEpoch(3, _earthKey), 5000),
        ),
      );
      expect(
        1,
        left.differenceInBeepsWith(
          Instant.ofBeeps(Day.ofEpoch(3, _earthKey), 4999),
        ),
      );
      expect(
        1000,
        left.differenceInBeepsWith(
          Instant.ofBeeps(Day.ofEpoch(3, _earthKey), 4000),
        ),
      );
      expect(
        4999,
        left.differenceInBeepsWith(
          Instant.ofBeeps(Day.ofEpoch(3, _earthKey), 1),
        ),
      );
      expect(
        5000,
        left.differenceInBeepsWith(
          Instant.ofBeeps(Day.ofEpoch(3, _earthKey), 0),
        ),
      );

      expect(
        5001,
        left.differenceInBeepsWith(
          Instant.ofBeeps(Day.ofEpoch(2, _earthKey), 9999),
        ),
      );
      expect(
        9999,
        left.differenceInBeepsWith(
          Instant.ofBeeps(Day.ofEpoch(2, _earthKey), 5001),
        ),
      );
      expect(
        10000,
        left.differenceInBeepsWith(
          Instant.ofBeeps(Day.ofEpoch(2, _earthKey), 5000),
        ),
      );
      expect(
        10001,
        left.differenceInBeepsWith(
          Instant.ofBeeps(Day.ofEpoch(2, _earthKey), 4999),
        ),
      );
      expect(
        15000,
        left.differenceInBeepsWith(
          Instant.ofBeeps(Day.ofEpoch(2, _earthKey), 0),
        ),
      );

      expect(
        15001,
        left.differenceInBeepsWith(
          Instant.ofBeeps(Day.ofEpoch(1, _earthKey), 9999),
        ),
      );
      expect(
        19999,
        left.differenceInBeepsWith(
          Instant.ofBeeps(Day.ofEpoch(1, _earthKey), 5001),
        ),
      );
      expect(
        20000,
        left.differenceInBeepsWith(
          Instant.ofBeeps(Day.ofEpoch(1, _earthKey), 5000),
        ),
      );
      expect(
        20001,
        left.differenceInBeepsWith(
          Instant.ofBeeps(Day.ofEpoch(1, _earthKey), 4999),
        ),
      );
      expect(
        25000,
        left.differenceInBeepsWith(
          Instant.ofBeeps(Day.ofEpoch(1, _earthKey), 0),
        ),
      );

      expect(
        -2000,
        Instant.ofBeeps(Day.ofEpoch(3, _earthKey), 3000).differenceInBeepsWith(
          Instant.of(
            Day.ofEpoch(3, _earthKey),
            Fraction(500099999, 1000000000),
          ),
        ),
      );
      expect(
        0,
        Instant.ofBeeps(Day.ofEpoch(3, _earthKey), 3000).differenceInBeepsWith(
          Instant.of(
            Day.ofEpoch(3, _earthKey),
            Fraction(300099999, 1000000000),
          ),
        ),
      );
    });

    test('testToCalendar', () {
      final earthData = store.data(_earthKey);
      final currentOffset =
          earthData.getUnixEpochOffsetMilliseconds() +
          DateTime.now().millisecondsSinceEpoch;

      final now = Instant.ofEpoch(currentOffset, _earthKey);
      final oneSecondBehind = now.toCalendar(_oneSecondBehindKey);
      expect(
        now.getEpochMilliseconds() + 1000,
        oneSecondBehind.getEpochMilliseconds(),
      );
      expect(_oneSecondBehindKey, oneSecondBehind.getCalendarKey());

      const leapUnixMs = 78796800000;
      final leapOffset =
          earthData.getUnixEpochOffsetMilliseconds() + leapUnixMs;

      for (final delta in [-1, 0, 1]) {
        final leap = Instant.ofEpoch(leapOffset + delta, _earthKey);
        final converted = leap.toCalendar(_oneSecondBehindKey);
        expect(
          leap.getEpochMilliseconds() + 1000,
          converted.getEpochMilliseconds(),
        );
      }
    });
  });
}

void _expectInstant(Instant expected, Instant actual) {
  assertInstant(
    expected.getEpochMilliseconds(),
    expected.getCalendarKey(),
    actual,
  );
}

void _assertInstantEquality(int epochMillis) {
  final instant = Instant.ofEpoch(epochMillis, _earthKey);
  expect(_earthKey, instant.getCalendarKey());
  expect(epochMillis, instant.getEpochMilliseconds());

  final copy = Instant.of(instant.getDay(), instant.getProportionOfDay());
  expect(instant.getCalendarKey(), copy.getCalendarKey());
  expect(instant.getEpochMilliseconds(), copy.getEpochMilliseconds());
  expect(instant.getProportionOfDay(), copy.getProportionOfDay());
  expect(instant.getBeeps(), copy.getBeeps());
  expect(instant, copy);

  final beepCopy = Instant.ofBeeps(instant.getDay(), instant.getBeeps());
  expect(instant.getCalendarKey(), beepCopy.getCalendarKey());
  expect(instant.getBeeps(), beepCopy.getBeeps());
}

class _FixedEarthCalendarProvider implements MillisecondStoreDataProvider {
  _FixedEarthCalendarProvider({
    required this.unixOffset,
    required this.years,
    required this.days,
  });

  final int unixOffset;
  final List<int> years;
  final List<int> days;

  @override
  int loadUnixEpochOffsetMilliseconds() => unixOffset;

  @override
  List<int> loadYearEpochMilliseconds() => years;

  @override
  List<int> loadDayEpochMilliseconds(List<int> yearEpochMilliseconds) => days;
}
