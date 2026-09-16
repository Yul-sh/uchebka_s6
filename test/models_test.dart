import 'package:flutter_test/flutter_test.dart';
import 'package:fly_y/models/booking.dart';
import 'package:fly_y/models/lookups.dart';
import 'package:fly_y/models/tour.dart';

void main() {
  group('Разбор моделей', () {
    test('Tour.fromJson не падает при минимальном JSON', () {
      final tour = Tour.fromJson({'id': 1});
      expect(tour.id, 1);
      expect(tour.title, '');
      expect(tour.hotelIds, isEmpty);
      expect(tour.categoryIds, isEmpty);
    });

    test('Tour.fromJson читает вложенное направление', () {
      final tour = Tour.fromJson({
        'id': 2,
        'title': 'Тест',
        'destination': {'id': 5, 'name': 'Рим'},
        'hotels': [
          {'id': 3},
        ],
        'categories': [
          {'id': 1},
        ],
      });
      expect(tour.destinationId, 5);
      expect(tour.hotelIds, [3]);
      expect(tour.categoryIds, [1]);
    });

    test('Destination.fromJson терпит null-поля', () {
      final d = Destination.fromJson({'id': 9});
      expect(d.name, '');
      expect(d.country, '');
    });

    test('Booking форматирует дату и статус по-русски', () {
      final b = Booking(
        id: 1,
        tourId: 1,
        tourTitle: 'Тур',
        userId: 1,
        status: 'active',
        expiresAt: DateTime(2027, 9, 1),
      );
      expect(b.subtitleRu, contains('активно до'));
      expect(b.expiresFormatted, '01.09.2027');
      expect(b.statusRu, 'активно');
    });
  });
}
