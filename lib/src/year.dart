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

/// Represents a year in the Lukashian Calendar Mechanism.
///
/// The first year is year 1; years before year 1 are not defined (consistent
/// with days, which also start at 1). Numbering fits designation of years
/// better than mere counting.
///
/// By definition, the exact point at which a year starts belongs to that year,
/// not the previous year, which ends at that point. So a year runs from its
/// start (inclusive) to its end (exclusive).
///
/// Year length in milliseconds is not constant; it reflects the actual length
/// of that year in astronomical terms. The same holds for days, so a day may
/// span two years; a day belongs to the year in which it *started*.
///
/// A [Year] tracks epoch milliseconds from the Lukashian epoch through the final
/// point of this year, and the epoch milliseconds of the previous year for
/// length calculations.
///
/// [Year] is immutable: mutation methods return new instances.
final class Year extends CalendarObject implements Comparable<Year> {
  Year._(this._year, super.calendarKey)
    : _epochMilliseconds = MillisecondStore.store().data(calendarKey).getEpochMillisecondsForYear(_year),
      _epochMillisecondsPreviousYear = _year == 1
          ? 0
          : MillisecondStore.store().data(calendarKey).getEpochMillisecondsForYear(_year - 1);

  final int _year;
  final int _epochMilliseconds;
  final int _epochMillisecondsPreviousYear;

  /// Returns a new [Year] that represents this year minus [yearsToSubtract].
  ///
  /// Throws [LukashianException] when the result would be year 0 or lower.
  Year minusYears(int yearsToSubtract) {
    if (yearsToSubtract < 0) return plusYears(-yearsToSubtract);
    return Year.of(_year - yearsToSubtract, calendarKey);
  }

  /// Returns a new [Year] that represents this year plus [yearsToAdd].
  Year plusYears(int yearsToAdd) {
    if (yearsToAdd < 0) return minusYears(-yearsToAdd);
    return Year.of(_year + yearsToAdd, calendarKey);
  }

  /// Returns the preceding year.
  ///
  /// Throws [LukashianException] when the result would be year 0 or lower.
  Year previous() => minusYears(1);

  /// Returns the succeeding year.
  Year next() => plusYears(1);

  /// The [Day] in this year with the given [day] number.
  ///
  /// Throws [LukashianException] when [day] does not exist in this year.
  Day atDay(int day) => Day.of(this, day);

  /// The first [Day] of this year.
  Day firstDay() => Day.of(this, 1);

  /// The last [Day] of this year (may end in the next year).
  Day lastDay() => Day.ofEpoch(
    MillisecondStore.store().data(calendarKey).getEpochDayForEpochMilliseconds(getEpochMilliseconds()),
    calendarKey,
  );

  /// The first [Instant] of this year (not necessarily at the start of a day).
  Instant firstInstant() => Instant.ofEpoch(getEpochMillisecondsAtStartOfYear(), calendarKey);

  /// The last [Instant] of this year (not necessarily at the end of a day).
  Instant lastInstant() => Instant.ofEpoch(getEpochMilliseconds(), calendarKey);

  /// Whether this year is strictly before [other].
  bool isBefore(Year other) {
    checkSameKeyAs(other);
    return _year < other._year;
  }

  /// Whether this year is the same as or before [other].
  bool isSameOrBefore(Year other) {
    checkSameKeyAs(other);
    return _year <= other._year;
  }

  /// Whether this year is strictly after [other].
  bool isAfter(Year other) {
    checkSameKeyAs(other);
    return _year > other._year;
  }

  /// Whether this year is the same as or after [other].
  bool isSameOrAfter(Year other) {
    checkSameKeyAs(other);
    return _year >= other._year;
  }

  /// Whether [day] started in this year.
  ///
  /// Java overloads `contains(Day)`; Dart uses [containsDay] because Dart has no method overloading.
  bool containsDay(Day day) {
    checkSameKeyAs(day);
    return this == day.getYear();
  }

  /// Whether [instant] lies in this year.
  ///
  /// The instant must fall between [getEpochMillisecondsAtStartOfYear] and[getEpochMilliseconds] inclusive
  /// — note that the instant's [Day] may still start in this year while the instant falls in the next year if that day
  /// ends after the year ends.
  ///
  /// Java overloads `contains(Instant)`; Dart uses [containsInstant] because Dart has no method overloading.
  bool containsInstant(Instant instant) {
    checkSameKeyAs(instant);
    final instantEpoch = instant.getEpochMilliseconds();
    return instantEpoch >= getEpochMillisecondsAtStartOfYear() && instantEpoch <= _epochMilliseconds;
  }

  /// Whether [day] did not start in this year.
  bool containsNotDay(Day day) {
    checkSameKeyAs(day);
    return !containsDay(day);
  }

  /// Whether [instant] does not lie in this year.
  bool containsNotInstant(Instant instant) {
    checkSameKeyAs(instant);
    return !containsInstant(instant);
  }

  /// Total milliseconds from the start of this year through its final point.
  int lengthInMilliseconds() => _epochMilliseconds - _epochMillisecondsPreviousYear;

  /// Number of days in this year ([lastDay]'s day number).
  int getNumberOfDays() => lastDay().getDayNumber();

  /// This year's numeric designation (1-based).
  int getYearNumber() => _year;

  /// Milliseconds from the Lukashian epoch through the final point of this year.
  int getEpochMilliseconds() => _epochMilliseconds;

  /// Milliseconds through the final point of the previous year, or 0 for year 1.
  int getEpochMillisecondsPreviousYear() => _epochMillisecondsPreviousYear;

  /// Milliseconds through the first point of this year, or 1 for year 1.
  int getEpochMillisecondsAtStartOfYear() => _epochMillisecondsPreviousYear + 1;

  /// Difference of year numbers: positive if this year is after [other].
  int differenceWith(Year other) {
    checkSameKeyAs(other);
    return _year - other._year;
  }

  /// Creates a [Year] for [year] and optional [calendarKey] (default: store default).
  ///
  /// See [CalendarKeys], [MillisecondStore]. Throws [LukashianException] for
  /// invalid year or unregistered key.
  static Year of(int year, [int? calendarKey]) {
    LukashianException.check(year >= 1, () => '$year is not a valid year, the minimum is 1');
    return Year._(year, calendarKey ?? MillisecondStore.store().getDefaultCalendarKey());
  }

  /// The current [Year] for optional [calendarKey] (default: store default).
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
