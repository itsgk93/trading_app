import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/trading_instrument.dart';

class InstrumentListItemWidget extends StatefulWidget {
  final TradingInstrument instrument;

  const InstrumentListItemWidget({
    Key? key,
    required this.instrument,
  }) : super(key: key);

  @override
  State<InstrumentListItemWidget> createState() => _InstrumentListItemWidgetState();
}

class _InstrumentListItemWidgetState extends State<InstrumentListItemWidget> {

  @override
  Widget build(BuildContext context) {
    double? changeValue;
    bool isPriceIncreasing = false;

    if (widget.instrument.previousPrice != null && widget.instrument.previousPrice! > 0) {
      changeValue = widget.instrument.currentPrice - widget.instrument.previousPrice!;
      isPriceIncreasing = changeValue > 0;
    }

    final changeColor = isPriceIncreasing ? Colors.green.shade700 : Colors.red.shade700;

    final priceFormatter = NumberFormat.currency(
      symbol: '',
      decimalDigits: 5,
    );

    final formattedPrice = priceFormatter.format(widget.instrument.currentPrice);

    String changeText = '';
    if (changeValue != null) {
      changeText = '${changeValue >= 0 ? '+' : ''}${changeValue.toStringAsFixed(5)}';
    }

    final timeFormatter = DateFormat('HH:mm:ss');
    final lastUpdated = timeFormatter.format(widget.instrument.lastUpdated);

    final cleanDescription = widget.instrument.description.replaceAll(' Forex Pair', '');

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 3,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.instrument.displaySymbol,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),

                Text(
                  formattedPrice,
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    cleanDescription,
                    style: Theme.of(context).textTheme.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                if (changeValue != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: changeColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isPriceIncreasing ? Icons.arrow_upward : Icons.arrow_downward,
                          color: Colors.white,
                          size: 12,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          changeText,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 4),

            Align(
              alignment: Alignment.bottomRight,
              child: Text(
                lastUpdated,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey.withOpacity(0.7),
                  fontSize: 10,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
