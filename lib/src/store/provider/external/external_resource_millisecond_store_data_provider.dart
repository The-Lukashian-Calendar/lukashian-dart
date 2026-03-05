/*
 * Copyright (c) 2018-2026 (5918-5926 in Lukashian years)
 * All rights reserved.
 * (License header abbreviated.)
 */

import 'dart:typed_data';

import '../../millisecond_store_data_provider.dart';

/// Base for loading epoch data from an external resource (file or URL).
/// Combines [baseLocation] with per-resource extensions and decodes 8-byte
/// big-endian long values. Subclasses implement [loadMillisecondsByteArray].
abstract class ExternalResourceMillisecondStoreDataProvider implements MillisecondStoreDataProvider {
  static const String defaultUnixEpochOffsetExtension = 'unixEpochOffset';
  static const String defaultYearEpochMillisecondsExtension = 'yearEpochMilliseconds';
  static const String defaultDayEpochMillisecondsExtension = 'dayEpochMilliseconds';

  ExternalResourceMillisecondStoreDataProvider(
    this.baseLocation,
    this.unixEpochOffsetExtension,
    this.yearEpochMillisecondsExtension,
    this.dayEpochMillisecondsExtension,
  );

  ExternalResourceMillisecondStoreDataProvider.withDefaults(String baseLocation)
      : this(
          baseLocation,
          defaultUnixEpochOffsetExtension,
          defaultYearEpochMillisecondsExtension,
          defaultDayEpochMillisecondsExtension,
        );

  final String baseLocation;
  final String unixEpochOffsetExtension;
  final String yearEpochMillisecondsExtension;
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
  Future<List<int>> loadDayEpochMilliseconds(List<int> yearEpochMilliseconds) async {
    return _loadMilliseconds(dayEpochMillisecondsExtension);
  }

  Future<List<int>> _loadMilliseconds(String extension) async {
    try {
      final bytes = await loadMillisecondsByteArray(baseLocation + extension);
      if (bytes.isEmpty) {
        throw Exception("No bytes could be loaded from '$baseLocation$extension'");
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

  /// Decodes 8-byte big-endian longs from [bytes]. Same format as Java ByteBuffer.asLongBuffer().
  static List<int> _decodeLongs(List<int> bytes) {
    final data = ByteData.sublistView(Uint8List.fromList(bytes));
    final count = bytes.length ~/ 8;
    final result = <int>[];
    for (var i = 0; i < count; i++) {
      result.add(data.getInt64(i * 8, Endian.big));
    }
    return result;
  }

  /// Loads raw bytes from the given location (base + extension). Each 8 bytes = one epoch millisecond value.
  Future<List<int>> loadMillisecondsByteArray(String location);
}
