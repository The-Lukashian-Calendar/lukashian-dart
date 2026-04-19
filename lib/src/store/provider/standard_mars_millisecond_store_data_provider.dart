/*
 * Copyright (c) 2018-2026 (5918-5926 in Lukashian years)
 * All rights reserved.
 * (License header abbreviated.)
 */

import 'package:lukashian/lukashian.dart';

/// An implementation of [MillisecondStoreDataProvider] that implements the
/// Lukashian Calendar Mechanism for Mars: tropical years and true solar sols,
/// southern-solstice based — see the Java class
/// `StandardMarsMillisecondStoreDataProvider` for the full specification
/// (epoch choice, Pathfinder-related constraints, etc.).
///
/// **Dart port:** this class is a stub; every method throws [UnimplementedError].
/// Use [StandardMarsHttpMillisecondStoreDataProvider] to load data from
/// lukashian.org, or provide your own [MillisecondStoreDataProvider].
class StandardMarsMillisecondStoreDataProvider
    implements MillisecondStoreDataProvider {
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
  Future<List<int>> loadDayEpochMilliseconds(
    List<int> yearEpochMilliseconds,
  ) async {
    throw UnimplementedError(
      'StandardMarsMillisecondStoreDataProvider is not implemented; '
      'use StandardMarsHttpMillisecondStoreDataProvider or provide your own data',
    );
  }
}
