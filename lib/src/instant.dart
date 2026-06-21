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

/// A unique millisecond on the Lukashian timeline (millisecond 1 is the first).
/// Also represents time-of-day as a [Fraction] — the proportion of the current
/// [Day] that has passed — or as **beeps** (basis points, 0–9999); see
/// <https://en.wikipedia.org/wiki/Basis_point>.
///
/// Translating proportion to a concrete millisecond uses a “wheel of fortune”
/// rule: the proportion picks a segment; boundaries belong to the *next*
/// millisecond. So an [Instant] includes the start of its millisecond and
/// excludes the end (`[m, m+1)` in millisecond index terms).
///
/// Translating a millisecond back to proportion uses the proportion from the
/// start of the day up to the *start* of that millisecond (the millisecond is
/// not considered fully passed), so the last millisecond of a day has
/// proportion &lt; 1 — consistent with [Day] running `[start, end)`.
///
/// Internally, [Instant] stores [getDay] and [getProportionOfDay], not the
/// timeline millisecond, so round-trips through beeps stay stable (see Java
/// `Instant` javadoc).
///
/// [Object.==], [hashCode], and [compareTo] use the timeline millisecond, not
/// the stored proportion alone.
///
/// **Naming:** the Java type is `Instant`; this Dart library uses [Instant]
/// (not `DateTime`) to avoid clashing with Dart's [DateTime].
///
/// [Instant] is immutable.
final class Instant extends CalendarObject implements Comparable<Instant> {
  Instant._(this._day, this._proportionOfDay, super.calendarKey);

  /// Beeps per day (basis points scale). Same as Java `BEEPS_PER_DAY`.
  static const int beepsPerDay = 10000;

  final Day _day;
  final Fraction _proportionOfDay;

  /// This instant's time-of-day on [day] minus [yearsToSubtract] years.
  ///
  /// Throws [LukashianException] if [Day.minusYears] would fail.
  Instant minusYears(int yearsToSubtract) => Instant.of(_day.minusYears(yearsToSubtract), _proportionOfDay);

  /// This instant's time-of-day on [day] plus [yearsToAdd] years.
  Instant plusYears(int yearsToAdd) => Instant.of(_day.plusYears(yearsToAdd), _proportionOfDay);

  /// This instant's time-of-day on a day [daysToSubtract] days earlier.
  ///
  /// Throws [LukashianException] if that would precede the calendar start.
  Instant minusDays(int daysToSubtract) => Instant.of(_day.minusDays(daysToSubtract), _proportionOfDay);

  /// This instant's time-of-day on a day [daysToAdd] days later.
  Instant plusDays(int daysToAdd) => Instant.of(_day.plusDays(daysToAdd), _proportionOfDay);

  /// Same instant time-of-day on the previous calendar day (`minusDays(1)`).
  Instant atPreviousDay() => minusDays(1);

  /// Same instant time-of-day on the next calendar day (`plusDays(1)`).
  Instant atNextDay() => plusDays(1);

  /// Minus [millisecondsToSubtract] timeline milliseconds.
  ///
  /// Throws [LukashianException] if the result would be before the calendar
  /// start. Small changes may not change default beep formatting.
  Instant minusMilliseconds(int millisecondsToSubtract) {
    if (millisecondsToSubtract < 0) {
      return plusMilliseconds(-millisecondsToSubtract);
    }
    return Instant.ofEpoch(getEpochMilliseconds() - millisecondsToSubtract, calendarKey);
  }

  /// Same as [minusMilliseconds] with seconds × 1000.
  Instant minusSeconds(int secondsToSubtract) => minusMilliseconds(secondsToSubtract * 1000);

  /// Plus [millisecondsToAdd] timeline milliseconds.
  Instant plusMilliseconds(int millisecondsToAdd) {
    if (millisecondsToAdd < 0) {
      return minusMilliseconds(-millisecondsToAdd);
    }
    return Instant.ofEpoch(getEpochMilliseconds() + millisecondsToAdd, calendarKey);
  }

  /// Same as [plusMilliseconds] with seconds × 1000.
  Instant plusSeconds(int secondsToAdd) => plusMilliseconds(secondsToAdd * 1000);

  /// Minus [proportionToSubtract] interpreted as **full days** where 1 = one
  /// full day (may span variable-length days).
  ///
  /// Throws [LukashianException] if the result would be before the calendar
  /// start.
  Instant minusProportionOfDay(Fraction proportionToSubtract) {
    if (_lessThan(proportionToSubtract, Fraction(0, 1))) {
      return plusProportionOfDay(Fraction(0, 1) - proportionToSubtract);
    }
    final totalProportion = _proportionOfDay - proportionToSubtract;
    final negated = totalProportion.negate();
    var daysToSubtract = negated.numerator ~/ negated.denominator;
    var remainingProportion = totalProportion + Fraction(daysToSubtract, 1);
    if (_lessThan(remainingProportion, Fraction(0, 1))) {
      daysToSubtract++;
      remainingProportion = remainingProportion + Fraction(1, 1);
    }
    return Instant.of(_day.minusDays(daysToSubtract), remainingProportion.reduce());
  }

  /// Minus [beepsToSubtract] beeps (each 1/[beepsPerDay] of a day).
  Instant minusBeeps(int beepsToSubtract) => minusProportionOfDay(Fraction(beepsToSubtract, beepsPerDay));

  /// Plus [proportionToAdd] as full days (1 = one day).
  Instant plusProportionOfDay(Fraction proportionToAdd) {
    if (_lessThan(proportionToAdd, Fraction(0, 1))) {
      return minusProportionOfDay(proportionToAdd.negate());
    }
    final totalProportion = _proportionOfDay + proportionToAdd;
    final daysToAdd = totalProportion.numerator ~/ totalProportion.denominator;
    final remainingProportion = (totalProportion - Fraction(daysToAdd, 1)).reduce();
    return Instant.of(_day.plusDays(daysToAdd), remainingProportion);
  }

  /// Plus [beepsToAdd] beeps.
  Instant plusBeeps(int beepsToAdd) => plusProportionOfDay(Fraction(beepsToAdd, beepsPerDay));

  /// Timeline order: strictly before [other] (same calendar key).
  bool isBefore(Instant other) {
    checkSameKeyAs(other);
    return getEpochMilliseconds() < other.getEpochMilliseconds();
  }

  /// Timeline order: same or before [other].
  bool isSameOrBefore(Instant other) {
    checkSameKeyAs(other);
    return getEpochMilliseconds() <= other.getEpochMilliseconds();
  }

  /// Timeline order: strictly after [other].
  bool isAfter(Instant other) {
    checkSameKeyAs(other);
    return getEpochMilliseconds() > other.getEpochMilliseconds();
  }

  /// Timeline order: same or after [other].
  bool isSameOrAfter(Instant other) {
    checkSameKeyAs(other);
    return getEpochMilliseconds() >= other.getEpochMilliseconds();
  }

  /// Whether this instant lies in [other] ([Year] or [Day]).
  ///
  /// The Java API has `isIn(Year)` and `isIn(Day)` separately.
  bool isIn(CalendarObject other) {
    checkSameKeyAs(other);
    if (other is Year) return other.contains(this);
    if (other is Day) return other.contains(this);
    return false;
  }

  /// The negation of [isIn].
  bool isNotIn(CalendarObject other) {
    checkSameKeyAs(other);
    return !isIn(other);
  }

  /// The unique Lukashian timeline millisecond for this instant.
  int getEpochMilliseconds() {
    final millisecondsOfDay = _day.lengthInMilliseconds();
    final prop = _proportionOfDay.reduce();
    final num = BigInt.from(millisecondsOfDay) * BigInt.from(prop.numerator);
    final den = BigInt.from(prop.denominator);

    var resultingNum = num;
    final truncatedMs = num ~/ den;
    if (resultingNum == den * truncatedMs) {
      resultingNum = resultingNum + den;
    }

    final resultingMillisecondLong = ((resultingNum + den - BigInt.one) ~/ den).toInt();
    return _day.getEpochMillisecondsPreviousDay() + resultingMillisecondLong;
  }

  /// Same as [getEpochMilliseconds].
  int getMillisecond() => getEpochMilliseconds();

  /// The stored proportion of the current day that has passed `[0, 1)`.
  Fraction getProportionOfDay() => _proportionOfDay;

  /// This instant's calendar day.
  Day getDay() => _day;

  /// The [Year] containing this instant's timeline position (may differ from
  /// [getDay].getYear() if the day ends in another year).
  Year getYear() => Year.of(
    MillisecondStore.store().data(calendarKey).getYearForEpochMilliseconds(getEpochMilliseconds()),
    calendarKey,
  );

  /// [getProportionOfDay] as beeps 0–9999 (truncated; see Java `Instant.getBeeps`).
  int getBeeps() => (_proportionOfDay * Fraction(beepsPerDay, 1)).toDouble().truncate();

  /// Milliseconds since the UNIX epoch for this instant (may be negative).
  int getUnixEpochMilliseconds() =>
      MillisecondStore.store().data(calendarKey).getUnixEpochMilliseconds(getEpochMilliseconds());

  /// Same instant as UTC [DateTime] (Java's `toJavaInstant()` equivalent).
  DateTime toDateTime() => DateTime.fromMillisecondsSinceEpoch(getUnixEpochMilliseconds(), isUtc: true);

  /// Same absolute time on [calendarKey] (offsets differ per calendar).
  Instant toCalendar(int calendarKey) {
    final offset = MillisecondStore.store().data(this.calendarKey).getUnixEpochOffsetMilliseconds();
    final otherOffset = MillisecondStore.store().data(calendarKey).getUnixEpochOffsetMilliseconds();
    final difference = offset - otherOffset;
    return Instant.ofEpoch(getEpochMilliseconds() - difference, calendarKey);
  }

  /// Millisecond difference on the timeline (positive if this is after
  /// [other]).
  int differenceWith(Instant other) {
    checkSameKeyAs(other);
    return getEpochMilliseconds() - other.getEpochMilliseconds();
  }

  /// Difference in beeps (truncated); see Java javadoc for cross-day behavior.
  int differenceInBeepsWith(Instant other) {
    checkSameKeyAs(other);
    final proportionDifference = _proportionOfDay - other.getProportionOfDay();
    final beepDifference = (proportionDifference * Fraction(beepsPerDay, 1)).toDouble().truncate();
    final dayDifference = _day.differenceWith(other.getDay()) * beepsPerDay;
    return beepDifference + dayDifference;
  }

  static bool _lessThan(Fraction a, Fraction b) {
    return a.numerator * b.denominator < b.numerator * a.denominator;
  }

  /// Creates an [Instant] from Lukashian [epochMilliseconds] and optional
  /// [calendarKey].
  static Instant ofEpoch(int epochMilliseconds, [int? calendarKey]) {
    final key = calendarKey ?? MillisecondStore.store().getDefaultCalendarKey();
    final store = MillisecondStore.store();
    final data = store.data(key);
    final day = Day.ofEpoch(data.getEpochDayForEpochMilliseconds(epochMilliseconds), key);
    final millisecondsOfDay = day.lengthInMilliseconds();
    final millisecondsPassed = epochMilliseconds - day.getEpochMillisecondsAtStartOfDay();
    final proportionOfDay = Fraction(millisecondsPassed, millisecondsOfDay);
    return Instant.of(day, proportionOfDay);
  }

  /// Creates an instant at [proportionOfDay] on [day].
  ///
  /// Throws [LukashianException] if [proportionOfDay] is not in `[0, 1)`.
  static Instant of(Day day, Fraction proportionOfDay) {
    final p = proportionOfDay.toDouble();
    LukashianException.check(
      p >= 0 && p < 1,
      () => 'Proportion of day must be between 0 (inclusive) and 1 (exclusive)',
    );
    return Instant._(day, proportionOfDay, day.getCalendarKey());
  }

  /// Creates an instant at [beeps] on [day].
  static Instant ofBeeps(Day day, int beeps) => Instant.of(day, Fraction(beeps, beepsPerDay));

  /// [of] with a [Year] and day-of-year.
  static Instant ofYearDay(Year year, int day, Fraction proportionOfDay) =>
      Instant.of(Day.of(year, day), proportionOfDay);

  /// [ofYearDay] with numeric year and optional [calendarKey].
  static Instant ofYearDayFraction(int year, int day, Fraction proportionOfDay, [int? calendarKey]) {
    final key = calendarKey ?? MillisecondStore.store().getDefaultCalendarKey();
    return Instant.of(Day.ofYearDay(year, day, key), proportionOfDay);
  }

  /// [ofBeeps] with [Year] and day-of-year.
  static Instant ofYearDayBeeps(Year year, int day, int beeps) => Instant.ofBeeps(Day.of(year, day), beeps);

  /// [ofYearDayBeeps] with numeric year and optional [calendarKey].
  static Instant ofYearDayBeepsKey(int year, int day, int beeps, [int? calendarKey]) {
    final key = calendarKey ?? MillisecondStore.store().getDefaultCalendarKey();
    return Instant.ofBeeps(Day.ofYearDay(year, day, key), beeps);
  }

  /// Lukashian instant from UNIX [unixEpochMilliseconds] (may be negative).
  static Instant ofUnixEpochMilliseconds(int unixEpochMilliseconds, [int? calendarKey]) {
    final key = calendarKey ?? MillisecondStore.store().getDefaultCalendarKey();
    return Instant.ofEpoch(
      MillisecondStore.store().data(key).getLukashianEpochMilliseconds(unixEpochMilliseconds),
      key,
    );
  }

  /// Same as [ofUnixEpochMilliseconds] for [dateTime]'s millis-since-epoch.
  static Instant ofDateTime(DateTime dateTime, [int? calendarKey]) {
    final key = calendarKey ?? MillisecondStore.store().getDefaultCalendarKey();
    return Instant.ofUnixEpochMilliseconds(dateTime.millisecondsSinceEpoch, key);
  }

  /// The current instant for optional [calendarKey].
  static Instant now([int? calendarKey]) {
    final key = calendarKey ?? MillisecondStore.store().getDefaultCalendarKey();
    final data = MillisecondStore.store().data(key);
    return Instant.ofEpoch(data.getCurrentEpochMilliseconds(), key);
  }

  @override
  int compareTo(Instant other) {
    checkSameKeyAs(other);
    return getEpochMilliseconds().compareTo(other.getEpochMilliseconds());
  }

  @override
  int get hashCode => Object.hash(getEpochMilliseconds(), calendarKey);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Instant && other.getEpochMilliseconds() == getEpochMilliseconds() && other.calendarKey == calendarKey);

  @override
  String toString() =>
      '[Instant: ${_day.getYear().getYearNumber()}-${_day.getDayNumber()} ${getBeeps().toString().padLeft(4, '0')}]';
}
