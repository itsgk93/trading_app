import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:trading_app/blocs/trading_instruments/events/trading_instruments_event.dart';
import 'package:trading_app/blocs/trading_instruments/states/trading_instruments_state.dart';
import 'package:trading_app/blocs/trading_instruments/trading_instruments_bloc.dart';
import 'package:trading_app/models/trading_instrument.dart';
import 'package:trading_app/screens/splash_screen.dart';
import 'package:trading_app/utils/connection_status.dart';

class MockTradingInstrumentsBloc extends Mock
    implements TradingInstrumentsBloc {}

class MockNavigatorObserver extends Mock implements NavigatorObserver {}

void main() {
  late MockTradingInstrumentsBloc bloc;
  late MockNavigatorObserver navigatorObserver;
  late StreamController<TradingInstrumentsState> streamController;

  setUp(() {
    bloc = MockTradingInstrumentsBloc();
    navigatorObserver = MockNavigatorObserver();
    streamController = StreamController<TradingInstrumentsState>.broadcast();

    when(() => bloc.stream).thenAnswer((_) => streamController.stream);

    registerFallbackValue(
      MaterialPageRoute<void>(builder: (_) => Container()),
    );

    registerFallbackValue(const LoadInstruments());
  });

  tearDown(() {
    streamController.close();
  });

  Widget createSplashScreen() {
    return MaterialApp(
      home: BlocProvider<TradingInstrumentsBloc>.value(
        value: bloc,
        child: const SplashScreen(),
      ),
      navigatorObservers: [navigatorObserver],
    );
  }

  group('SplashScreen', () {
    final mockInstruments = [
      TradingInstrument(
        symbol: 'AAPL',
        description: 'Apple Inc.',
        displaySymbol: 'AAPL',
        currentPrice: 150.0,
      ),
      TradingInstrument(
        symbol: 'MSFT',
        description: 'Microsoft Corporation',
        displaySymbol: 'MSFT',
        currentPrice: 250.0,
      ),
    ];

    testWidgets('shows app name and loading indicator initially',
        (WidgetTester tester) async {
      when(() => bloc.state).thenReturn(const TradingInstrumentsInitial());

      await tester.pumpWidget(createSplashScreen());

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Loading trading instruments...'), findsOneWidget);

      verify(() => bloc.add(const LoadInstruments())).called(1);
    });

    testWidgets('shows connection status when instruments are loaded',
        (WidgetTester tester) async {
      when(() => bloc.state).thenReturn(
        TradingInstrumentsLoaded(
          instruments: mockInstruments,
          filteredInstruments: mockInstruments,
          connectionStatus: ConnectionStatus.connecting,
        ),
      );

      await tester.pumpWidget(createSplashScreen());

      expect(find.text('Connecting to price feed...'), findsOneWidget);
    });

    testWidgets('shows error view when loading fails',
        (WidgetTester tester) async {
      when(() => bloc.state).thenReturn(
        const TradingInstrumentsError(message: 'Failed to load data'),
      );

      await tester.pumpWidget(createSplashScreen());

      expect(find.text('Error: Failed to load data'), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });

    testWidgets('tapping retry triggers reload', (WidgetTester tester) async {
      when(() => bloc.state).thenReturn(
        const TradingInstrumentsError(message: 'Failed to load data'),
      );

      await tester.pumpWidget(createSplashScreen());
      await tester.tap(find.text('Retry'));

      verify(() => bloc.add(const RetryLoadInstruments())).called(1);
    });
  });
}
