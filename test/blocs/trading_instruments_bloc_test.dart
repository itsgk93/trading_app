import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:trading_app/blocs/trading_instruments/events/trading_instruments_event.dart';
import 'package:trading_app/blocs/trading_instruments/states/trading_instruments_state.dart';
import 'package:trading_app/blocs/trading_instruments/trading_instruments_bloc.dart';
import 'package:trading_app/models/trading_instrument.dart';
import 'package:trading_app/repositories/trading_instruments_repository.dart';
import 'package:trading_app/utils/app_exceptions.dart';
import 'package:trading_app/utils/connection_status.dart';

class MockTradingInstrumentsRepository extends Mock
    implements TradingInstrumentsRepository {}

void main() {
  late TradingInstrumentsBloc bloc;
  late MockTradingInstrumentsRepository repository;

  setUp(() {
    repository = MockTradingInstrumentsRepository();
    bloc = TradingInstrumentsBloc(repository: repository);
  });

  tearDown(() {
    bloc.close();
  });

  group('TradingInstrumentsBloc', () {
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

    test('initial state is TradingInstrumentsInitial', () {
      expect(bloc.state, const TradingInstrumentsInitial());
    });

    blocTest<TradingInstrumentsBloc, TradingInstrumentsState>(
      'emits [Loading, Error] when LoadInstruments fails',
      build: () {
        when(() => repository.fetchInstruments())
            .thenThrow(ApiException(statusCode: 500, message: 'Server error'));
        return bloc;
      },
      act: (bloc) => bloc.add(const LoadInstruments()),
      expect: () => [
        const TradingInstrumentsLoading(),
        predicate<TradingInstrumentsError>(
            (state) => state.message.contains('Server error')),
      ],
    );

    blocTest<TradingInstrumentsBloc, TradingInstrumentsState>(
      'emits correct state when SearchInstruments is added',
      build: () {
        when(() => repository.fetchInstruments())
            .thenAnswer((_) async => mockInstruments);

        final streamController = StreamController<Map<String, dynamic>>();
        when(() => repository.connectToTickerStream())
            .thenAnswer((_) => streamController.stream);

        return bloc;
      },
      seed: () => TradingInstrumentsLoaded(
        instruments: mockInstruments,
        filteredInstruments: mockInstruments,
      ),
      act: (bloc) => bloc.add(const SearchInstruments(query: 'APP')),
      expect: () => [
        TradingInstrumentsLoaded(
          instruments: mockInstruments,
          filteredInstruments: [mockInstruments[0]],
        ),
      ],
    );

    blocTest<TradingInstrumentsBloc, TradingInstrumentsState>(
      'emits updated state when PriceUpdated is added with new price',
      build: () => bloc,
      seed: () => TradingInstrumentsLoaded(
        instruments: mockInstruments,
        filteredInstruments: mockInstruments,
      ),
      act: (bloc) => bloc.add(const PriceUpdated(
        symbol: 'AAPL',
        price: 155.0,
      )),
      expect: () => [
        predicate<TradingInstrumentsLoaded>((state) {
          final updatedInstrument = state.instruments.firstWhere(
            (i) => i.symbol == 'AAPL',
            orElse: () => TradingInstrument(
              symbol: '',
              description: '',
              displaySymbol: '',
            ),
          );
          return updatedInstrument.currentPrice == 155.0 &&
              updatedInstrument.previousPrice == 150.0 &&
              updatedInstrument.previousClosePrice == 148.0;
        }),
      ],
    );

    blocTest<TradingInstrumentsBloc, TradingInstrumentsState>(
      'emits updated state when PriceUpdated is added without previous close price',
      build: () => bloc,
      seed: () => TradingInstrumentsLoaded(
        instruments: mockInstruments,
        filteredInstruments: mockInstruments,
      ),
      act: (bloc) => bloc.add(const PriceUpdated(
        symbol: 'AAPL',
        price: 155.0,
      )),
      expect: () => [
        predicate<TradingInstrumentsLoaded>((state) {
          final updatedInstrument = state.instruments.firstWhere(
            (i) => i.symbol == 'AAPL',
            orElse: () => TradingInstrument(
              symbol: '',
              description: '',
              displaySymbol: '',
            ),
          );
          return updatedInstrument.currentPrice == 155.0 &&
              updatedInstrument.previousPrice == 150.0 &&
              updatedInstrument.previousClosePrice == 148.0;
        }),
      ],
    );

    blocTest<TradingInstrumentsBloc, TradingInstrumentsState>(
      'does not emit updated state when PriceUpdated has an unknown symbol',
      build: () => bloc,
      seed: () => TradingInstrumentsLoaded(
        instruments: mockInstruments,
        filteredInstruments: mockInstruments,
      ),
      act: (bloc) => bloc.add(const PriceUpdated(
        symbol: 'UNKNOWN',
        price: 155.0,
      )),
      expect: () => [],
    );

    blocTest<TradingInstrumentsBloc, TradingInstrumentsState>(
      'emits ConnectionStatusChanged when connection status changes',
      build: () => bloc,
      act: (bloc) => bloc.add(
          const ConnectionStatusChanged(status: ConnectionStatus.connected)),
      expect: () => [
        const TradingInstrumentsConnectionChanged(
            status: ConnectionStatus.connected),
      ],
    );
  });
}
