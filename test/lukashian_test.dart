import 'package:lukashian/lukashian.dart';
import 'package:test/test.dart';

import 'helpers/test_millisecond_store_data_provider.dart';

void main() {
  group('Calendar API smoke test', () {
    test('Year/Day/Instant formatting is non-empty', () {
      final store = MillisecondStore.store();
      final previousDefaultKey = store.getDefaultCalendarKey();

      store.loadProvider(testCalendarKey, TestMillisecondStoreDataProvider());
      store.setDefaultCalendarKey(testCalendarKey);

      try {
        final year = Year.of(1, testCalendarKey);
        final day = year.atDay(1);
        final instant = day.atTimeBeeps(1234);

        expect(instant.getEpochMilliseconds(), 38);

        final formatted = Formatter.formatInstant(instant, dayFormat: DayFormat.dayFirst);
        expect(formatted, '1-1 1234');
      } finally {
        store.setDefaultCalendarKey(previousDefaultKey);
        store.clearData(testCalendarKey);
      }
    });
  });
}
