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

import 'package:lukashian/lukashian.dart';

/// Represents a day in the Lukashian Calendar Mechanism.
///
/// The first day of every year is day 1. A day is part of the year that it
/// starts in, even if it finishes in the next year.
///
/// By definition, the exact point at which a day starts belongs to that day,
/// not the previous day, which ends at that point. So a day runs from its start
/// (inclusive) to its end (exclusive).
///
/// Day length in milliseconds is not constant; it reflects the actual length
/// of that day in astronomical terms. The same holds for years, so a day may
/// span two calendar years; a day belongs to the year in which it *started*.
///
/// The first day of the calendar starts at the same instant as the first year.
///
/// A [Day] tracks epoch milliseconds through the final point of this day and the
/// previous day for length calculations. Internally it uses **epoch day**:
/// which day since the start of the calendar (1-based), independent of year.
///
/// [Day] is immutable: mutation methods return new instances.
final class Day extends CalendarObject implements Comparable<Day> {
  Day._(this._epochDay, super.calendarKey)
    : _epochMilliseconds = MillisecondStore.store().data(calendarKey).getEpochMillisecondsForEpochDay(_epochDay),
      _epochMillisecondsPreviousDay = _epochDay == 1
          ? 0
          : MillisecondStore.store().data(calendarKey).getEpochMillisecondsForEpochDay(_epochDay - 1);

  final int _epochDay;
  final int _epochMilliseconds;
  final int _epochMillisecondsPreviousDay;

  /// Same calendar day-of-year, [yearsToSubtract] years earlier.
  ///
  /// Throws [LukashianException] if the result would be before the calendar
  /// start or the target year has no such day number.
  Day minusYears(int yearsToSubtract) => Day.of(getYear().minusYears(yearsToSubtract), getDayNumber());

  /// Same calendar day-of-year, [yearsToAdd] years later.
  ///
  /// Throws [LukashianException] if the target year has no such day number.
  Day plusYears(int yearsToAdd) => Day.of(getYear().plusYears(yearsToAdd), getDayNumber());

  /// This day minus [daysToSubtract] epoch days (may change year).
  ///
  /// Throws [LukashianException] if the result would be before day 1.
  Day minusDays(int daysToSubtract) {
    if (daysToSubtract < 0) return plusDays(-daysToSubtract);
    return Day.ofEpoch(_epochDay - daysToSubtract, calendarKey);
  }

  /// This day plus [daysToAdd] epoch days (may change year).
  Day plusDays(int daysToAdd) {
    if (daysToAdd < 0) return minusDays(-daysToAdd);
    return Day.ofEpoch(_epochDay + daysToAdd, calendarKey);
  }

  /// The previous calendar day.
  ///
  /// Throws [LukashianException] if that would be before day 1.
  Day previous() => minusDays(1);

  /// The next calendar day.
  Day next() => plusDays(1);

  /// The [Instant] after [proportionOfDay] of this day has passed.
  ///
  /// Throws [LukashianException] if [proportionOfDay] is not in `[0, 1)`.
  Instant atTime(Fraction proportionOfDay) => Instant.of(this, proportionOfDay);

  /// The [Instant] after [beeps] beeps of this day have passed (0–9999).
  ///
  /// Same as Java `Day.atTime(int beeps)`.
  Instant atTimeBeeps(int beeps) => Instant.ofBeeps(this, beeps);

  /// The first [Instant] of this day.
  Instant firstInstant() => Instant.ofEpoch(getEpochMillisecondsAtStartOfDay(), calendarKey);

  /// The last [Instant] of this day.
  Instant lastInstant() => Instant.ofEpoch(_epochMilliseconds, calendarKey);

  /// Whether this day is strictly before [other].
  bool isBefore(Day other) {
    checkSameKeyAs(other);
    return _epochDay < other._epochDay;
  }

  /// Whether this day is the same as or before [other].
  bool isSameOrBefore(Day other) {
    checkSameKeyAs(other);
    return _epochDay <= other._epochDay;
  }

  /// Whether this day is strictly after [other].
  bool isAfter(Day other) {
    checkSameKeyAs(other);
    return _epochDay > other._epochDay;
  }

  /// Whether this day is the same as or after [other].
  bool isSameOrAfter(Day other) {
    checkSameKeyAs(other);
    return _epochDay >= other._epochDay;
  }

  /// Whether [instant]'s day equals this [Day].
  bool contains(Instant instant) {
    checkSameKeyAs(instant);
    return this == instant.getDay();
  }

  /// The negation of [contains].
  bool containsNot(Instant instant) {
    checkSameKeyAs(instant);
    return !contains(instant);
  }

  /// Whether this day started in [year] (see [Year.contains]).
  bool isIn(Year year) {
    checkSameKeyAs(year);
    return year.contains(this);
  }

  /// The negation of [isIn].
  bool isNotIn(Year year) {
    checkSameKeyAs(year);
    return year.containsNot(this);
  }

  /// Milliseconds from the start of this day through its final point.
  int lengthInMilliseconds() => _epochMilliseconds - _epochMillisecondsPreviousDay;

  /// Epoch day: days since the Lukashian epoch (1-based).
  int getEpochDay() => _epochDay;

  /// Milliseconds from the Lukashian epoch through the final point of this day.
  int getEpochMilliseconds() => _epochMilliseconds;

  /// Milliseconds through the final point of the previous day.
  int getEpochMillisecondsPreviousDay() => _epochMillisecondsPreviousDay;

  /// Milliseconds through the first point of this day (or 1 for epoch day 1).
  int getEpochMillisecondsAtStartOfDay() => _epochMillisecondsPreviousDay + 1;

  /// The year this day *starts* in.
  Year getYear() => Year.of(
    MillisecondStore.store().data(calendarKey).getYearForEpochMilliseconds(getEpochMillisecondsAtStartOfDay()),
    calendarKey,
  );

  /// The year this day's final instant falls in (may differ from [getYear]).
  Year getEndYear() =>
      Year.of(MillisecondStore.store().data(calendarKey).getYearForEpochMilliseconds(_epochMilliseconds), calendarKey);

  /// Day-of-year number within [getYear] (1-based).
  int getDayNumber() {
    final firstEpochDayOfYear = _getFirstDayOfYearInEpochForm(getYear());
    return (_epochDay - firstEpochDayOfYear) + 1;
  }

  /// Length of one beep (1/10000 of a day) as a [Fraction] of milliseconds.
  Fraction getLengthOfBeepInMilliseconds() => Fraction(lengthInMilliseconds(), Instant.beepsPerDay);

  /// Epoch-day difference: positive if this day is after [other].
  int differenceWith(Day other) {
    checkSameKeyAs(other);
    return _epochDay - other._epochDay;
  }

  /// Creates a [Day] for epoch day [epochDay] and optional [calendarKey].
  ///
  /// See [CalendarKeys], [MillisecondStore].
  static Day ofEpoch(int epochDay, [int? calendarKey]) {
    LukashianException.check(epochDay >= 1, () => '$epochDay is not a valid epoch day, the minimum is 1');
    final key = calendarKey ?? MillisecondStore.store().getDefaultCalendarKey();
    return Day._(epochDay, key);
  }

  /// Creates a [Day] for [day] within [year].
  ///
  /// Throws [LukashianException] if [day] is out of range for [year].
  static Day of(Year year, int day) {
    LukashianException.check(day >= 1, () => '$day is not a valid day, the minimum is 1');
    LukashianException.check(
      day <= year.getNumberOfDays(),
      () => '$day is not a valid day in year ${year.getYearNumber()}',
    );
    final firstEpochDayOfYear = _getFirstDayOfYearInEpochForm(year);
    return Day.ofEpoch((firstEpochDayOfYear + day) - 1, year.getCalendarKey());
  }

  /// [Day.of] with a numeric [year] and optional [calendarKey].
  static Day ofYearDay(int year, int day, [int? calendarKey]) {
    final key = calendarKey ?? MillisecondStore.store().getDefaultCalendarKey();
    return Day.of(Year.of(year, key), day);
  }

  /// Today's [Day] for optional [calendarKey].
  static Day now([int? calendarKey]) {
    final key = calendarKey ?? MillisecondStore.store().getDefaultCalendarKey();
    final store = MillisecondStore.store();
    final data = store.data(key);
    return Day.ofEpoch(data.getEpochDayForEpochMilliseconds(data.getCurrentEpochMilliseconds()), key);
  }

  static int _getFirstDayOfYearInEpochForm(Year year) {
    final store = MillisecondStore.store();
    final key = year.getCalendarKey();
    final data = store.data(key);
    final epochMillisecondsAtStartOfYear = year.getEpochMillisecondsAtStartOfYear();
    final runningEpochDayAtStartOfYear = data.getEpochDayForEpochMilliseconds(epochMillisecondsAtStartOfYear);
    final epochMillisecondsAtStartOfRunningDay = runningEpochDayAtStartOfYear == 1
        ? 1
        : data.getEpochMillisecondsForEpochDay(runningEpochDayAtStartOfYear - 1) + 1;
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
      identical(this, other) || (other is Day && other._epochDay == _epochDay && other.calendarKey == calendarKey);

  @override
  String toString() => '[Day: ${getYear().getYearNumber()}-${getDayNumber()}]';
}
