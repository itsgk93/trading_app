import 'package:flutter/material.dart';
import '../models/trading_instrument.dart';
import 'instrument_list_item.dart';

class InstrumentListWidget extends StatelessWidget {
  final List<TradingInstrument> instruments;

  const InstrumentListWidget({
    Key? key,
    required this.instruments,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (instruments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 48,
              color: Theme.of(context).disabledColor,
            ),
            const SizedBox(height: 16),
            Text(
              'No instruments found',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await Future.delayed(const Duration(milliseconds: 500));
      },
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(top: 8, bottom: 16),
        itemCount: instruments.length,
        separatorBuilder: (context, index) => const SizedBox(height: 2),
        itemBuilder: (context, index) {
          final instrument = instruments[index];
          return InstrumentListItemWidget(instrument: instrument);
        },
      ),
    );
  }
}
