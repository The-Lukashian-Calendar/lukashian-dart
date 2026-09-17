/*
 * Copyright (c) 2018-2026 (5918-5926 in Lukashian years)
 * All rights reserved.
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

import 'package:lukashian/src/store/async_millisecond_store_data_provider.dart';
import 'package:lukashian/src/store/millisecond_store_data_provider.dart';

/// Test calendar key for unit tests.
const int testCalendarKey = 100;

/// Deterministic Lukashian calendar for unit tests.
/// Years: 1..8 with boundaries at 1000, 2000, 3000, 4000, 4499, 4800, 5000, 40000 (epoch ms).
/// Days: 1..18 with boundaries at 300, 600, ..., 4799, 4900, 39000.
/// "Now" is at 1350 (via unix offset).
class TestMillisecondStoreDataProvider implements MillisecondStoreDataProvider {
  @override
  int loadUnixEpochOffsetMilliseconds() {
    return 1350 - DateTime.now().millisecondsSinceEpoch;
  }

  @override
  List<int> loadYearEpochMilliseconds() {
    return [1000, 2000, 3000, 4000, 4499, 4800, 5000, 40000];
  }

  @override
  List<int> loadDayEpochMilliseconds(List<int> yearEpochMilliseconds) {
    return [300, 600, 900, 1200, 1500, 1800, 2100, 2400, 2700, 3000, 3300, 3600, 3900, 4200, 4500, 4799, 4900, 39000];
  }
}

/// Async wrapper around [TestMillisecondStoreDataProvider] for async load tests.
class TestAsyncMillisecondStoreDataProvider implements AsyncMillisecondStoreDataProvider {
  TestAsyncMillisecondStoreDataProvider([MillisecondStoreDataProvider? delegate])
    : _delegate = delegate ?? TestMillisecondStoreDataProvider();

  final MillisecondStoreDataProvider _delegate;

  @override
  Future<int> loadUnixEpochOffsetMilliseconds() async {
    return _delegate.loadUnixEpochOffsetMilliseconds();
  }

  @override
  Future<List<int>> loadYearEpochMilliseconds() async {
    return _delegate.loadYearEpochMilliseconds();
  }

  @override
  Future<List<int>> loadDayEpochMilliseconds(List<int> yearEpochMilliseconds) async {
    return _delegate.loadDayEpochMilliseconds(yearEpochMilliseconds);
  }
}

/// Deterministic provider with fixed offset. Same year/day structure as
/// [TestMillisecondStoreDataProvider]. Used for [Instant.toCalendar] tests
/// where we need exactly-known offset differences.
class ConstantOffsetTestProvider implements MillisecondStoreDataProvider {
  ConstantOffsetTestProvider(this.offsetMilliseconds);

  final int offsetMilliseconds;

  static final List<int> _years = [1000, 2000, 3000, 4000, 4499, 4800, 5000, 40000];
  static final List<int> _days = [
    300,
    600,
    900,
    1200,
    1500,
    1800,
    2100,
    2400,
    2700,
    3000,
    3300,
    3600,
    3900,
    4200,
    4500,
    4799,
    4900,
    39000,
  ];

  @override
  int loadUnixEpochOffsetMilliseconds() => offsetMilliseconds;

  @override
  List<int> loadYearEpochMilliseconds() => _years;

  @override
  List<int> loadDayEpochMilliseconds(List<int> yearEpochMilliseconds) => _days;
}
