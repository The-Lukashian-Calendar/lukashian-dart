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

import 'package:test/test.dart';

import 'package:lukashian/lukashian.dart';

void main() {
  final provider = _EarthLeapSecondTestProvider();
  final data = MillisecondStoreData.fromProvider(provider);

  test('getUnixEpochMilliseconds leap second edge cases', () {
    // At the lukashian earth epoch, no leap seconds were added yet
    _testDifferenceBetweenUnixAndLukashianTime(data, 0, 0);

    // At the UNIX epoch, no leap seconds were added yet
    _testDifferenceBetweenUnixAndLukashianTime(data, provider.loadUnixEpochOffsetMilliseconds(), 0);

    // At 78796800000 milliseconds after the UNIX epoch, the first leap second was added
    var lukashianEpochMillisecondsToTest = provider.loadUnixEpochOffsetMilliseconds() + 78796800000;
    _testDifferenceBetweenUnixAndLukashianTime(data, lukashianEpochMillisecondsToTest - 2, 0);
    _testDifferenceBetweenUnixAndLukashianTime(data, lukashianEpochMillisecondsToTest - 1, 0);
    _testDifferenceBetweenUnixAndLukashianTime(data, lukashianEpochMillisecondsToTest, -1000);
    _testDifferenceBetweenUnixAndLukashianTime(data, lukashianEpochMillisecondsToTest + 1, -1000);
    _testDifferenceBetweenUnixAndLukashianTime(data, lukashianEpochMillisecondsToTest + 2, -1000);

    // At 362793600000 milliseconds after the UNIX epoch, the 10th leap second was added
    lukashianEpochMillisecondsToTest = provider.loadUnixEpochOffsetMilliseconds() + 362793600000;
    _testDifferenceBetweenUnixAndLukashianTime(data, lukashianEpochMillisecondsToTest - 2, -9000);
    _testDifferenceBetweenUnixAndLukashianTime(data, lukashianEpochMillisecondsToTest - 1, -9000);
    _testDifferenceBetweenUnixAndLukashianTime(data, lukashianEpochMillisecondsToTest, -10000);
    _testDifferenceBetweenUnixAndLukashianTime(data, lukashianEpochMillisecondsToTest + 1, -10000);
    _testDifferenceBetweenUnixAndLukashianTime(data, lukashianEpochMillisecondsToTest + 2, -10000);

    // What we see here is that, whenever you increment the lukashian timestamp past the
    // point of a leap second addition, the unix timestamp will "jump back" by a second,
    // effectively doing the same second again, because that certain unix timestamp second
    // represents two seconds in reality.

    // As of right now, 27 leap seconds have been added since the UNIX epoch
    _testDifferenceBetweenUnixAndLukashianTime(
      data,
      provider.loadUnixEpochOffsetMilliseconds() + DateTime.now().millisecondsSinceEpoch,
      -27000,
    );
  });

  test('getLukashianEpochMilliseconds leap second edge cases', () {
    // At the lukashian earth epoch, no leap seconds were added yet
    _testDifferenceBetweenLukashianAndUnixTime(data, provider.loadUnixEpochOffsetMilliseconds() * -1, 0);

    // At the UNIX epoch, no leap seconds were added yet
    _testDifferenceBetweenLukashianAndUnixTime(data, 0, 0);

    // At 78796800000 milliseconds after the UNIX epoch, the first leap second was added
    var unixEpochMillisecondsToTest = 78796800000;
    _testDifferenceBetweenLukashianAndUnixTime(data, unixEpochMillisecondsToTest - 2, 0);
    _testDifferenceBetweenLukashianAndUnixTime(data, unixEpochMillisecondsToTest - 1, 0);
    _testDifferenceBetweenLukashianAndUnixTime(data, unixEpochMillisecondsToTest, 1000);
    _testDifferenceBetweenLukashianAndUnixTime(data, unixEpochMillisecondsToTest + 1, 1000);
    _testDifferenceBetweenLukashianAndUnixTime(data, unixEpochMillisecondsToTest + 2, 1000);

    // At 362793600000 milliseconds after the UNIX epoch, the 10th leap second was added
    unixEpochMillisecondsToTest = 362793600000;
    _testDifferenceBetweenLukashianAndUnixTime(data, unixEpochMillisecondsToTest - 1, 9000);
    _testDifferenceBetweenLukashianAndUnixTime(data, unixEpochMillisecondsToTest - 2, 9000);
    _testDifferenceBetweenLukashianAndUnixTime(data, unixEpochMillisecondsToTest, 10000);
    _testDifferenceBetweenLukashianAndUnixTime(data, unixEpochMillisecondsToTest + 1, 10000);
    _testDifferenceBetweenLukashianAndUnixTime(data, unixEpochMillisecondsToTest + 2, 10000);

    // What we see here is that, whenever you increment the unix timestamp past the point
    // of a leap second addition, the lukashian timestamp will "jump ahead" by a second,
    // because that certain unix timestamp second represents two seconds in reality.

    // As of right now, 27 leap seconds have been added since the UNIX epoch
    _testDifferenceBetweenLukashianAndUnixTime(data, DateTime.now().millisecondsSinceEpoch, 27000);
  });
}

void _testDifferenceBetweenUnixAndLukashianTime(
  MillisecondStoreData data,
  int lukashianEpochMillisecondsToTest,
  int expectedDifference,
) {
  final unixEpochMillisecondsAtLukashianEpoch = data.getUnixEpochMilliseconds(0);
  final unixEpochMillisecondsAtTimeToTest = data.getUnixEpochMilliseconds(lukashianEpochMillisecondsToTest);
  final elapsedUnixMilliseconds = unixEpochMillisecondsAtTimeToTest - unixEpochMillisecondsAtLukashianEpoch;
  final difference = elapsedUnixMilliseconds - lukashianEpochMillisecondsToTest;
  expect(difference, expectedDifference);
}

void _testDifferenceBetweenLukashianAndUnixTime(
  MillisecondStoreData data,
  int unixEpochMillisecondsToTest,
  int expectedDifference,
) {
  final lukashianEpochMillisecondsAtUnixEpoch = data.getLukashianEpochMilliseconds(0);
  final lukashianEpochMillisecondsAtTimeToTest = data.getLukashianEpochMilliseconds(unixEpochMillisecondsToTest);
  final elapsedLukashianMilliseconds = lukashianEpochMillisecondsAtTimeToTest - lukashianEpochMillisecondsAtUnixEpoch;
  final difference = elapsedLukashianMilliseconds - unixEpochMillisecondsToTest;
  expect(difference, expectedDifference);
}

/// Supplies the Standard Earth unix epoch offset for leap-second conversion tests.
///
/// Year and day arrays are unused by these tests; see
/// [StandardEarthMillisecondStoreDataProvider] in the Java reference implementation.
class _EarthLeapSecondTestProvider implements MillisecondStoreDataProvider {
  static const int _earthUnixEpochOffsetMilliseconds = 185208761225352;

  @override
  int loadUnixEpochOffsetMilliseconds() => _earthUnixEpochOffsetMilliseconds;

  @override
  List<int> loadYearEpochMilliseconds() => const [1];

  @override
  List<int> loadDayEpochMilliseconds(List<int> yearEpochMilliseconds) => const [1];
}
