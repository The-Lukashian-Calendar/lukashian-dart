/*
 * Copyright (c) 2018-2026 (5918-5926 in Lukashian years)
 * All rights reserved.
 * (License header abbreviated.)
 */

import 'dart:io';

import '../external_resource_millisecond_store_data_provider.dart';

/// Loads epoch data from files. Base path should end with a path separator;
/// extensions are appended as-is (e.g. "unixEpochOffset").
class FileMillisecondStoreDataProvider
    extends ExternalResourceMillisecondStoreDataProvider {
  FileMillisecondStoreDataProvider(
    super.baseLocation,
    super.unixEpochOffsetExtension,
    super.yearEpochMillisecondsExtension,
    super.dayEpochMillisecondsExtension,
  );

  // note: cannot use super.baseLocation - would mix super parameter with positional super call.
  // ignore: use_super_parameters
  FileMillisecondStoreDataProvider.withDefaults(String baseLocation)
    : super.withDefaults(baseLocation);

  @override
  Future<List<int>> loadMillisecondsByteArray(String path) async {
    final file = File(path);
    return file.readAsBytes();
  }
}
