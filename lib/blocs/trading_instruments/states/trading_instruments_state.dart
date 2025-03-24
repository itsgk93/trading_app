import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

import '../../../models/trading_instrument.dart';
import '../../../utils/connection_status.dart';

@immutable
abstract class TradingInstrumentsState extends Equatable {
  const TradingInstrumentsState();

  @override
  List<Object?> get props => [];
}

class TradingInstrumentsInitial extends TradingInstrumentsState {
  const TradingInstrumentsInitial();
}

class TradingInstrumentsLoading extends TradingInstrumentsState {
  const TradingInstrumentsLoading();
}

class TradingInstrumentsLoaded extends TradingInstrumentsState {
  final List<TradingInstrument> instruments;
  final List<TradingInstrument> filteredInstruments;
  final ConnectionStatus connectionStatus;

  final String? updateTrigger;

  const TradingInstrumentsLoaded({
    required this.instruments,
    required this.filteredInstruments,
    this.connectionStatus = ConnectionStatus.disconnected,
    this.updateTrigger,
  });

  TradingInstrumentsLoaded copyWith({
    List<TradingInstrument>? instruments,
    List<TradingInstrument>? filteredInstruments,
    ConnectionStatus? connectionStatus,
    String? updateTrigger,
  }) {
    return TradingInstrumentsLoaded(
      instruments: instruments ?? this.instruments,
      filteredInstruments: filteredInstruments ?? this.filteredInstruments,
      connectionStatus: connectionStatus ?? this.connectionStatus,
      updateTrigger: updateTrigger,
    );
  }

  @override
  List<Object?> get props => [instruments, filteredInstruments, connectionStatus, updateTrigger];
}

class TradingInstrumentsError extends TradingInstrumentsState {
  final String message;

  const TradingInstrumentsError({required this.message});

  @override
  List<Object?> get props => [message];
}

class TradingInstrumentsConnectionChanged extends TradingInstrumentsState {
  final ConnectionStatus status;

  const TradingInstrumentsConnectionChanged({required this.status});

  @override
  List<Object?> get props => [status];
}
