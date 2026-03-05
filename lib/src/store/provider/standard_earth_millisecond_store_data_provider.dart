/*
 * Copyright (c) 2018-2026 (5918-5926 in Lukashian years)
 * All rights reserved.
 * (License header abbreviated.)
 */

import '../millisecond_store_data_provider.dart';

/// Stub for the computed Standard Earth calendar provider.
/// Use [StandardEarthHttpMillisecondStoreDataProvider] to load Earth data from lukashian.org,
/// or implement [MillisecondStoreDataProvider] yourself.
class StandardEarthMillisecondStoreDataProvider implements MillisecondStoreDataProvider {
  @override
  Future<int> loadUnixEpochOffsetMilliseconds() async {
    throw UnimplementedError(
      'StandardEarthMillisecondStoreDataProvider is not implemented; '
      'use StandardEarthHttpMillisecondStoreDataProvider or provide your own data',
    );
  }

  @override
  Future<List<int>> loadYearEpochMilliseconds() async {
    throw UnimplementedError(
      'StandardEarthMillisecondStoreDataProvider is not implemented; '
      'use StandardEarthHttpMillisecondStoreDataProvider or provide your own data',
    );
  }

  @override
  Future<List<int>> loadDayEpochMilliseconds(List<int> yearEpochMilliseconds) async {
    throw UnimplementedError(
      'StandardEarthMillisecondStoreDataProvider is not implemented; '
      'use StandardEarthHttpMillisecondStoreDataProvider or provide your own data',
    );
  }
}
