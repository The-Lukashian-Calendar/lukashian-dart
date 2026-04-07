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

import '../lukashian_exception.dart';

/// Stores epoch milliseconds for years and days, and Lukashian–UNIX offset.
/// Built from loaded provider data; immutable.
class MillisecondStoreData {
  MillisecondStoreData({
    required int unixEpochOffsetMilliseconds,
    required List<int> yearEpochMilliseconds,
    required List<int> dayEpochMilliseconds,
  })  : _unixEpochOffsetMilliseconds = unixEpochOffsetMilliseconds,
        _yearEpochMilliseconds = List<int>.unmodifiable(yearEpochMilliseconds),
        _dayEpochMilliseconds = List<int>.unmodifiable(dayEpochMilliseconds),
        _unixTimestampsWithLeapSecond = _getUnixTimestampsWithLeapSecond();

  final int _unixEpochOffsetMilliseconds;
  final List<int> _yearEpochMilliseconds;
  final List<int> _dayEpochMilliseconds;
  final List<int> _unixTimestampsWithLeapSecond;

  /// Offset between the UNIX epoch and the Lukashian epoch for this calendar.
  int getUnixEpochOffsetMilliseconds() => _unixEpochOffsetMilliseconds;

  /// Milliseconds from UNIX epoch to the given Lukashian epoch milliseconds.
  int getUnixEpochMilliseconds(int lukashianEpochMilliseconds) {
    final unixEpochMilliseconds =
        lukashianEpochMilliseconds - _unixEpochOffsetMilliseconds;
    final index = _binarySearch(_unixTimestampsWithLeapSecond, unixEpochMilliseconds);
    final numberOfLeapSeconds = index >= 0 ? index + 1 : -index - 1;
    return unixEpochMilliseconds - (numberOfLeapSeconds * 1000);
  }

  /// Lukashian epoch milliseconds for the given UNIX epoch milliseconds.
  int getLukashianEpochMilliseconds(int unixEpochMilliseconds) {
    final index = _binarySearch(_unixTimestampsWithLeapSecond, unixEpochMilliseconds);
    final numberOfLeapSeconds = index >= 0 ? index + 1 : -index - 1;
    return unixEpochMilliseconds + (numberOfLeapSeconds * 1000) + _unixEpochOffsetMilliseconds;
  }

  /// Lukashian epoch milliseconds for the current time.
  int getCurrentEpochMilliseconds() {
    return getLukashianEpochMilliseconds(DateTime.now().millisecondsSinceEpoch);
  }

  /// Epoch milliseconds at the end of the given year (year 1-based).
  int getEpochMillisecondsForYear(int year) {
    LukashianException.check(
      year >= 1,
      () => '$year is not a valid year, the minimum is 1',
    );
    LukashianException.check(
      year <= _yearEpochMilliseconds.length,
      () => 'Year $year isn\'t supported yet by this Lukashian Calendar instance',
    );
    return _yearEpochMilliseconds[year - 1];
  }

  /// Epoch milliseconds at the end of the given epoch day (1-based).
  int getEpochMillisecondsForEpochDay(int epochDay) {
    LukashianException.check(
      epochDay >= 1,
      () => '$epochDay is not a valid epoch day, the minimum is 1',
    );
    LukashianException.check(
      epochDay <= _dayEpochMilliseconds.length,
      () => 'Epoch day $epochDay isn\'t supported yet by this Lukashian Calendar instance',
    );
    return _dayEpochMilliseconds[epochDay - 1];
  }

  /// Year (1-based) that contains the given epoch milliseconds.
  int getYearForEpochMilliseconds(int epochMilliseconds) {
    LukashianException.check(
      epochMilliseconds >= 1,
      () => '$epochMilliseconds is not valid, the minimum is 1',
    );
    LukashianException.check(
      epochMilliseconds <= _yearEpochMilliseconds.last,
      () => 'Epoch millisecond $epochMilliseconds isn\'t supported yet by this Lukashian Calendar instance',
    );
    final index = _binarySearch(_yearEpochMilliseconds, epochMilliseconds);
    return index >= 0 ? index + 1 : -index;
  }

  /// Epoch day (1-based) that contains the given epoch milliseconds.
  int getEpochDayForEpochMilliseconds(int epochMilliseconds) {
    LukashianException.check(
      epochMilliseconds >= 1,
      () => '$epochMilliseconds is not valid, the minimum is 1',
    );
    LukashianException.check(
      epochMilliseconds <= _dayEpochMilliseconds.last,
      () => 'Epoch millisecond $epochMilliseconds isn\'t supported yet by this Lukashian Calendar instance',
    );
    final index = _binarySearch(_dayEpochMilliseconds, epochMilliseconds);
    return index >= 0 ? index + 1 : -index;
  }

  static int _binarySearch(List<int> list, int key) {
    var low = 0;
    var high = list.length - 1;
    while (low <= high) {
      final mid = (low + high) >> 1;
      final midVal = list[mid];
      if (midVal < key) {
        low = mid + 1;
      } else if (midVal > key) {
        high = mid - 1;
      } else {
        return mid;
      }
    }
    return -(low + 1);
  }

  static List<int> _getUnixTimestampsWithLeapSecond() {
    // See https://github.com/eggert/tz/blob/master/leap-seconds.list
    const secondsSince1900WithLeapSecond = [
      2287785600,
      2303683200,
      2335219200,
      2366755200,
      2398291200,
      2429913600,
      2461449600,
      2492985600,
      2524521600,
      2571782400,
      2603318400,
      2634854400,
      2698012800,
      2776982400,
      2840140800,
      2871676800,
      2918937600,
      2950473600,
      2982009600,
      3029443200,
      3076704000,
      3124137600,
      3345062400,
      3439756800,
      3550089600,
      3644697600,
      3692217600,
    ];
    return secondsSince1900WithLeapSecond
        .map((s) => (s - 2208988800) * 1000)
        .toList();
  }
}
