import 'package:flutter_test/flutter_test.dart';
import 'package:trading_app/models/trading_instrument.dart';

void main() {
  group('TradingInstrument', () {
    test('should create a TradingInstrument from constructor', () {
      final instrument = TradingInstrument(
        symbol: 'AAPL',
        description: 'Apple Inc.',
        displaySymbol: 'AAPL',
        currentPrice: 150.0,
        previousClosePrice: 148.0,
      );

      expect(instrument.symbol, equals('AAPL'));
      expect(instrument.description, equals('Apple Inc.'));
      expect(instrument.displaySymbol, equals('AAPL'));
      expect(instrument.currentPrice, equals(150.0));
      expect(instrument.previousPrice, isNull);
      expect(instrument.previousClosePrice, equals(148.0));
      expect(instrument.lastUpdated, isNotNull);
    });

    test('should create a TradingInstrument from JSON', () {
      final json = {
        'symbol': 'AAPL',
        'description': 'Apple Inc.',
        'displaySymbol': 'AAPL',
        'previousClose': 148.0,
      };

      final instrument = TradingInstrument.fromJson(json);

      expect(instrument.symbol, equals('AAPL'));
      expect(instrument.description, equals('Apple Inc.'));
      expect(instrument.displaySymbol, equals('AAPL'));
      expect(instrument.currentPrice, equals(0.0));
      expect(instrument.previousPrice, isNull);
      expect(instrument.previousClosePrice, equals(148.0));
    });

    test('getPriceChange should prioritize previous close price', () {
      final instrument = TradingInstrument(
        symbol: 'AAPL',
        description: 'Apple Inc.',
        displaySymbol: 'AAPL',
        currentPrice: 150.0,
        previousPrice: 145.0,
        previousClosePrice: 148.0,
      );

      expect(instrument.getPriceChange(), equals(1));

      final updatedInstrument1 = instrument.copyWithUpdatedPrice(145.0);
      expect(updatedInstrument1.getPriceChange(), equals(-1));

      final updatedInstrument2 = updatedInstrument1.copyWithUpdatedPrice(148.0);
      expect(updatedInstrument2.getPriceChange(), equals(0));
    });

    test(
        'getPriceChange should fall back to previous price when previous close is null',
        () {
      final instrument = TradingInstrument(
        symbol: 'AAPL',
        description: 'Apple Inc.',
        displaySymbol: 'AAPL',
        currentPrice: 150.0,
        previousPrice: 145.0,
      );

      expect(instrument.getPriceChange(), equals(1));

      final updatedInstrument = instrument.copyWithUpdatedPrice(140.0);
      expect(updatedInstrument.getPriceChange(), equals(-1));
    });

    test(
        'getPriceChange should return 0 when no reference prices are available',
        () {
      final instrument = TradingInstrument(
        symbol: 'AAPL',
        description: 'Apple Inc.',
        displaySymbol: 'AAPL',
        currentPrice: 150.0,
      );

      expect(instrument.getPriceChange(), equals(0));
    });

    test('copyWithUpdatedPrice should update prices correctly', () {
      final instrument = TradingInstrument(
        symbol: 'AAPL',
        description: 'Apple Inc.',
        displaySymbol: 'AAPL',
        currentPrice: 150.0,
        previousClosePrice: 148.0,
      );

      expect(instrument.currentPrice, equals(150.0));
      expect(instrument.previousPrice, isNull);
      expect(instrument.previousClosePrice, equals(148.0));

      final updatedInstrument1 = instrument.copyWithUpdatedPrice(155.0);
      expect(updatedInstrument1.currentPrice, equals(155.0));
      expect(updatedInstrument1.previousPrice, equals(150.0));
      expect(updatedInstrument1.previousClosePrice, equals(148.0));

      final updatedInstrument2 = updatedInstrument1.copyWithUpdatedPrice(160.0);
      expect(updatedInstrument2.currentPrice, equals(160.0));
      expect(updatedInstrument2.previousPrice, equals(155.0));
      expect(updatedInstrument2.previousClosePrice, equals(148.0));
    });

    test('copyWithUpdatedPrice should update previousClosePrice when provided',
        () {
      final instrument = TradingInstrument(
        symbol: 'AAPL',
        description: 'Apple Inc.',
        displaySymbol: 'AAPL',
        currentPrice: 150.0,
        previousClosePrice: 148.0,
      );

      final updatedInstrument =
          instrument.copyWithUpdatedPrice(155.0, previousClose: 152.0);

      expect(updatedInstrument.currentPrice, equals(155.0));
      expect(updatedInstrument.previousPrice, equals(150.0));
      expect(updatedInstrument.previousClosePrice, equals(152.0));
    });

    test(
        'copyWithUpdatedPrice should not create a new instance if price is unchanged',
        () {
      final instrument = TradingInstrument(
        symbol: 'AAPL',
        description: 'Apple Inc.',
        displaySymbol: 'AAPL',
        currentPrice: 150.0,
      );

      final updatedInstrument = instrument.copyWithUpdatedPrice(150.0);

      expect(identical(instrument, updatedInstrument), isTrue);
    });

    test('props should include all relevant fields', () {
      final instrument = TradingInstrument(
        symbol: 'AAPL',
        description: 'Apple Inc.',
        displaySymbol: 'AAPL',
        currentPrice: 150.0,
        previousPrice: 145.0,
        previousClosePrice: 148.0,
      );

      expect(instrument.props, contains(instrument.symbol));
      expect(instrument.props, contains(instrument.description));
      expect(instrument.props, contains(instrument.displaySymbol));
      expect(instrument.props, contains(instrument.currentPrice));
      expect(instrument.props, contains(instrument.previousPrice));
      expect(instrument.props, contains(instrument.previousClosePrice));
      expect(instrument.props, contains(instrument.lastUpdated));
    });
  });
}
