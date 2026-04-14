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
    if (rest.length > 1) {
      throw FormatException(
        'At most one ISO_DATE argument is allowed; received ${rest.length}: ${rest.join(' ')}',
      );
    }
    final isoDate = rest.isEmpty ? null : rest[0];

    await _run(calendarKey: calendarKey, isoDate: isoDate);
  } on FormatException catch (e) {
    print('Error: ${e.message}');
    _printHelp();
    exit(1);
  } on LukashianException catch (e) {
    print('Error: $e');
    exit(1);
  } on StateError catch (e) {
    print('Error: $e');
    exit(1);
  }
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
    final trimmed = isoDate.trim();
    final dateTime = DateTime.tryParse(trimmed);
    if (dateTime == null) {
      stderr.writeln(
        'Warning: could not parse ISO_DATE "$trimmed"; using current date/time.',
      );
    }
    instant = LukashianInstant.ofDateTime(
      dateTime ?? DateTime.now(),
      calendarKey,
    );
  } else {
    instant = LukashianInstant.now(calendarKey);
  }

  print(Formatter.formatInstant(instant, dayFormat: DayFormat.dayFirst));
}

void _printHelp() {
  print('''
Lukashian CLI – convert Earth date to Lukashian date (official lukashian.org)

Usage:
  dart run example/lukashian_example.dart [options] [ISO_DATE]

  If ISO_DATE is omitted, the current date/time is used.
  ISO_DATE must be in ISO 8601 format (e.g. 2025-03-28 or 2025-03-28T12:00:00Z).
  If ISO_DATE cannot be parsed, a warning is printed and the current date/time is used.
  Out-of-range elements overflow to the next unit (e.g. 2025-03-32 is 2025-04-01).


Options:
  -c, --calendar    Calendar: earth or mars (default: earth)
  -h, --help        Show this help message
''');
}
