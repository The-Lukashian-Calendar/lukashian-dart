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

/// The different ways to format a [Day] (see [Formatter.formatDay]).
enum DayFormat {
  /// Format the epoch day — which day it is since the start of the Lukashian
  /// Calendar, irrespective of the year — for example `'15592'`.
  epoch,

  /// Format the year first, then the day inside the year — for example
  /// `'5919-43'`.
  yearFirst,

  /// Format the day first, then the year of the day — for example `'43-5919'`.
  dayFirst,

  /// Format the day only — for example `'43'`.
  dayOnly,
}

/// Provides methods for formatting instances of the Lukashian Calendar classes.
///
/// This implementation is not as sophisticated as the Java formatting classes,
/// but should provide sufficient functionality for most use cases.
///
/// In Dart, overloads are named methods: [formatYear], [formatDay],
/// [formatDayDefault], [formatProportion], [formatInstant].
final class Formatter {
  Formatter._();

  /// Formats the given [year] by returning its year number as a string.
  static String formatYear(Year year) => year.getYearNumber().toString();

  /// Formats [day] according to [format], using [separator] between day and
  /// year where applicable.
  ///
  /// If [DayFormat.epoch] or [DayFormat.dayOnly] is chosen, [separator] is
  /// not used.
  ///
  /// Throws [StateError] if [format] is null.
  static String formatDay(
    Day day,
    DayFormat? format, [
    String separator = '-',
  ]) {
    if (format == null) throw StateError('DayFormat must not be null');
    switch (format) {
      case DayFormat.epoch:
        return day.getEpochDay().toString();
      case DayFormat.yearFirst:
        return formatYear(day.getYear()) +
            separator +
            day.getDayNumber().toString();
      case DayFormat.dayFirst:
        return day.getDayNumber().toString() +
            separator +
            formatYear(day.getYear());
      case DayFormat.dayOnly:
        return day.getDayNumber().toString();
    }
  }

  /// Formats [day] with [DayFormat.yearFirst] and `'-'` as separator.
  static String formatDayDefault(Day day) =>
      formatDay(day, DayFormat.yearFirst);

  /// Formats [proportionOfDay] using [formatter], or as four-digit beeps
  /// (0–9999) if [formatter] is null.
  ///
  /// For how the proportion maps to beeps, see [Instant.getBeeps]. Basis points:
  /// <https://en.wikipedia.org/wiki/Basis_point>.
  static String formatProportion(
    Fraction proportionOfDay, [
    String Function(Fraction)? formatter,
  ]) {
    if (formatter != null) return formatter(proportionOfDay);
    final beeps = (proportionOfDay * Fraction(Instant.beepsPerDay, 1))
        .toDouble()
        .truncate();
    return beeps.clamp(0, 9999).toString().padLeft(4, '0');
  }

  /// Formats [instant] using [formatDay] and [formatProportion], separated by
  /// a space.
  static String formatInstant(
    Instant instant, {
    DayFormat dayFormat = DayFormat.yearFirst,
    String daySeparator = '-',
    String Function(Fraction)? formatter,
  }) {
    return '${formatDay(instant.getDay(), dayFormat, daySeparator)} ${formatProportion(instant.getProportionOfDay(), formatter)}';
  }
}
