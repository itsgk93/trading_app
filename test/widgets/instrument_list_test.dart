import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trading_app/models/trading_instrument.dart';
import 'package:trading_app/widgets/instrument_list.dart';
import 'package:trading_app/widgets/instrument_list_item.dart';

void main() {
  group('InstrumentListWidget', () {
    List<TradingInstrument> createTestInstruments(int count) {
      return List.generate(count, (index) {
        return TradingInstrument(
          symbol: 'SYMBOL:$index',
          displaySymbol: 'Symbol $index',
          description: 'Description $index',
          currentPrice: 100.0 + index,
          previousPrice: 99.0 + index,
          previousClosePrice: 98.0 + index,
          lastUpdated: DateTime.now(),
        );
      });
    }

    testWidgets('renders list of instruments when not empty',
        (WidgetTester tester) async {
      final instruments = createTestInstruments(3);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: InstrumentListWidget(instruments: instruments),
          ),
        ),
      );

      expect(find.byType(InstrumentListItemWidget), findsNWidgets(3));
      expect(find.text('Symbol 0'), findsOneWidget);
      expect(find.text('Symbol 1'), findsOneWidget);
      expect(find.text('Symbol 2'), findsOneWidget);

      final listView = tester.widget<ListView>(find.byType(ListView));
      expect(listView.physics, isA<AlwaysScrollableScrollPhysics>());

      expect(find.byType(RefreshIndicator), findsOneWidget);
    });

    testWidgets('renders empty state when instruments list is empty',
        (WidgetTester tester) async {
      final instruments = <TradingInstrument>[];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: InstrumentListWidget(instruments: instruments),
          ),
        ),
      );

      expect(find.byType(InstrumentListItemWidget), findsNothing);
      expect(find.byType(ListView), findsNothing);

      expect(find.byIcon(Icons.search_off), findsOneWidget);
      expect(find.text('No instruments found'), findsOneWidget);

      final icon = tester.widget<Icon>(find.byIcon(Icons.search_off));
      expect(icon.size, 48);
    });

    testWidgets('separates list items with SizedBox',
        (WidgetTester tester) async {
      final instruments = createTestInstruments(2);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: InstrumentListWidget(instruments: instruments),
          ),
        ),
      );

      final sizedBoxes = tester.widgetList<SizedBox>(find.byType(SizedBox));

      expect(sizedBoxes.any((box) => box.height == 2), isTrue,
          reason: 'Should find a SizedBox with height 2 as separator');
    });

    testWidgets('refreshes list when pulled down', (WidgetTester tester) async {
      final instruments = createTestInstruments(5);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: InstrumentListWidget(instruments: instruments),
          ),
        ),
      );

      await tester.drag(find.byType(ListView), const Offset(0, 300));

      await tester.pump();

      expect(find.byType(RefreshProgressIndicator), findsOneWidget);

      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 100));

      await tester.pumpAndSettle();
    });

    testWidgets('has correct padding', (WidgetTester tester) async {
      final instruments = createTestInstruments(3);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: InstrumentListWidget(instruments: instruments),
          ),
        ),
      );

      final listView = tester.widget<ListView>(find.byType(ListView));
      final padding = listView.padding as EdgeInsets;

      expect(padding.top, 8);
      expect(padding.bottom, 16);
      expect(padding.left, 0);
      expect(padding.right, 0);
    });

    testWidgets('builds correct item for each instrument',
        (WidgetTester tester) async {
      final instruments = [
        TradingInstrument(
          symbol: 'OANDA:EUR_USD',
          displaySymbol: 'EUR/USD',
          description: 'Euro vs US Dollar',
          currentPrice: 1.10500,
          previousPrice: 1.10000,
          previousClosePrice: 1.09000,
          lastUpdated: DateTime.now(),
        ),
        TradingInstrument(
          symbol: 'OANDA:GBP_USD',
          displaySymbol: 'GBP/USD',
          description: 'British Pound vs US Dollar',
          currentPrice: 1.25500,
          previousPrice: 1.25700,
          previousClosePrice: 1.25000,
          lastUpdated: DateTime.now(),
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: InstrumentListWidget(instruments: instruments),
          ),
        ),
      );

      expect(find.text('EUR/USD'), findsOneWidget);
      expect(find.text('GBP/USD'), findsOneWidget);

      final listItems = tester
          .widgetList<InstrumentListItemWidget>(
              find.byType(InstrumentListItemWidget))
          .toList();

      expect(listItems[0].instrument.symbol, 'OANDA:EUR_USD');
      expect(listItems[1].instrument.symbol, 'OANDA:GBP_USD');
    });
  });
}
