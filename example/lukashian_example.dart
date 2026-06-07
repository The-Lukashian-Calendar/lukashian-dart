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
    stderr.writeln('Error: ${e.message}');
    _printHelp();
    exit(1);
  } on LukashianException catch (e) {
    stderr.writeln('Error: $e');
    exit(1);
  } on StateError catch (e) {
    stderr.writeln('Error: $e');
    exit(1);
  } on Exception catch (e) {
    stderr.writeln('Error: $e');
    exit(1);
  }
}

Future<void> _run({required int calendarKey, String? isoDate}) async {
  final store = MillisecondStore.store();

  await store.init();
  store.setDefaultCalendarKey(calendarKey);

  final Instant instant;
  if (isoDate != null && isoDate.trim().isNotEmpty) {
    final trimmed = isoDate.trim();
    final dateTime = DateTime.tryParse(trimmed);
    if (dateTime == null) {
      throw FormatException(
        'Could not parse ISO_DATE "$trimmed". '
        'Use ISO 8601 format (e.g. 2025-03-28 or 2025-03-28T12:00:00Z).',
      );
    }
    instant = Instant.ofDateTime(dateTime, calendarKey);
  } else {
    instant = Instant.now(calendarKey);
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
  Out-of-range elements overflow to the next unit (e.g. 2025-03-32 is 2025-04-01).


Options:
  -c, --calendar    Calendar: earth or mars (default: earth)
  -h, --help        Show this help message
''');
}
