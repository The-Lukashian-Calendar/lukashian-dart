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
class HttpMillisecondStoreDataProvider extends ExternalResourceMillisecondStoreDataProvider {
  HttpMillisecondStoreDataProvider(
    String baseUrl,
    String unixEpochOffsetUrlExtension,
    String yearEpochMillisecondsUrlExtension,
    String dayEpochMillisecondsUrlExtension,
  ) : super(
          baseUrl,
          unixEpochOffsetUrlExtension,
          yearEpochMillisecondsUrlExtension,
          dayEpochMillisecondsUrlExtension,
        );

  HttpMillisecondStoreDataProvider.withDefaults(String baseUrl)
      : super.withDefaults(baseUrl);

  @override
  Future<List<int>> loadMillisecondsByteArray(String url) async {
    final client = HttpClient();
    try {
      final request = await client.getUrl(Uri.parse(url));
      request.headers.set('Accept', 'application/octet-stream');
      final response = await request.close();
      if (response.statusCode != 200) {
        throw HttpException(
          'Expected response code 200, instead received response code ${response.statusCode}',
        );
      }
      final builder = BytesBuilder();
      await for (final chunk in response) {
        builder.add(chunk);
      }
      return builder.toBytes();
    } finally {
      client.close();
    }
  }
}
