/*
 * Copyright (c) 2018-2026 (5918-5926 in Lukashian years)
 * All rights reserved.
 * (License header abbreviated.)
 */

import '../millisecond_store_data_provider.dart';

/// An implementation of [MillisecondStoreDataProvider] that implements the
/// Lukashian Calendar Mechanism for Earth: tropical (southern-solstice to
/// southern-solstice) years, true solar days, TT-based, with year numbers
/// roughly 3900 above the Gregorian calendar — see the Java class
/// `StandardEarthMillisecondStoreDataProvider` for the full specification.
///
/// **Dart port:** this class is a stub; every method throws [UnimplementedError].
/// Use [StandardEarthHttpMillisecondStoreDataProvider] to load the same data
/// from lukashian.org, or provide your own [MillisecondStoreDataProvider].
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
