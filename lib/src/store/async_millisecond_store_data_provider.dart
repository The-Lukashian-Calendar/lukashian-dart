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

/// Async counterpart of [MillisecondStoreDataProvider] for providers that
/// load data over HTTP, files, or other asynchronous I/O.
///
/// Use [MillisecondStore.loadAsyncProvider] to load data into the store; the
/// provider is not retained after loading.
///
/// See [MillisecondStoreDataProvider] for data semantics.
abstract interface class AsyncMillisecondStoreDataProvider {
  /// Loads the offset in milliseconds between the Lukashian epoch and the UNIX
  /// epoch (see [MillisecondStoreDataProvider]).
  Future<int> loadUnixEpochOffsetMilliseconds();

  /// Loads cumulative epoch milliseconds at the end of each year (index 0 =
  /// year 1).
  Future<List<int>> loadYearEpochMilliseconds();

  /// Loads cumulative epoch milliseconds at the end of each epoch day (index 0 =
  /// day 1).
  ///
  /// [yearEpochMilliseconds] is the result of [loadYearEpochMilliseconds].
  Future<List<int>> loadDayEpochMilliseconds(List<int> yearEpochMilliseconds);
}
