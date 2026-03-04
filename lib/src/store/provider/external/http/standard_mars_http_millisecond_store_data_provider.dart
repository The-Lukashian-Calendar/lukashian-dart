/*
 * Copyright (c) 2018-2026 (5918-5926 in Lukashian years)
 * All rights reserved.
 * (License header abbreviated.)
 */

import 'http_millisecond_store_data_provider.dart';

/// Loads the Standard Mars calendar from the official lukashian.org server.
class StandardMarsHttpMillisecondStoreDataProvider extends HttpMillisecondStoreDataProvider {
  StandardMarsHttpMillisecondStoreDataProvider()
      : super.withDefaults('https://lukashian.org/millisecondstore/standardmars/');
}
