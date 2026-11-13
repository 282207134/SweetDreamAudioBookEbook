import 'package:flutter_test/flutter_test.dart';
import 'package:sweet_dream/data/books.dart';

void main() {
  test('filters combine age, duration, language and price', () {
    final filter = BookFilter()
      ..reset()
      ..active = true
      ..price = 'Free';
    expect(books.where(filter.matches).map((b) => b.id), ['coco', 'ferdinand']);
    filter.maxDuration = 60;
    expect(books.where(filter.matches).map((b) => b.id), ['ferdinand']);
    filter.age = 10;
    expect(books.where(filter.matches), isEmpty);
    filter.reset();
    filter
      ..active = true
      ..language = 'RUS';
    expect(books.where(filter.matches), isEmpty);
  });
  test('paid price bounds apply and reset restores the catalog', () {
    final filter = BookFilter()
      ..reset()
      ..active = true
      ..price = 'Paid'
      ..minPrice = 4;
    expect(books.where(filter.matches), isEmpty);
    filter.minPrice = 2;
    expect(books.where(filter.matches).length, 3);
    filter.reset();
    expect(books.where(filter.matches).length, books.length);
  });
}
