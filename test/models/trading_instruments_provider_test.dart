import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:trading_app/models/trading_instrument.dart';
import 'package:trading_app/models/trading_instruments_provider.dart';
import 'package:trading_app/services/finnhub_service.dart';
import 'package:trading_app/utils/app_exceptions.dart';
import 'package:trading_app/utils/connection_status.dart';

class MockFinnhubService extends Mock implements FinnhubService {}

void main() {
  late TradingInstrumentsProvider provider;
  late MockFinnhubService mockService;

  setUp(() {
    mockService = MockFinnhubService();
    provider = TradingInstrumentsProvider(mockService);

    registerFallbackValue(Uri.parse(''));
  });

  group('TradingInstrumentsProvider', () {
    final mockInstruments = [
      TradingInstrument(
        symbol: 'AAPL',
        description: 'Apple Inc.',
        displaySymbol: 'AAPL',
        currentPrice: 150.0,
        previousClosePrice: 148.0,
      ),
      TradingInstrument(
        symbol: 'MSFT',
        description: 'Microsoft Corporation',
        displaySymbol: 'MSFT',
        currentPrice: 250.0,
        previousClosePrice: 252.0,
      ),
    ];

    test('initialize should fetch instruments and connect to ticker', () async {
      when(() => mockService.fetchInstruments())
          .thenAnswer((_) async => mockInstruments);

      final streamController = StreamController<Map<String, dynamic>>();
      when(() => mockService.connectToTickerStream())
          .thenAnswer((_) => streamController.stream);

      await provider.initialize();

      expect(provider.instruments, equals(mockInstruments));
      expect(provider.isLoading, isFalse);
      expect(provider.errorMessage, isEmpty);
      expect(provider.connectionStatus, equals(ConnectionStatus.connected));

      verify(() => mockService.fetchInstruments()).called(1);
      verify(() => mockService.connectToTickerStream()).called(1);

      streamController.close();
    });

    test('initialize should handle errors', () async {
      when(() => mockService.fetchInstruments())
          .thenThrow(ApiException(statusCode: 500, message: 'Server error'));

      await provider.initialize();

      expect(provider.isLoading, isFalse);
      expect(provider.errorMessage, contains('API Error'));

      verify(() => mockService.fetchInstruments()).called(1);
      verifyNever(() => mockService.connectToTickerStream());
    });

    test('searchInstruments should filter instruments correctly', () async {
      when(() => mockService.fetchInstruments())
          .thenAnswer((_) async => mockInstruments);

      final streamController = StreamController<Map<String, dynamic>>();
      when(() => mockService.connectToTickerStream())
          .thenAnswer((_) => streamController.stream);

      await provider.initialize();

      provider.searchInstruments('');
      expect(provider.instruments.length, equals(2));

      provider.searchInstruments('AAPL');
      expect(provider.instruments.length, equals(1));
      expect(provider.instruments[0].symbol, equals('AAPL'));

      provider.searchInstruments('microsoft');
      expect(provider.instruments.length, equals(1));
      expect(provider.instruments[0].symbol, equals('MSFT'));

      provider.searchInstruments('XYZ');
      expect(provider.instruments.length, equals(0));

      streamController.close();
    });

    test('ticker stream should update prices with previous close', () async {
      when(() => mockService.fetchInstruments())
          .thenAnswer((_) async => mockInstruments);

      final streamController = StreamController<Map<String, dynamic>>();
      when(() => mockService.connectToTickerStream())
          .thenAnswer((_) => streamController.stream);

      await provider.initialize();

      expect(provider.instruments[0].currentPrice, equals(150.0));
      expect(provider.instruments[0].previousClosePrice, equals(148.0));

      streamController.add({
        'symbol': 'AAPL',
        'price': 155.0,
        'previousClose': 148.0,
      });

      await Future.delayed(Duration.zero);

      expect(provider.instruments[0].currentPrice, equals(155.0));
      expect(provider.instruments[0].previousClosePrice, equals(148.0));

      streamController.close();
    });

    test('retry should reinitialize the provider', () async {
      when(() => mockService.fetchInstruments())
          .thenThrow(ApiException(statusCode: 500, message: 'Server error'));

      when(() => mockService.fetchInstruments())
          .thenAnswer((_) async => mockInstruments);

      await provider.initialize();
      expect(provider.errorMessage, contains('API Error'));

      final streamController = StreamController<Map<String, dynamic>>();
      when(() => mockService.connectToTickerStream())
          .thenAnswer((_) => streamController.stream);

      await provider.retry();

      expect(provider.instruments, equals(mockInstruments));
      expect(provider.isLoading, isFalse);
      expect(provider.errorMessage, isEmpty);

      streamController.close();
    });

    test('dispose should clean up resources', () async {
      when(() => mockService.dispose()).thenReturn(null);

      provider.dispose();

      verify(() => mockService.dispose()).called(1);
    });
  });
}
