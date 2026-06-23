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
 * THIS SOFTWARE IS PROVIDED BY COPYRIGHT HOLDER "AS IS" AND ANY
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

import 'package:lukashian/lukashian.dart';

/// Singleton that manages the various instances of the Lukashian Calendar.
///
/// The int constants in [CalendarKeys] represent the instances supported by
/// default. Load additional calendars with [loadProvider] or
/// [loadAsyncProvider].
///
/// The default calendar instance is used when [Year], [Day] and [Instant]
/// methods do not specify a calendar key. By default the default is
/// [CalendarKeys.earthHttpLukashianOrg] until computed providers are ported
/// ([#33](https://github.com/The-Lukashian-Calendar/lukashian-dart/issues/33)); then it will
/// match Java as [CalendarKeys.earth]. You can change it with
/// [setDefaultCalendarKey].
///
/// Before using HTTP-backed calendars, call [init] once at application startup.
/// Calendar data is loaded eagerly and cached in [MillisecondStoreData];
/// providers are not retained after loading.
///
/// In the Java API, `MillisecondStore.data(int)` and
/// `MillisecondStore.defaultCalendarKey()` are static shortcuts on the
/// singleton; in Dart use [store] and then instance methods.
///
/// See also [MillisecondStoreData], [MillisecondStoreDataProvider],
/// [AsyncMillisecondStoreDataProvider].
final class MillisecondStore {
  MillisecondStore._() : _defaultCalendarKey = CalendarKeys.earthHttpLukashianOrg {
    // Deferred until #33 (computation provider port):
    // loadProvider(CalendarKeys.earth, StandardEarthMillisecondStoreDataProvider());
    // loadProvider(CalendarKeys.mars, StandardMarsMillisecondStoreDataProvider());
  }

  static final MillisecondStore _instance = MillisecondStore._();

  /// The singleton [MillisecondStore].
  static MillisecondStore store() => _instance;

  int _defaultCalendarKey;
  final Map<int, MillisecondStoreData> _data = {};
  Future<void>? _initFuture;
  final Map<int, Future<void>> _asyncLoading = {};
  final Map<int, int> _asyncLoadGeneration = {};

  /// Bumps the async-load generation for [key] and returns the new value.
  int _bumpAsyncLoadGeneration(int key) {
    final next = (_asyncLoadGeneration[key] ?? 0) + 1;
    _asyncLoadGeneration[key] = next;
    return next;
  }

  /// Invalidates in-flight async loads for [key].
  void _invalidateAsyncLoad(int key) {
    _bumpAsyncLoadGeneration(key);
    _asyncLoading.remove(key);
  }

  /// The default calendar key when no explicit key is provided.
  int getDefaultCalendarKey() => _defaultCalendarKey;

  /// Sets the default calendar key when no explicit key is provided.
  void setDefaultCalendarKey(int key) {
    _defaultCalendarKey = key;
  }

  /// Loads calendar data synchronously from [provider] under [key].
  ///
  /// The provider is not retained after loading. Calling again replaces the
  /// cached [MillisecondStoreData] for [key].
  void loadProvider(int key, MillisecondStoreDataProvider provider) {
    _invalidateAsyncLoad(key);
    _data[key] = MillisecondStoreData.fromProvider(provider);
  }

  /// Loads calendar data asynchronously from [provider] under [key].
  ///
  /// The provider is not retained after loading. Concurrent calls for the same
  /// [key] share one in-flight load. Calling again after completion replaces
  /// the cached [MillisecondStoreData] for [key].
  Future<void> loadAsyncProvider(int key, AsyncMillisecondStoreDataProvider provider) async {
    if (_data.containsKey(key)) {
      final generation = _bumpAsyncLoadGeneration(key);
      final data = await MillisecondStoreData.fromAsyncProvider(provider);
      if (_asyncLoadGeneration[key] == generation) {
        _data[key] = data;
      }
      return;
    }

    final inFlight = _asyncLoading[key];
    if (inFlight != null) {
      await inFlight;
      if (_data.containsKey(key)) {
        return;
      }
    }

    final generation = _bumpAsyncLoadGeneration(key);
    final future = () async {
      final data = await MillisecondStoreData.fromAsyncProvider(provider);
      if (_asyncLoadGeneration[key] == generation) {
        _data[key] = data;
      }
    }();

    _asyncLoading[key] = future;
    try {
      await future;
    } finally {
      if (identical(_asyncLoading[key], future)) {
        await _asyncLoading.remove(key);
      }
    }
  }

  /// Eagerly loads the default HTTP calendar data from lukashian.org.
  ///
  /// Loads [CalendarKeys.earthHttpLukashianOrg] and
  /// [CalendarKeys.marsHttpLukashianOrg]. Concurrent calls share one
  /// in-flight load. Safe to call multiple times.
  Future<void> init() {
    final existing = _initFuture;
    if (existing != null) {
      return existing;
    }
    final future = _initDefaults();
    _initFuture = future;
    return future;
  }

  Future<void> _initDefaults() async {
    await loadAsyncProvider(CalendarKeys.earthHttpLukashianOrg, StandardEarthHttpMillisecondStoreDataProvider());
    await loadAsyncProvider(CalendarKeys.marsHttpLukashianOrg, StandardMarsHttpMillisecondStoreDataProvider());
  }

  /// Returns cached [MillisecondStoreData] for [calendarKey].
  ///
  /// Throws [LukashianException] if data has not been loaded yet. Call [init]
  /// or [loadProvider] / [loadAsyncProvider] before use.
  MillisecondStoreData data(int calendarKey) {
    final cached = _data[calendarKey];
    LukashianException.check(
      cached != null,
      () =>
          'Data for key $calendarKey not loaded. Call init(), loadProvider($calendarKey, ...) or loadAsyncProvider($calendarKey, ...) first.',
    );
    return cached!;
  }

  /// Clears cached data for [key].
  ///
  /// Reload by calling [loadProvider] or [loadAsyncProvider] again.
  void clearData(int key) {
    _invalidateAsyncLoad(key);
    _data.remove(key);
    if (key == CalendarKeys.earthHttpLukashianOrg || key == CalendarKeys.marsHttpLukashianOrg) {
      _initFuture = null;
    }
  }

  /// Clears all cached [MillisecondStoreData].
  void clearAllData() {
    for (final key in {..._asyncLoadGeneration.keys, ..._asyncLoading.keys}) {
      _bumpAsyncLoadGeneration(key);
    }
    _data.clear();
    _initFuture = null;
    _asyncLoading.clear();
  }
}
