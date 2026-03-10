/*
 * Copyright (c) 2018-2026 (5918-5926 in Lukashian years)
 * All rights reserved.
 * (License header abbreviated.)
 */

import 'package:fraction/fraction.dart';

import 'day.dart';
import 'instant.dart';
import 'year.dart';

/// Ways to format a [Day].
enum DayFormat {
  /// Epoch day, e.g. '15592'.
  epoch,

  /// Year first, then day, e.g. '5919-43'.
  yearFirst,

  /// Day first, then year, e.g. '43-5919'.
  dayFirst,

  /// Day number only, e.g. '43'.
  dayOnly,
}

/// Formats Lukashian Calendar types to strings.
final class Formatter {
  Formatter._();

  /// Formats [year] as its number.
  static String formatYear(Year year) => year.getYearNumber().toString();

  /// Formats [day] with [format] and [separator]. Separator unused for [DayFormat.epoch] and [DayFormat.dayOnly].
  /// Throws [StateError] if [format] is null.
  static String formatDay(Day day, DayFormat? format, [String separator = '-']) {
    if (format == null) throw StateError('DayFormat must not be null');
    switch (format) {
      case DayFormat.epoch:
        return day.getEpochDay().toString();
      case DayFormat.yearFirst:
        return formatYear(day.getYear()) + separator + day.getDayNumber().toString();
      case DayFormat.dayFirst:
        return day.getDayNumber().toString() + separator + formatYear(day.getYear());
      case DayFormat.dayOnly:
        return day.getDayNumber().toString();
    }
  }

  /// Formats [day] with [DayFormat.yearFirst] and '-'.
  static String formatDayDefault(Day day) => formatDay(day, DayFormat.yearFirst);

  /// Formats [proportionOfDay] using [formatter], or beeps (4 digits) if null.
  static String formatProportion(Fraction proportionOfDay, [String Function(Fraction)? formatter]) {
    if (formatter != null) return formatter(proportionOfDay);
    final beeps = (proportionOfDay * Fraction(LukashianInstant.beepsPerDay, 1)).toDouble().truncate();
    return beeps.clamp(0, 9999).toString().padLeft(4, '0');
  }

  /// Formats [instant] with optional [dayFormat], [daySeparator], and proportion [formatter].
  static String formatInstant(
    LukashianInstant instant, {
    DayFormat dayFormat = DayFormat.yearFirst,
    String daySeparator = '-',
    String Function(Fraction)? formatter,
  }) {
    return '${formatDay(instant.getDay(), dayFormat, daySeparator)} ${formatProportion(instant.getProportionOfDay(), formatter)}';
  }
}
