/*
 * Copyright (c) 2018-2026 (5918-5926 in Lukashian years)
 * All rights reserved.
 * (License header abbreviated.)
 */

import 'dart:io';
import 'dart:typed_data';

import '../external_resource_millisecond_store_data_provider.dart';

/// Loads epoch data from HTTP(S) URLs. Base URL should end with a path separator;
/// extensions are appended as-is.
class HttpMillisecondStoreDataProvider
    extends ExternalResourceMillisecondStoreDataProvider {
  HttpMillisecondStoreDataProvider(
    super.baseLocation,
    super.unixEpochOffsetExtension,
    super.yearEpochMillisecondsExtension,
    super.dayEpochMillisecondsExtension,
  );

  // note: cannot use super.baseLocation - would mix super parameter with positional super call.
  // ignore: use_super_parameters
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
