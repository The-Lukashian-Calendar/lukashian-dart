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

import 'package:lukashian/src/store/millisecond_store.dart';
import 'package:test/test.dart';

import '../helpers/lukashian_assert.dart';
import '../helpers/test_millisecond_store_data_provider.dart';

void main() {
  final store = MillisecondStore.store();

  setUp(() {
    store.clearAllData();
  });

  tearDown(() {
    store.clearAllData();
  });

  test('testDataLoading', () async {
    var counter = 0;
    final loadCounterProvider = _CountingTestProvider(() => counter++);

    store.registerProvider(testCalendarKey + 2, loadCounterProvider);

    assertLukashianException(() => store.data(testCalendarKey + 3));

    await store.ensureLoaded(testCalendarKey + 2);
    store.data(testCalendarKey + 2);
    expect(counter, 1);

    store.data(testCalendarKey + 2);
    expect(counter, 1);

    store.clearData(testCalendarKey + 2);
    await store.ensureLoaded(testCalendarKey + 2);
    store.data(testCalendarKey + 2);
    expect(counter, 2);

    store.clearAllData();
    await store.ensureLoaded(testCalendarKey + 2);
    store.data(testCalendarKey + 2);
    expect(counter, 3);
  });
}

class _CountingTestProvider extends TestMillisecondStoreDataProvider {
  _CountingTestProvider(this._onLoad);

  final void Function() _onLoad;

  @override
  Future<int> loadUnixEpochOffsetMilliseconds() async {
    _onLoad();
    return super.loadUnixEpochOffsetMilliseconds();
  }
}
