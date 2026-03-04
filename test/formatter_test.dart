/*
 * Copyright (c) 2018-2026 (5918-5926 in Lukashian years)
 * All rights reserved.
 * (License header abbreviated.)
 */

import 'package:lukashian/lukashian.dart';
import 'package:test/test.dart';

import 'helpers/test_millisecond_store_data_provider.dart';

void main() {
  setUpAll(() async {
    final store = MillisecondStore.store();
    store.registerProvider(testCalendarKey, TestMillisecondStoreDataProvider());
    store.setDefaultCalendarKey(testCalendarKey);
    await store.ensureLoaded(testCalendarKey);
  });

  group('Formatter', () {
    test('testFormat', () {
      expect(Formatter.formatInstant(LukashianInstant.ofEpoch(1)), '1-1 0000');
      expect(Formatter.formatInstant(LukashianInstant.ofEpoch(300)), '1-1 9966');
      final instant1900 = LukashianInstant.ofEpoch(1900);
      expect(Formatter.formatInstant(instant1900), '2-3 3300');

      final proportionStr = instant1900.getProportionOfDay().toString();
      expect(
        Formatter.formatInstant(
          instant1900,
          dayFormat: DayFormat.dayFirst,
          daySeparator: '/',
          formatter: (f) => f.toString(),
        ),
        '3/2 $proportionStr',
      );
      expect(
        Formatter.formatInstant(
          instant1900,
          dayFormat: DayFormat.dayOnly,
          daySeparator: '/',
          formatter: (f) => f.toString(),
        ),
        '3 $proportionStr',
      );
      expect(
        Formatter.formatInstant(
          instant1900,
          dayFormat: DayFormat.epoch,
          formatter: (f) => f.toString(),
        ),
        '7 $proportionStr',
      );
      expect(
        Formatter.formatInstant(instant1900, formatter: (f) => f.toString()),
        '2-3 $proportionStr',
      );

      expect(
        Formatter.formatInstant(LukashianInstant.ofEpoch(1900), dayFormat: DayFormat.dayOnly, daySeparator: '/'),
        '3 3300',
      );
      expect(
        Formatter.formatInstant(LukashianInstant.ofEpoch(1900), dayFormat: DayFormat.epoch),
        '7 3300',
      );
      expect(Formatter.formatInstant(LukashianInstant.ofEpoch(1900)), '2-3 3300');
    });

    test('testFormat_NoDayFormat', () {
      expect(() => Formatter.formatDay(Day.ofEpoch(1), null), throwsStateError);
    });
  });
}
