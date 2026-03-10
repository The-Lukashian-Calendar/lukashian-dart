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

import 'calendar_object.dart';
import 'day.dart';
import 'instant.dart';
import 'lukashian_exception.dart';
import 'store/millisecond_store.dart';

/// Represents a year in the Lukashian Calendar Mechanism.
final class Year extends CalendarObject implements Comparable<Year> {
  Year._(this._year, super.calendarKey)
      : _epochMilliseconds = MillisecondStore.store().data(calendarKey).getEpochMillisecondsForYear(_year),
        _epochMillisecondsPreviousYear = _year == 1 ? 0 : MillisecondStore.store().data(calendarKey).getEpochMillisecondsForYear(_year - 1);

  final int _year;
  final int _epochMilliseconds;
  final int _epochMillisecondsPreviousYear;

  Year minusYears(int yearsToSubtract) {
    if (yearsToSubtract < 0) return plusYears(-yearsToSubtract);
    return Year.of(_year - yearsToSubtract, calendarKey);
  }

  Year plusYears(int yearsToAdd) {
    if (yearsToAdd < 0) return minusYears(-yearsToAdd);
    return Year.of(_year + yearsToAdd, calendarKey);
  }

  Year previous() => minusYears(1);
  Year next() => plusYears(1);

  Day atDay(int day) => Day.of(this, day);
  Day firstDay() => Day.of(this, 1);
  Day lastDay() => Day.ofEpoch(MillisecondStore.store().data(calendarKey).getEpochDayForEpochMilliseconds(getEpochMilliseconds()), calendarKey);

  LukashianInstant firstInstant() => LukashianInstant.ofEpoch(getEpochMillisecondsAtStartOfYear(), calendarKey);
  LukashianInstant lastInstant() => LukashianInstant.ofEpoch(getEpochMilliseconds(), calendarKey);

  bool isBefore(Year other) {
    checkSameKeyAs(other);
    return _year < other._year;
  }

  bool isSameOrBefore(Year other) {
    checkSameKeyAs(other);
    return _year <= other._year;
  }

  bool isAfter(Year other) {
    checkSameKeyAs(other);
    return _year > other._year;
  }

  bool isSameOrAfter(Year other) {
    checkSameKeyAs(other);
    return _year >= other._year;
  }

  bool contains(CalendarObject other) {
    checkSameKeyAs(other);
    if (other is Day) return this == other.getYear();
    if (other is LukashianInstant) {
      final instantEpoch = other.getEpochMilliseconds();
      return instantEpoch >= getEpochMillisecondsAtStartOfYear() && instantEpoch <= _epochMilliseconds;
    }
    return false;
  }

  bool containsNot(CalendarObject other) {
    checkSameKeyAs(other);
    return !contains(other);
  }

  int lengthInMilliseconds() => _epochMilliseconds - _epochMillisecondsPreviousYear;
  int getNumberOfDays() => lastDay().getDayNumber();
  int getYearNumber() => _year;
  int getEpochMilliseconds() => _epochMilliseconds;
  int getEpochMillisecondsPreviousYear() => _epochMillisecondsPreviousYear;
  int getEpochMillisecondsAtStartOfYear() => _epochMillisecondsPreviousYear + 1;

  int differenceWith(Year other) {
    checkSameKeyAs(other);
    return _year - other._year;
  }

  static Year of(int year, [int? calendarKey]) {
    LukashianException.check(year >= 1, () => '$year is not a valid year, the minimum is 1');
    return Year._(year, calendarKey ?? MillisecondStore.store().getDefaultCalendarKey());
  }

  static Year now([int? calendarKey]) {
    final key = calendarKey ?? MillisecondStore.store().getDefaultCalendarKey();
    final store = MillisecondStore.store();
    final data = store.data(key);
    return Year.of(data.getYearForEpochMilliseconds(data.getCurrentEpochMilliseconds()), key);
  }

  @override
  int compareTo(Year other) => differenceWith(other);

  @override
  int get hashCode => Object.hash(_year, calendarKey);

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Year && other._year == _year && other.calendarKey == calendarKey);

  @override
  String toString() => '[Year: $_year]';
}
