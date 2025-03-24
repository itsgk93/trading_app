import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

import '../../../utils/connection_status.dart';

@immutable
abstract class TradingInstrumentsEvent extends Equatable {
  const TradingInstrumentsEvent();

  @override
  List<Object?> get props => [];
}

class LoadInstruments extends TradingInstrumentsEvent {
  const LoadInstruments();
}

class SearchInstruments extends TradingInstrumentsEvent {
  final String query;

  const SearchInstruments({required this.query});

  @override
  List<Object?> get props => [query];
}

class PriceUpdated extends TradingInstrumentsEvent {
  final String symbol;
  final double price;

  const PriceUpdated({
    required this.symbol,
    required this.price,
  });

  @override
  List<Object?> get props => [symbol, price];
}

class ConnectionStatusChanged extends TradingInstrumentsEvent {
  final ConnectionStatus status;

  const ConnectionStatusChanged({required this.status});

  @override
  List<Object?> get props => [status];
}

class RetryLoadInstruments extends TradingInstrumentsEvent {
  const RetryLoadInstruments();
}
