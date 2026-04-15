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

import 'package:fraction/fraction.dart';

import 'calendar_object.dart';
import 'instant.dart';
import 'lukashian_exception.dart';
import 'store/millisecond_store.dart';
import 'year.dart';

/// Represents a day in the Lukashian Calendar Mechanism.
final class Day extends CalendarObject implements Comparable<Day> {
  Day._(this._epochDay, super.calendarKey)
    : _epochMilliseconds = MillisecondStore.store()
          .data(calendarKey)
          .getEpochMillisecondsForEpochDay(_epochDay),
      _epochMillisecondsPreviousDay = _epochDay == 1
          ? 0
          : MillisecondStore.store()
                .data(calendarKey)
                .getEpochMillisecondsForEpochDay(_epochDay - 1);

  final int _epochDay;
  final int _epochMilliseconds;
  final int _epochMillisecondsPreviousDay;

  Day minusYears(int yearsToSubtract) =>
      Day.of(getYear().minusYears(yearsToSubtract), getDayNumber());
  Day plusYears(int yearsToAdd) =>
      Day.of(getYear().plusYears(yearsToAdd), getDayNumber());

  Day minusDays(int daysToSubtract) {
    if (daysToSubtract < 0) return plusDays(-daysToSubtract);
    return Day.ofEpoch(_epochDay - daysToSubtract, calendarKey);
  }

  Day plusDays(int daysToAdd) {
    if (daysToAdd < 0) return minusDays(-daysToAdd);
    return Day.ofEpoch(_epochDay + daysToAdd, calendarKey);
  }

  Day previous() => minusDays(1);
  Day next() => plusDays(1);

  Instant atTime(Fraction proportionOfDay) => Instant.of(this, proportionOfDay);
  Instant atTimeBeeps(int beeps) => Instant.ofBeeps(this, beeps);

  Instant firstInstant() =>
      Instant.ofEpoch(getEpochMillisecondsAtStartOfDay(), calendarKey);
  Instant lastInstant() => Instant.ofEpoch(_epochMilliseconds, calendarKey);

  bool isBefore(Day other) {
    checkSameKeyAs(other);
    return _epochDay < other._epochDay;
  }

  bool isSameOrBefore(Day other) {
    checkSameKeyAs(other);
    return _epochDay <= other._epochDay;
  }

  bool isAfter(Day other) {
    checkSameKeyAs(other);
    return _epochDay > other._epochDay;
  }

  bool isSameOrAfter(Day other) {
    checkSameKeyAs(other);
    return _epochDay >= other._epochDay;
  }

  bool contains(Instant instant) {
    checkSameKeyAs(instant);
    return this == instant.getDay();
  }

  bool containsNot(Instant instant) {
    checkSameKeyAs(instant);
    return !contains(instant);
  }

  bool isIn(Year year) {
    checkSameKeyAs(year);
    return year.contains(this);
  }

  bool isNotIn(Year year) {
    checkSameKeyAs(year);
    return year.containsNot(this);
  }

  int lengthInMilliseconds() =>
      _epochMilliseconds - _epochMillisecondsPreviousDay;
  int getEpochDay() => _epochDay;
  int getEpochMilliseconds() => _epochMilliseconds;
  int getEpochMillisecondsPreviousDay() => _epochMillisecondsPreviousDay;
  int getEpochMillisecondsAtStartOfDay() => _epochMillisecondsPreviousDay + 1;

  Year getYear() => Year.of(
    MillisecondStore.store()
        .data(calendarKey)
        .getYearForEpochMilliseconds(getEpochMillisecondsAtStartOfDay()),
    calendarKey,
  );
  Year getEndYear() => Year.of(
    MillisecondStore.store()
        .data(calendarKey)
        .getYearForEpochMilliseconds(_epochMilliseconds),
    calendarKey,
  );

  int getDayNumber() {
    final firstEpochDayOfYear = _getFirstDayOfYearInEpochForm(getYear());
    return (_epochDay - firstEpochDayOfYear) + 1;
  }

  Fraction getLengthOfBeepInMilliseconds() =>
      Fraction(lengthInMilliseconds(), Instant.beepsPerDay);

  int differenceWith(Day other) {
    checkSameKeyAs(other);
    return _epochDay - other._epochDay;
  }

  static Day ofEpoch(int epochDay, [int? calendarKey]) {
    LukashianException.check(
      epochDay >= 1,
      () => '$epochDay is not a valid epoch day, the minimum is 1',
    );
    final key = calendarKey ?? MillisecondStore.store().getDefaultCalendarKey();
    return Day._(epochDay, key);
  }

  static Day of(Year year, int day) {
    LukashianException.check(
      day >= 1,
      () => '$day is not a valid day, the minimum is 1',
    );
    LukashianException.check(
      day <= year.getNumberOfDays(),
      () => '$day is not a valid day in year ${year.getYearNumber()}',
    );
    final firstEpochDayOfYear = _getFirstDayOfYearInEpochForm(year);
    return Day.ofEpoch((firstEpochDayOfYear + day) - 1, year.getCalendarKey());
  }

  static Day ofYearDay(int year, int day, [int? calendarKey]) {
    final key = calendarKey ?? MillisecondStore.store().getDefaultCalendarKey();
    return Day.of(Year.of(year, key), day);
  }

  static Day now([int? calendarKey]) {
    final key = calendarKey ?? MillisecondStore.store().getDefaultCalendarKey();
    final store = MillisecondStore.store();
    final data = store.data(key);
    return Day.ofEpoch(
      data.getEpochDayForEpochMilliseconds(data.getCurrentEpochMilliseconds()),
      key,
    );
  }

  static int _getFirstDayOfYearInEpochForm(Year year) {
    final store = MillisecondStore.store();
    final key = year.getCalendarKey();
    final data = store.data(key);
    final epochMillisecondsAtStartOfYear = year
        .getEpochMillisecondsAtStartOfYear();
    final runningEpochDayAtStartOfYear = data.getEpochDayForEpochMilliseconds(
      epochMillisecondsAtStartOfYear,
    );
    final epochMillisecondsAtStartOfRunningDay =
        runningEpochDayAtStartOfYear == 1
        ? 1
        : data.getEpochMillisecondsForEpochDay(
                runningEpochDayAtStartOfYear - 1,
              ) +
              1;
    if (epochMillisecondsAtStartOfRunningDay < epochMillisecondsAtStartOfYear) {
      return runningEpochDayAtStartOfYear + 1;
    }
    return runningEpochDayAtStartOfYear;
  }

  @override
  int compareTo(Day other) => differenceWith(other);

  @override
  int get hashCode => Object.hash(_epochDay, calendarKey);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Day &&
          other._epochDay == _epochDay &&
          other.calendarKey == calendarKey);

  @override
  String toString() => '[Day: ${getYear().getYearNumber()}-${getDayNumber()}]';
}
