import 'package:equatable/equatable.dart';

class TradingInstrument extends Equatable {
  final String symbol;
  final String description;
  final String displaySymbol;
  final double currentPrice;
  final double? previousPrice;
  final double? previousClosePrice;
  final DateTime lastUpdated;

  TradingInstrument({
    required this.symbol,
    required this.description,
    required this.displaySymbol,
    this.currentPrice = 0.0,
    this.previousPrice,
    this.previousClosePrice,
    DateTime? lastUpdated,
  }) : lastUpdated = lastUpdated ?? DateTime.now();

  factory TradingInstrument.fromJson(Map<String, dynamic> json) {
    final symbol = json['symbol'] as String? ?? '';
    final description = json['description'] as String? ?? '';
    final displaySymbol = json['displaySymbol'] as String? ?? '';

    double initialPrice = 0.0;
    if (json.containsKey('price') && json['price'] != null) {
      final priceValue = json['price'];
      initialPrice = (priceValue is num) ? priceValue.toDouble() : 0.0;
    }

    double? previousClose;
    if (json.containsKey('previousClose') && json['previousClose'] != null) {
      final prevCloseValue = json['previousClose'];
      previousClose = (prevCloseValue is num) ? prevCloseValue.toDouble() : null;
    }

    return TradingInstrument(
      symbol: symbol,
      description: description,
      displaySymbol: displaySymbol,
      currentPrice: initialPrice,
      previousClosePrice: previousClose,
    );
  }

  int getPriceChange() {
    if (previousClosePrice != null && previousClosePrice! > 0) {
      if (currentPrice > previousClosePrice!) return 1;
      if (currentPrice < previousClosePrice!) return -1;
      return 0;
    }

    if (previousPrice != null && previousPrice! > 0) {
      if (currentPrice > previousPrice!) return 1;
      if (currentPrice < previousPrice!) return -1;
      return 0;
    }

    return 0;
  }

  TradingInstrument copyWithUpdatedPrice(double newPrice, {double? previousClose}) {
    if (newPrice == currentPrice) {
      return this;
    }

    return TradingInstrument(
      symbol: symbol,
      description: description,
      displaySymbol: displaySymbol,
      currentPrice: newPrice,
      previousPrice: currentPrice,
      previousClosePrice: previousClose ?? previousClosePrice,
      lastUpdated: DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [
    symbol,
    description,
    displaySymbol,
    currentPrice,
    previousPrice,
    previousClosePrice,
    lastUpdated
  ];

  @override
  String toString() => 'TradingInstrument($symbol, $displaySymbol, price: $currentPrice, prevClose: $previousClosePrice)';
}
