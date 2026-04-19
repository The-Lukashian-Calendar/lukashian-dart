/*
 * Copyright (c) 2018-2026 (5918-5926 in Lukashian years)
 * All rights reserved.
 * (License header abbreviated.)
 */

import 'package:fraction/fraction.dart';

import 'day.dart';
import 'instant.dart';
import 'year.dart';

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
