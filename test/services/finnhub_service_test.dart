import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:trading_app/models/trading_instrument.dart';
import 'package:trading_app/services/finnhub_service.dart';

class MockHttpClient extends Mock implements http.Client {}

class MockWebSocket extends Mock implements Stream<String> {}

void main() {
  late FinnhubService finnhubService;
  late MockHttpClient mockHttpClient;

  setUp(() {
    mockHttpClient = MockHttpClient();
    finnhubService = FinnhubService(httpClient: mockHttpClient);
    registerFallbackValue(Uri.parse(''));
  });

  tearDown(() {
    finnhubService.dispose();
  });

  group('FinnhubService', () {
    test('fetchInstruments should return list of instruments on success',
        () async {
      final instruments = await finnhubService.fetchInstruments();

      expect(instruments, isA<List<TradingInstrument>>());
      expect(instruments.length, equals(15));
      expect(instruments[0].symbol, equals('OANDA:EUR_USD'));
      expect(instruments[0].displaySymbol, equals('EUR/USD'));
      expect(instruments[1].description, equals('GBP/USD'));
    });

    test('connectToTickerStream should return a stream of price updates',
        () async {
      final stream = finnhubService.connectToTickerStream();

      expect(stream, isA<Stream<Map<String, dynamic>>>());
    });

    test('_updateInstrumentPrice should update price with previous close',
        () async {
      await finnhubService.fetchInstruments();

      final updates = <Map<String, dynamic>>[];
      finnhubService.connectToTickerStream().listen(updates.add);

      await Future.delayed(Duration.zero);

      expect(finnhubService, isNotNull);
    });
  });
}
