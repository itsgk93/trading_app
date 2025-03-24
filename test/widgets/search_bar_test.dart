import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:trading_app/blocs/trading_instruments/events/trading_instruments_event.dart';
import 'package:trading_app/blocs/trading_instruments/trading_instruments_bloc.dart';
import 'package:trading_app/widgets/search_bar_widget.dart';

class MockTradingInstrumentsBloc extends Mock
    implements TradingInstrumentsBloc {}

class FakeTradingInstrumentsEvent extends Fake
    implements TradingInstrumentsEvent {}

void main() {
  group('SearchBarWidget', () {
    late MockTradingInstrumentsBloc mockBloc;

    setUpAll(() {
      registerFallbackValue(FakeTradingInstrumentsEvent());
    });

    setUp(() {
      mockBloc = MockTradingInstrumentsBloc();
    });

    Widget buildSubject() {
      return MaterialApp(
        home: Scaffold(
          body: BlocProvider<TradingInstrumentsBloc>.value(
            value: mockBloc,
            child: const SearchBarWidget(),
          ),
        ),
      );
    }

    testWidgets('renders correctly in initial state',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildSubject());

      expect(find.byType(Card), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
      expect(find.byIcon(Icons.search), findsOneWidget);
      expect(find.byIcon(Icons.clear), findsNothing);

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.decoration?.hintText, 'Search instruments...');
      expect(textField.decoration?.border, InputBorder.none);
    });

    testWidgets('applies correct styling to TextField',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildSubject());

      final textField = tester.widget<TextField>(find.byType(TextField));

      expect(textField.decoration?.border, InputBorder.none);
      expect(textField.textInputAction, TextInputAction.search);

      final textFieldContainer = find
          .ancestor(
            of: find.byType(TextField),
            matching: find.byType(Padding),
          )
          .first;

      final padding = tester.widget<Padding>(textFieldContainer).padding;
      expect(
          padding, const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0));
    });

    testWidgets('disposes controller and focus node',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildSubject());

      await tester.pumpWidget(Container());
    });
  });
}
