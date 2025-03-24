import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:trading_app/models/trading_instrument.dart';
import 'package:trading_app/repositories/trading_instruments_repository.dart';
import 'package:trading_app/services/finnhub_service.dart';

class MockFinnhubService extends Mock implements FinnhubService {}

void main() {
  late TradingInstrumentsRepository repository;
  late MockFinnhubService mockService;

  setUp(() {
    mockService = MockFinnhubService();
    repository = TradingInstrumentsRepository(service: mockService);
  });

  group('TradingInstrumentsRepository', () {
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

    test('fetchInstruments delegates to the service', () async {
      when(() => mockService.fetchInstruments())
          .thenAnswer((_) async => mockInstruments);

      final result = await repository.fetchInstruments();

      expect(result, equals(mockInstruments));
      verify(() => mockService.fetchInstruments()).called(1);
    });

    test('fetchInstruments throws when service throws', () async {
      when(() => mockService.fetchInstruments())
          .thenThrow(Exception('Failed to fetch instruments'));

      expect(
        () => repository.fetchInstruments(),
        throwsA(isA<Exception>()),
      );
    });

    test('connectToTickerStream delegates to the service', () {
      const mockStream = Stream<Map<String, dynamic>>.empty();
      when(() => mockService.connectToTickerStream())
          .thenAnswer((_) => mockStream);

      final result = repository.connectToTickerStream();

      expect(result, equals(mockStream));
      verify(() => mockService.connectToTickerStream()).called(1);
    });

    test('subscribeToSymbol delegates to the service', () {
      const symbol = 'AAPL';
      when(() => mockService.subscribeToSymbol(any())).thenReturn(null);

      repository.subscribeToSymbol(symbol);

      verify(() => mockService.subscribeToSymbol(symbol)).called(1);
    });

    test('unsubscribeFromSymbol delegates to the service', () {
      const symbol = 'AAPL';
      when(() => mockService.unsubscribeFromSymbol(any())).thenReturn(null);

      repository.unsubscribeFromSymbol(symbol);

      verify(() => mockService.unsubscribeFromSymbol(symbol)).called(1);
    });

    test('getInstrumentBySymbol returns correct instrument', () async {
      when(() => mockService.fetchInstruments())
          .thenAnswer((_) async => mockInstruments);

      final result = await repository.getInstrumentBySymbol('AAPL');

      expect(result, equals(mockInstruments[0]));
      verify(() => mockService.fetchInstruments()).called(1);
    });

    test('dispose calls service dispose', () {
      when(() => mockService.dispose()).thenReturn(null);

      repository.dispose();

      verify(() => mockService.dispose()).called(1);
    });
  });
}
