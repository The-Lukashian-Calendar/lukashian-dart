/*
 * Copyright (c) 2018-2026 (5918-5926 in Lukashian years)
 * All rights reserved.
 * (License header abbreviated.)
 */

import 'http_millisecond_store_data_provider.dart';

/// [HttpMillisecondStoreDataProvider] that loads from the official lukashian.org
/// Standard Mars millisecond store.
///
/// Server-side values are produced by the Java class
/// `StandardMarsMillisecondStoreDataProvider`.
class StandardMarsHttpMillisecondStoreDataProvider extends HttpMillisecondStoreDataProvider {
  /// Uses `https://lukashian.org/millisecondstore/standardmars/` as base URL.
  StandardMarsHttpMillisecondStoreDataProvider()
      : super.withDefaults('https://lukashian.org/millisecondstore/standardmars/');
}
