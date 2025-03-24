import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:trading_app/blocs/trading_instruments/events/trading_instruments_event.dart';
import 'package:trading_app/blocs/trading_instruments/states/trading_instruments_state.dart';
import 'package:trading_app/blocs/trading_instruments/trading_instruments_bloc.dart';
import 'package:trading_app/models/trading_instrument.dart';
import 'package:trading_app/screens/home_screen.dart';

class MockTradingInstrumentsBloc
    extends MockBloc<TradingInstrumentsEvent, TradingInstrumentsState>
    implements TradingInstrumentsBloc {}

void main() {
  late MockTradingInstrumentsBloc mockBloc;

  setUp(() {
    mockBloc = MockTradingInstrumentsBloc();
  });

  Widget createHomeScreen() {
    return MaterialApp(
      home: BlocProvider<TradingInstrumentsBloc>.value(
        value: mockBloc,
        child: const HomeScreen(),
      ),
    );
  }

  testWidgets('HomeScreen should display instruments when data is loaded',
      (WidgetTester tester) async {
    final mockInstruments = [
      TradingInstrument(
        symbol: 'OANDA:EUR_USD',
        displaySymbol: 'EUR/USD',
        description: 'Euro vs US Dollar',
        currentPrice: 1.10234,
        previousPrice: 1.09876,
      ),
    ];

    when(() => mockBloc.state).thenReturn(
      TradingInstrumentsLoaded(
        instruments: mockInstruments,
        filteredInstruments: mockInstruments,
      ),
    );

    await tester.pumpWidget(createHomeScreen());

    expect(find.text('Exinity App'), findsOneWidget);
    expect(find.text('EUR/USD'), findsOneWidget);
    expect(find.text('1.10234'), findsOneWidget);
    expect(find.text('Euro vs US Dollar'), findsOneWidget);

    final changeFinder = find.textContaining('+0.00358');
    expect(changeFinder, findsOneWidget);

    final priceFinder = find.text('1.10234');
    final priceWidget = tester.widget<Text>(priceFinder);
    expect(priceWidget.style?.color, equals(Colors.black));
  });

  testWidgets('HomeScreen should display correct colors and arrows for price changes',
      (WidgetTester tester) async {
    final mockInstrumentsWithDiff = [
      TradingInstrument(
        symbol: 'OANDA:EUR_USD',
        displaySymbol: 'EUR/USD',
        description: 'Euro vs US Dollar',
        currentPrice: 1.10234,
        previousPrice: 1.09876,
      ),
      TradingInstrument(
        symbol: 'OANDA:GBP_USD',
        displaySymbol: 'GBP/USD',
        description: 'British Pound vs US Dollar',
        currentPrice: 1.30456,
        previousPrice: 1.31234,
      ),
    ];

    when(() => mockBloc.state).thenReturn(
      TradingInstrumentsLoaded(
        instruments: mockInstrumentsWithDiff,
        filteredInstruments: mockInstrumentsWithDiff,
      ),
    );

    await tester.pumpWidget(createHomeScreen());
    await tester.pumpAndSettle();

    final firstPriceFinder = find.text('1.10234');
    final firstPriceWidget = tester.widget<Text>(firstPriceFinder);
    expect(firstPriceWidget.style?.color, equals(Colors.black));

    final secondPriceFinder = find.text('1.30456');
    final secondPriceWidget = tester.widget<Text>(secondPriceFinder);
    expect(secondPriceWidget.style?.color, equals(Colors.black));

    expect(find.textContaining('+0.00358'), findsOneWidget);
    expect(find.textContaining('-0.00778'), findsOneWidget);
    expect(find.byIcon(Icons.arrow_upward), findsOneWidget);
    expect(find.byIcon(Icons.arrow_downward), findsOneWidget);
  });
  
  testWidgets('HomeScreen should show loading indicator when loading',
      (WidgetTester tester) async {
    when(() => mockBloc.state).thenReturn(const TradingInstrumentsLoading());

    await tester.pumpWidget(createHomeScreen());

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
