/*
 * Copyright (c) 2018-2026 (5918-5926 in Lukashian years)
 * All rights reserved.
 * (License header abbreviated.)
 */

import 'http_millisecond_store_data_provider.dart';

/// [HttpMillisecondStoreDataProvider] that loads from the official lukashian.org
/// Standard Earth millisecond store.
///
/// Server-side values are produced by the Java class
/// `StandardEarthMillisecondStoreDataProvider`.
class StandardEarthHttpMillisecondStoreDataProvider extends HttpMillisecondStoreDataProvider {
  /// Uses `https://lukashian.org/millisecondstore/standardearth/` as base URL.
  StandardEarthHttpMillisecondStoreDataProvider()
      : super.withDefaults('https://lukashian.org/millisecondstore/standardearth/');
}
