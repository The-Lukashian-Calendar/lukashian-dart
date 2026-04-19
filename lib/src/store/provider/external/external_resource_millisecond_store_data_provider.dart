/*
 * Copyright (c) 2018-2026 (5918-5926 in Lukashian years)
 * All rights reserved.
 * (License header abbreviated.)
 */

import 'dart:typed_data';

import 'package:lukashian/lukashian.dart';

/// Base functionality for loading epoch millisecond arrays from an external
/// resource (file or URL), so the exact numbers can be maintained centrally.
///
/// A [MillisecondStoreDataProvider] must supply the UNIX offset, year epoch
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
    implements MillisecondStoreDataProvider {
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
