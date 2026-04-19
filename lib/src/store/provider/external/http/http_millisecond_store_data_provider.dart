/*
 * Copyright (c) 2018-2026 (5918-5926 in Lukashian years)
 * All rights reserved.
 * (License header abbreviated.)
 */

import 'dart:io';
import 'dart:typed_data';

import '../external_resource_millisecond_store_data_provider.dart';

/// Loads binary epoch millisecond streams over HTTP(S) using `dart:io`
/// [HttpClient].
///
/// See [ExternalResourceMillisecondStoreDataProvider] for URL layout and binary
/// format.
///
/// **Platform note:** uses `dart:io` and is only available on the Dart VM (not
/// on web). The Java library uses the JDK HTTP client instead.
class HttpMillisecondStoreDataProvider
    extends ExternalResourceMillisecondStoreDataProvider {
  /// Same as [ExternalResourceMillisecondStoreDataProvider] constructor.
  HttpMillisecondStoreDataProvider(
    super.baseLocation,
    super.unixEpochOffsetExtension,
    super.yearEpochMillisecondsExtension,
    super.dayEpochMillisecondsExtension,
  );

  /// Same as [ExternalResourceMillisecondStoreDataProvider.withDefaults].
  // ignore: use_super_parameters — explicit forward matches original pattern.
  HttpMillisecondStoreDataProvider.withDefaults(String baseLocation)
    : super.withDefaults(baseLocation);

  @override
  Future<List<int>> loadMillisecondsByteArray(String url) async {
    final client = HttpClient()
      ..connectionTimeout = const Duration(seconds: 10);
    try {
      final request = await client
          .getUrl(Uri.parse(url))
          .timeout(const Duration(seconds: 10));
      request.headers.set('Accept', 'application/octet-stream');
      final response = await request.close().timeout(const Duration(seconds: 15));
      if (response.statusCode != 200) {
        throw HttpException(
          'Expected response code 200, instead received response code ${response.statusCode}',
        );
      }
      final builder = BytesBuilder();
      await for (final chunk in response.timeout(const Duration(seconds: 15))) {
        builder.add(chunk);
      }
      return builder.toBytes();
    } finally {
      client.close();
    }
  }
}
