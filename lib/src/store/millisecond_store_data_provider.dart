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

/// For each [Day] and [Year], an implementation provides the number of
/// milliseconds between the start of the calendar (the Lukashian epoch) and the
/// end of that day or year ('epoch milliseconds'). It also stores the offset
/// between the Lukashian epoch and the UNIX epoch. Using these numbers, the
/// actual years and days of the Lukashian Calendar are defined.
///
/// An implementation must provide:
///
/// - The number of epoch milliseconds for each year in an array where the index
///   + 1 is the year and the value is the number of epoch milliseconds for that
///   year — how many milliseconds have passed from the beginning of the
///   calendar up until the final point of that year.
/// - The number of epoch milliseconds for each day in an array where the
///   index + 1 is the epoch day and the value is the number of epoch
///   milliseconds for that day — how many milliseconds have passed from the
///   beginning of the calendar up until the final point of that day (epoch
///   days; it does not take into account the year each day is in).
/// - The offset in milliseconds between the Lukashian epoch and the UNIX
///   epoch such that
///   `unixEpochOffsetMilliseconds + millisecondsSinceUnixEpoch =
///   millisecondsSinceLukashianEpoch`. When the UNIX epoch is after the
///   Lukashian epoch, this must be positive. It is measured around the point
///   of the UNIX epoch, before any UNIX leap seconds were added.
///
/// This allows for various instances of the Lukashian Calendar Mechanism. See
/// [CalendarKeys] for the instances available by default.
///
/// The Lukashian Calendar Mechanism assumes that each year and each day is at
/// least 3 milliseconds long (a first millisecond, a last one, and at least one
/// in between). Shorter spans are not guaranteed.
///
/// Following that constraint, each year is assumed to be at least 3 days long.
///
/// Implementations do not need to provide caching: in this Dart port each
/// load method is async; [MillisecondStore.ensureLoaded] loads once and
/// [MillisecondStore] caches the result in [MillisecondStoreData].
abstract interface class MillisecondStoreDataProvider {
  /// Loads the offset in milliseconds between the Lukashian epoch and the UNIX
  /// epoch (see interface documentation).
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
