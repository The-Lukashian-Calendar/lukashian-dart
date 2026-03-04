/// Command-line tool to convert an Earth date (or now) to the Lukashian date
/// using the official lukashian.org endpoint.
///
/// Usage:
///   dart run example/lukashian_example.dart [options] [ISO_DATE]
///
/// Options:
///   -c, --calendar    Calendar: earth or mars (default: earth)
///   -h, --help        Show this help message
library;

import 'dart:io';

import 'package:args/args.dart';
import 'package:lukashian/lukashian.dart';

void main(List<String> args) async {
  final parser = ArgParser()
    ..addOption(
      'calendar',
      abbr: 'c',
      help: 'Calendar: earth or mars (uses official lukashian.org data)',
      allowed: ['earth', 'mars'],
      defaultsTo: 'earth',
    )
    ..addFlag(
      'help',
      abbr: 'h',
      help: 'Show this help message',
      negatable: false,
    );

  try {
    final results = parser.parse(args);

    if (results['help'] as bool) {
      _printHelp();
      exit(0);
    }

    final calendarArg = results['calendar'] as String;
    final calendarKey = calendarArg == 'mars'
        ? CalendarKeys.marsHttpLukashianOrg
        : CalendarKeys.earthHttpLukashianOrg;

    final rest = results.rest;
    final isoDate = rest.isNotEmpty ? rest.single : null;

    await _run(calendarKey: calendarKey, isoDate: isoDate);
  } on FormatException catch (e) {
    print('Error: ${e.message}');
    _printHelp();
    exit(1);
  } on LukashianException catch (e) {
    print('Error: $e');
    exit(1);
  }
  exit(0);
}

Future<void> _run({required int calendarKey, String? isoDate}) async {
  final store = MillisecondStore.store();

  store.registerProvider(
    CalendarKeys.earthHttpLukashianOrg,
    StandardEarthHttpMillisecondStoreDataProvider(),
  );
  store.registerProvider(
    CalendarKeys.marsHttpLukashianOrg,
    StandardMarsHttpMillisecondStoreDataProvider(),
  );

  await store.ensureLoaded(calendarKey);
  store.setDefaultCalendarKey(calendarKey);

  final LukashianInstant instant;
  if (isoDate != null && isoDate.trim().isNotEmpty) {
    final dateTime = DateTime.parse(isoDate.trim());
    instant = LukashianInstant.ofDateTime(dateTime, calendarKey);
  } else {
    instant = LukashianInstant.now(calendarKey);
  }

  print(Formatter.formatInstant(instant));
}

void _printHelp() {
  print('''
Lukashian CLI – convert Earth date to Lukashian date (official lukashian.org)

Usage:
  dart run example/lukashian_example.dart [options] [ISO_DATE]

  If ISO_DATE is omitted, the current date/time is used.
  ISO_DATE must be in ISO 8601 format (e.g. 2025-03-04 or 2025-03-04T12:00:00Z).

Options:
  -c, --calendar    Calendar: earth or mars (default: earth)
  -h, --help        Show this help message
''');
}
