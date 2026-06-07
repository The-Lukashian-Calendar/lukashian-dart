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

import 'dart:typed_data';

import 'package:lukashian/lukashian.dart';

/// Base functionality for loading epoch millisecond arrays from an external
/// resource (file or URL), so the exact numbers can be maintained centrally.
///
/// An [AsyncMillisecondStoreDataProvider] must supply the UNIX offset, year epoch
/// milliseconds, and day epoch milliseconds — see [MillisecondStoreDataProvider].
///
/// This class combines [baseLocation] with three extensions (one per load
/// method). **The base location must end with a path separator**; extensions
/// are appended as-is.
///
/// Defaults match the Java constants
/// [defaultUnixEpochOffsetExtension], [defaultYearEpochMillisecondsExtension],
/// [defaultDayEpochMillisecondsExtension].
///
/// Data is a binary stream: **each consecutive 8 bytes is one signed epoch
/// millisecond value** (big-endian), same as Java `ByteBuffer` longs. The UNIX
/// offset stream must contain exactly one value.
///
/// Subclasses implement [loadMillisecondsByteArray] for the actual I/O (file,
/// HTTP, etc.).
///
/// See also [FileMillisecondStoreDataProvider], [HttpMillisecondStoreDataProvider].
abstract class ExternalResourceMillisecondStoreDataProvider
    implements AsyncMillisecondStoreDataProvider {
  /// Default extension for [loadUnixEpochOffsetMilliseconds] (one 8-byte value).
  static const String defaultUnixEpochOffsetExtension = 'unixEpochOffset';

  /// Default extension for [loadYearEpochMilliseconds].
  static const String defaultYearEpochMillisecondsExtension =
      'yearEpochMilliseconds';

  /// Default extension for [loadDayEpochMilliseconds].
  static const String defaultDayEpochMillisecondsExtension =
      'dayEpochMilliseconds';

  /// Creates a provider that loads from [baseLocation] with the given
  /// [unixEpochOffsetExtension], [yearEpochMillisecondsExtension], and
  /// [dayEpochMillisecondsExtension].
  ///
  /// **The base location must end with a path separator.**
  ExternalResourceMillisecondStoreDataProvider(
    this.baseLocation,
    this.unixEpochOffsetExtension,
    this.yearEpochMillisecondsExtension,
    this.dayEpochMillisecondsExtension,
  );

  /// Creates a provider using [baseLocation] and [defaultUnixEpochOffsetExtension],
  /// [defaultYearEpochMillisecondsExtension], [defaultDayEpochMillisecondsExtension].
  ///
  /// **The base location must end with a path separator.**
  ExternalResourceMillisecondStoreDataProvider.withDefaults(String baseLocation)
    : this(
        baseLocation,
        defaultUnixEpochOffsetExtension,
        defaultYearEpochMillisecondsExtension,
        defaultDayEpochMillisecondsExtension,
      );

  /// Base URL or directory, ending with `/` or the platform path separator.
  final String baseLocation;

  /// Extension appended to [baseLocation] for the UNIX offset file.
  final String unixEpochOffsetExtension;

  /// Extension appended to [baseLocation] for year epoch milliseconds.
  final String yearEpochMillisecondsExtension;

  /// Extension appended to [baseLocation] for day epoch milliseconds.
  final String dayEpochMillisecondsExtension;

  @override
  Future<int> loadUnixEpochOffsetMilliseconds() async {
    final list = await _loadMilliseconds(unixEpochOffsetExtension);
    if (list.length != 1) {
      throw StateError('Expected exactly one unix epoch offset');
    }
    return list[0];
  }

  @override
  Future<List<int>> loadYearEpochMilliseconds() async {
    return _loadMilliseconds(yearEpochMillisecondsExtension);
  }

  @override
  Future<List<int>> loadDayEpochMilliseconds(
    List<int> yearEpochMilliseconds,
  ) async {
    return _loadMilliseconds(dayEpochMillisecondsExtension);
  }

  Future<List<int>> _loadMilliseconds(String extension) async {
    try {
      final bytes = await loadMillisecondsByteArray(baseLocation + extension);
      if (bytes.isEmpty) {
        throw Exception(
          "No bytes could be loaded from '$baseLocation$extension'",
        );
      }
      if (bytes.length % 8 != 0) {
        throw ArgumentError(
          'Number of bytes is not a multiple of 8, which is required for reading long values',
        );
      }
      return _decodeLongs(bytes);
    } catch (e, st) {
      Error.throwWithStackTrace(
        Exception(
          'Exception occurred during loading of milliseconds from External Resource: $e',
        ),
        st,
      );
    }
  }

  /// Decodes 8-byte big-endian signed integers from [bytes] (Java long layout).
  static List<int> _decodeLongs(List<int> bytes) {
    final data = ByteData.sublistView(Uint8List.fromList(bytes));
    final count = bytes.length ~/ 8;
    final result = <int>[];
    for (var i = 0; i < count; i++) {
      result.add(data.getInt64(i * 8, Endian.big));
    }
    return result;
  }

  /// Loads the raw bytes for the full resource path [location] (`base` +
  /// `extension`).
  Future<List<int>> loadMillisecondsByteArray(String location);
}
