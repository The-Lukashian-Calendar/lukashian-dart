/*
 * Copyright (c) 2018-2026 (5918-5926 in Lukashian years)
 * All rights reserved.
 * (License header abbreviated.)
 */

import 'dart:io';

import 'package:lukashian/lukashian.dart';

/// Loads binary epoch millisecond streams from the local filesystem.
///
/// See [ExternalResourceMillisecondStoreDataProvider] for format and path rules.
///
/// Useful when you want the same data as [StandardEarthHttpMillisecondStoreDataProvider]
/// but offline: download the default resources from the same URLs (e.g. with
/// `curl`) into a directory whose path you pass as [baseLocation].
class FileMillisecondStoreDataProvider
    extends ExternalResourceMillisecondStoreDataProvider {
  /// Same as [ExternalResourceMillisecondStoreDataProvider] constructor.
  FileMillisecondStoreDataProvider(
    super.baseLocation,
    super.unixEpochOffsetExtension,
    super.yearEpochMillisecondsExtension,
    super.dayEpochMillisecondsExtension,
  );

  /// Same as [ExternalResourceMillisecondStoreDataProvider.withDefaults].
  // ignore: use_super_parameters — explicit forward matches original pattern.
  FileMillisecondStoreDataProvider.withDefaults(String baseLocation)
    : super.withDefaults(baseLocation);

  @override
  Future<List<int>> loadMillisecondsByteArray(String path) async {
    final file = File(path);
    return file.readAsBytes();
  }
}
