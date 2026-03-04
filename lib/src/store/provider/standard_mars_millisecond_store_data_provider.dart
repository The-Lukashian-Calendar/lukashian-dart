/*
 * Copyright (c) 2018-2026 (5918-5926 in Lukashian years)
 * All rights reserved.
 * (License header abbreviated.)
 */

import '../millisecond_store_data_provider.dart';

/// Stub for the computed Standard Mars calendar provider.
/// Use [StandardMarsHttpMillisecondStoreDataProvider] to load Mars data from lukashian.org,
/// or implement [MillisecondStoreDataProvider] yourself.
class StandardMarsMillisecondStoreDataProvider implements MillisecondStoreDataProvider {
  @override
  Future<int> loadUnixEpochOffsetMilliseconds() async {
    throw UnimplementedError(
      'StandardMarsMillisecondStoreDataProvider is not implemented; '
      'use StandardMarsHttpMillisecondStoreDataProvider or provide your own data',
    );
  }

  @override
  Future<List<int>> loadYearEpochMilliseconds() async {
    throw UnimplementedError(
      'StandardMarsMillisecondStoreDataProvider is not implemented; '
      'use StandardMarsHttpMillisecondStoreDataProvider or provide your own data',
    );
  }

  @override
  Future<List<int>> loadDayEpochMilliseconds(List<int> yearEpochMilliseconds) async {
    throw UnimplementedError(
      'StandardMarsMillisecondStoreDataProvider is not implemented; '
      'use StandardMarsHttpMillisecondStoreDataProvider or provide your own data',
    );
  }
}
