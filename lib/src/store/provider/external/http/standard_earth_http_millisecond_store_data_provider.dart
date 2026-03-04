/*
 * Copyright (c) 2018-2026 (5918-5926 in Lukashian years)
 * All rights reserved.
 * (License header abbreviated.)
 */

import 'http_millisecond_store_data_provider.dart';

/// Loads the Standard Earth calendar from the official lukashian.org server.
class StandardEarthHttpMillisecondStoreDataProvider extends HttpMillisecondStoreDataProvider {
  StandardEarthHttpMillisecondStoreDataProvider()
      : super.withDefaults('https://lukashian.org/millisecondstore/standardearth/');
}
