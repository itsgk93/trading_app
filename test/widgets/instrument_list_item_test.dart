import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:trading_app/models/trading_instrument.dart';
import 'package:trading_app/widgets/instrument_list_item.dart';

void main() {
  group('InstrumentListItemWidget', () {
    final testDateTime = DateTime(2023, 1, 1, 10, 30, 15);
    final timeFormatter = DateFormat('HH:mm:ss');
    final formattedTime = timeFormatter.format(testDateTime);

    testWidgets('renders correctly with current price only (no previous price)',
        (WidgetTester tester) async {
      final instrument = TradingInstrument(
        symbol: 'OANDA:EUR_USD',
        displaySymbol: 'EUR/USD',
        description: 'Euro vs US Dollar',
        currentPrice: 1.10000,
        previousClosePrice: 1.09500,
        lastUpdated: testDateTime,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: InstrumentListItemWidget(instrument: instrument),
          ),
        ),
      );

      expect(find.text('EUR/USD'), findsOneWidget);
      expect(find.text('Euro vs US Dollar'), findsOneWidget);
      expect(find.text('1.10000'), findsOneWidget);
      expect(find.text(formattedTime), findsOneWidget);

      expect(find.byIcon(Icons.arrow_upward), findsNothing);
      expect(find.byIcon(Icons.arrow_downward), findsNothing);
    });

    testWidgets('renders correctly with price increase',
        (WidgetTester tester) async {
      final instrument = TradingInstrument(
        symbol: 'OANDA:EUR_USD',
        displaySymbol: 'EUR/USD',
        description: 'Euro vs US Dollar',
        currentPrice: 1.10500,
        previousPrice: 1.10000,
        previousClosePrice: 1.09500,
        lastUpdated: testDateTime,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: InstrumentListItemWidget(instrument: instrument),
          ),
        ),
      );

      expect(find.text('EUR/USD'), findsOneWidget);
      expect(find.text('1.10500'), findsOneWidget);
      expect(find.text('+0.00500'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_upward), findsOneWidget);

      final container = tester.widget<Container>(find.byType(Container));
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, Colors.green.shade700);
    });

    testWidgets('renders correctly with price decrease',
        (WidgetTester tester) async {
      final instrument = TradingInstrument(
        symbol: 'OANDA:EUR_USD',
        displaySymbol: 'EUR/USD',
        description: 'Euro vs US Dollar',
        currentPrice: 1.09500,
        previousPrice: 1.10000,
        previousClosePrice: 1.09000,
        lastUpdated: testDateTime,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: InstrumentListItemWidget(instrument: instrument),
          ),
        ),
      );

      expect(find.text('EUR/USD'), findsOneWidget);
      expect(find.text('1.09500'), findsOneWidget);
      expect(find.text('-0.00500'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_downward), findsOneWidget);

      final container = tester.widget<Container>(find.byType(Container));
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, Colors.red.shade700);
    });

    testWidgets('cleans up description text correctly',
        (WidgetTester tester) async {
      final instrument = TradingInstrument(
        symbol: 'OANDA:EUR_USD',
        displaySymbol: 'EUR/USD',
        description: 'Euro vs US Dollar Forex Pair',
        currentPrice: 1.10000,
        previousPrice: 1.09800,
        previousClosePrice: 1.09500,
        lastUpdated: testDateTime,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: InstrumentListItemWidget(instrument: instrument),
          ),
        ),
      );

      expect(find.text('Euro vs US Dollar'), findsOneWidget);
      expect(find.text('Euro vs US Dollar Forex Pair'), findsNothing);
    });

    testWidgets('handles long description with ellipsis',
        (WidgetTester tester) async {
      final instrument = TradingInstrument(
        symbol: 'OANDA:EUR_USD',
        displaySymbol: 'EUR/USD',
        description:
            'A very long description that should be truncated with ellipsis when displayed in the UI because it exceeds the available space',
        currentPrice: 1.10000,
        previousPrice: 1.09900,
        previousClosePrice: 1.09500,
        lastUpdated: testDateTime,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: InstrumentListItemWidget(instrument: instrument),
          ),
        ),
      );

      final descriptionTextWidget = tester.widget<Text>(
        find
            .descendant(
              of: find.byType(InstrumentListItemWidget),
              matching: find.byWidgetPredicate((widget) =>
                  widget is Text &&
                  widget.style?.fontSize ==
                      Theme.of(tester.element(find.byType(MaterialApp)))
                          .textTheme
                          .bodySmall
                          ?.fontSize),
            )
            .first,
      );

      expect(descriptionTextWidget.maxLines, 1);
      expect(descriptionTextWidget.overflow, TextOverflow.ellipsis);
    });

    testWidgets('formats price correctly with 5 decimal places',
        (WidgetTester tester) async {
      final testCases = [
        {'price': 1.0, 'expected': '1.00000'},
        {'price': 1.1, 'expected': '1.10000'},
        {'price': 1.12345, 'expected': '1.12345'},
        {'price': 1.123456, 'expected': '1.12346'},
        {'price': 0.00001, 'expected': '0.00001'},
      ];

      for (final testCase in testCases) {
        final instrument = TradingInstrument(
          symbol: 'OANDA:EUR_USD',
          displaySymbol: 'EUR/USD',
          description: 'Euro vs US Dollar',
          currentPrice: testCase['price'] as double,
          previousClosePrice: 1.0,
          lastUpdated: testDateTime,
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: InstrumentListItemWidget(instrument: instrument),
            ),
          ),
        );

        expect(find.text(testCase['expected'] as String), findsOneWidget,
            reason:
                'Price ${testCase['price']} should be formatted as ${testCase['expected']}');

        await tester.pumpAndSettle();
      }
    });
  });
}
