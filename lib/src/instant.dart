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
import 'day.dart';
import 'lukashian_exception.dart';
import 'store/millisecond_store.dart';
import 'year.dart';

/// Represents a unique millisecond on the Lukashian timeline; also represents time-of-day as proportion (0..1) or beeps (0..9999).
final class Instant extends CalendarObject implements Comparable<Instant> {
  Instant._(this._day, this._proportionOfDay, super.calendarKey);

  static const int beepsPerDay = 10000;

  final Day _day;
  final Fraction _proportionOfDay;

  Instant minusYears(int yearsToSubtract) =>
      Instant.of(_day.minusYears(yearsToSubtract), _proportionOfDay);
  Instant plusYears(int yearsToAdd) =>
      Instant.of(_day.plusYears(yearsToAdd), _proportionOfDay);
  Instant minusDays(int daysToSubtract) =>
      Instant.of(_day.minusDays(daysToSubtract), _proportionOfDay);
  Instant plusDays(int daysToAdd) =>
      Instant.of(_day.plusDays(daysToAdd), _proportionOfDay);
  Instant atPreviousDay() => minusDays(1);
  Instant atNextDay() => plusDays(1);

  Instant minusMilliseconds(int millisecondsToSubtract) {
    if (millisecondsToSubtract < 0)
      return plusMilliseconds(-millisecondsToSubtract);
    return Instant.ofEpoch(
      getEpochMilliseconds() - millisecondsToSubtract,
      calendarKey,
    );
  }

  Instant minusSeconds(int secondsToSubtract) =>
      minusMilliseconds(secondsToSubtract * 1000);

  Instant plusMilliseconds(int millisecondsToAdd) {
    if (millisecondsToAdd < 0) return minusMilliseconds(-millisecondsToAdd);
    return Instant.ofEpoch(
      getEpochMilliseconds() + millisecondsToAdd,
      calendarKey,
    );
  }

  Instant plusSeconds(int secondsToAdd) =>
      plusMilliseconds(secondsToAdd * 1000);

  Instant minusProportionOfDay(Fraction proportionToSubtract) {
    if (_lessThan(proportionToSubtract, Fraction(0, 1)))
      return plusProportionOfDay(Fraction(0, 1) - proportionToSubtract);
    Fraction totalProportion = _proportionOfDay - proportionToSubtract;
    int daysToSubtract = (Fraction(0, 1) - totalProportion)
        .toDouble()
        .truncate();
    Fraction remainingProportion =
        totalProportion + Fraction(daysToSubtract, 1);
    if (_lessThan(remainingProportion, Fraction(0, 1))) {
      daysToSubtract++;
      remainingProportion = remainingProportion + Fraction(1, 1);
    }
    return Instant.of(_day.minusDays(daysToSubtract), remainingProportion);
  }

  Instant minusBeeps(int beepsToSubtract) =>
      minusProportionOfDay(Fraction(beepsToSubtract, beepsPerDay));

  Instant plusProportionOfDay(Fraction proportionToAdd) {
    if (_lessThan(proportionToAdd, Fraction(0, 1)))
      return minusProportionOfDay(proportionToAdd.negate());
    Fraction totalProportion = _proportionOfDay + proportionToAdd;
    int daysToAdd = totalProportion.toDouble().truncate();
    Fraction remainingProportion = totalProportion - Fraction(daysToAdd, 1);
    return Instant.of(_day.plusDays(daysToAdd), remainingProportion);
  }

  Instant plusBeeps(int beepsToAdd) =>
      plusProportionOfDay(Fraction(beepsToAdd, beepsPerDay));

  bool isBefore(Instant other) {
    checkSameKeyAs(other);
    return getEpochMilliseconds() < other.getEpochMilliseconds();
  }

  bool isSameOrBefore(Instant other) {
    checkSameKeyAs(other);
    return getEpochMilliseconds() <= other.getEpochMilliseconds();
  }

  bool isAfter(Instant other) {
    checkSameKeyAs(other);
    return getEpochMilliseconds() > other.getEpochMilliseconds();
  }

  bool isSameOrAfter(Instant other) {
    checkSameKeyAs(other);
    return getEpochMilliseconds() >= other.getEpochMilliseconds();
  }

  bool isIn(CalendarObject other) {
    checkSameKeyAs(other);
    if (other is Year) return other.contains(this);
    if (other is Day) return other.contains(this);
    return false;
  }

  bool isNotIn(CalendarObject other) {
    checkSameKeyAs(other);
    return !isIn(other);
  }

  int getEpochMilliseconds() {
    final millisecondsOfDay = _day.lengthInMilliseconds();
    Fraction resultingMillisecond =
        Fraction(millisecondsOfDay, 1) * _proportionOfDay;
    if (resultingMillisecond ==
        Fraction(resultingMillisecond.toDouble().truncate(), 1)) {
      resultingMillisecond = resultingMillisecond + Fraction(1, 1);
    }
    final resultingMillisecondLong = resultingMillisecond.toDouble().ceil();
    return _day.getEpochMillisecondsPreviousDay() + resultingMillisecondLong;
  }

  int getMillisecond() => getEpochMilliseconds();

  Fraction getProportionOfDay() => _proportionOfDay;
  Day getDay() => _day;

  Year getYear() => Year.of(
    MillisecondStore.store()
        .data(calendarKey)
        .getYearForEpochMilliseconds(getEpochMilliseconds()),
    calendarKey,
  );

  int getBeeps() =>
      (_proportionOfDay * Fraction(beepsPerDay, 1)).toDouble().truncate();

  int getUnixEpochMilliseconds() => MillisecondStore.store()
      .data(calendarKey)
      .getUnixEpochMilliseconds(getEpochMilliseconds());

  DateTime toDateTime() => DateTime.fromMillisecondsSinceEpoch(
    getUnixEpochMilliseconds(),
    isUtc: true,
  );

  Instant toCalendar(int calendarKey) {
    final offset = MillisecondStore.store()
        .data(this.calendarKey)
        .getUnixEpochOffsetMilliseconds();
    final otherOffset = MillisecondStore.store()
        .data(calendarKey)
        .getUnixEpochOffsetMilliseconds();
    final difference = offset - otherOffset;
    return Instant.ofEpoch(getEpochMilliseconds() - difference, calendarKey);
  }

  int differenceWith(Instant other) {
    checkSameKeyAs(other);
    return getEpochMilliseconds() - other.getEpochMilliseconds();
  }

  int differenceInBeepsWith(Instant other) {
    checkSameKeyAs(other);
    final proportionDifference = _proportionOfDay - other.getProportionOfDay();
    final beepDifference = (proportionDifference * Fraction(beepsPerDay, 1))
        .toDouble()
        .truncate();
    final dayDifference = _day.differenceWith(other.getDay()) * beepsPerDay;
    return beepDifference + dayDifference;
  }

  static bool _lessThan(Fraction a, Fraction b) => a.toDouble() < b.toDouble();

  static Instant ofEpoch(int epochMilliseconds, [int? calendarKey]) {
    final key = calendarKey ?? MillisecondStore.store().getDefaultCalendarKey();
    final store = MillisecondStore.store();
    final data = store.data(key);
    final day = Day.ofEpoch(
      data.getEpochDayForEpochMilliseconds(epochMilliseconds),
      key,
    );
    final millisecondsOfDay = day.lengthInMilliseconds();
    final millisecondsPassed =
        epochMilliseconds - day.getEpochMillisecondsAtStartOfDay();
    final proportionOfDay = Fraction(millisecondsPassed, millisecondsOfDay);
    return Instant.of(day, proportionOfDay);
  }

  static Instant of(Day day, Fraction proportionOfDay) {
    final p = proportionOfDay.toDouble();
    LukashianException.check(
      p >= 0 && p < 1,
      () => 'Proportion of day must be between 0 (inclusive) and 1 (exclusive)',
    );
    return Instant._(day, proportionOfDay, day.getCalendarKey());
  }

  static Instant ofBeeps(Day day, int beeps) =>
      Instant.of(day, Fraction(beeps, beepsPerDay));

  static Instant ofYearDay(Year year, int day, Fraction proportionOfDay) =>
      Instant.of(Day.of(year, day), proportionOfDay);
  static Instant ofYearDayFraction(
    int year,
    int day,
    Fraction proportionOfDay, [
    int? calendarKey,
  ]) {
    final key = calendarKey ?? MillisecondStore.store().getDefaultCalendarKey();
    return Instant.of(Day.ofYearDay(year, day, key), proportionOfDay);
  }

  static Instant ofYearDayBeeps(Year year, int day, int beeps) =>
      Instant.ofBeeps(Day.of(year, day), beeps);
  static Instant ofYearDayBeepsKey(
    int year,
    int day,
    int beeps, [
    int? calendarKey,
  ]) {
    final key = calendarKey ?? MillisecondStore.store().getDefaultCalendarKey();
    return Instant.ofBeeps(Day.ofYearDay(year, day, key), beeps);
  }

  static Instant ofUnixEpochMilliseconds(
    int unixEpochMilliseconds, [
    int? calendarKey,
  ]) {
    final key = calendarKey ?? MillisecondStore.store().getDefaultCalendarKey();
    return Instant.ofEpoch(
      MillisecondStore.store()
          .data(key)
          .getLukashianEpochMilliseconds(unixEpochMilliseconds),
      key,
    );
  }

  static Instant ofDateTime(DateTime dateTime, [int? calendarKey]) {
    final key = calendarKey ?? MillisecondStore.store().getDefaultCalendarKey();
    return Instant.ofUnixEpochMilliseconds(
      dateTime.millisecondsSinceEpoch,
      key,
    );
  }

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
      (other is Instant &&
          other.getEpochMilliseconds() == getEpochMilliseconds() &&
          other.calendarKey == calendarKey);

  @override
  String toString() =>
      '[Instant: ${_day.getYear().getYearNumber()}-${_day.getDayNumber()} ${getBeeps().toString().padLeft(4, '0')}]';
}
