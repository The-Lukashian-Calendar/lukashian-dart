/*
 * Copyright (c) 2018-2026 (5918-5926 in Lukashian years)
 * All rights reserved.
 *
 * The Lukashian Calendar and The Lukashian Calendar Mechanism are registered
 * at the Benelux Office for Intellectual Property, registration number 120712.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 * 1. Redistributions of source code must retain the above copyright
 *    notice, the above registration notice, this list of conditions
 *    and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, the above registration notice, this list of conditions
 *    and the following disclaimer in the documentation and/or other materials
 *    provided with the distribution.
 * 3. All materials mentioning features or use of this software,
 *    the Lukashian Calendar or the underlying Lukashian Calendar Mechanism,
 *    with or without modification, must refer to the Calendar as "The
 *    Lukashian Calendar" and to the Calendar Mechanism as "The Lukashian
 *    Calendar Mechanism".
 * 4. Renaming of source code, binary form, the Lukashian Calendar or the
 *    Lukashian Calendar Mechanism, with or without modification, is explicitly
 *    disallowed.
 * 5. Any copies, extracts, code excerpts, forks, redistributions
 *    or translations into other languages of source code, binary form,
 *    the functional behaviour of the Lukashian Calendar as defined by source code or
 *    the functional behaviour of the Lukashian Calendar Mechanism as defined by source
 *    code, with or without modification, may not include modifications that
 *    change the functional behaviour of the Lukashian Calendar Mechanism as
 *    implemented by source code.
 *
 * THIS SOFTWARE IS PROVIDED BY COPYRIGHT HOLDER ''AS IS'' AND ANY
 * EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL COPYRIGHT HOLDER BE LIABLE FOR ANY
 * DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

import 'dart:async';

import '../lukashian_exception.dart';
import 'calendar_keys.dart';
import 'millisecond_store_data.dart';
import 'millisecond_store_data_provider.dart';

/// Singleton that manages Lukashian calendar instances (providers and cached data).
/// Call [ensureLoaded] before using [data] for a given key.
final class MillisecondStore {
  MillisecondStore._() : _defaultCalendarKey = CalendarKeys.earth;

  static final MillisecondStore _instance = MillisecondStore._();

  static MillisecondStore store() => _instance;

  int _defaultCalendarKey;
  final Map<int, MillisecondStoreDataProvider> _providers = {};
  final Map<int, MillisecondStoreData> _data = {};
  final Map<int, Future<void>> _loading = {};

  int getDefaultCalendarKey() => _defaultCalendarKey;
  void setDefaultCalendarKey(int key) {
    _defaultCalendarKey = key;
  }

  /// Registers a provider. Do not overwrite standard [CalendarKeys] values.
  /// Registering a provider under a key also clears any cached data for that key.
  void registerProvider(int key, MillisecondStoreDataProvider provider) {
    _providers[key] = provider;
    clearData(key);
    _loading.remove(key);
  }

  /// Loads data for [calendarKey] from its provider if not already cached.
  /// Deduplicates concurrent calls for the same key so only one load runs.
  /// Throws [LukashianException] if no provider is registered for [calendarKey].
  Future<void> ensureLoaded(int calendarKey) async {
    if (_data.containsKey(calendarKey)) return;
    final inFlight = _loading[calendarKey];
    if (inFlight != null) return inFlight;

    final future = () async {
      final provider = _providers[calendarKey];
      LukashianException.check(
        provider != null,
        () =>
            'Please register provider for key $calendarKey before calling this method with key $calendarKey',
      );
      final p = provider!;
      final unixOffset = await p.loadUnixEpochOffsetMilliseconds();
      final yearMs = await p.loadYearEpochMilliseconds();
      final dayMs = await p.loadDayEpochMilliseconds(yearMs);
      _data[calendarKey] = MillisecondStoreData(
        unixEpochOffsetMilliseconds: unixOffset,
        yearEpochMilliseconds: yearMs,
        dayEpochMilliseconds: dayMs,
      );
    }();

    _loading[calendarKey] = future;
    try {
      await future;
    } finally {
      unawaited(_loading.remove(calendarKey));
    }
  }

  /// Returns cached data for [calendarKey]. Call [ensureLoaded] first.
  /// Throws [LukashianException] if no provider is registered or data not yet loaded.
  MillisecondStoreData data(int calendarKey) {
    final provider = _providers[calendarKey];
    LukashianException.check(
      provider != null,
      () =>
          'Please register provider for key $calendarKey before calling this method with key $calendarKey',
    );
    final cached = _data[calendarKey];
    LukashianException.check(
      cached != null,
      () =>
          'Data for key $calendarKey not loaded. Call ensureLoaded($calendarKey) first.',
    );
    return cached!;
  }

  void clearData(int key) {
    _data.remove(key);
  }

  void clearAllData() {
    _data.clear();
    _loading.clear();
  }
}
