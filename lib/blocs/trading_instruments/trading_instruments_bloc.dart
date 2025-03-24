import 'dart:async';
import 'package:bloc/bloc.dart';
import '../../models/trading_instrument.dart';
import '../../repositories/trading_instruments_repository.dart';
import '../../utils/app_exceptions.dart';
import '../../utils/connection_status.dart';
import 'events/trading_instruments_event.dart';
import 'states/trading_instruments_state.dart';

class TradingInstrumentsBloc extends Bloc<TradingInstrumentsEvent, TradingInstrumentsState> {
  final TradingInstrumentsRepository _repository;
  StreamSubscription? _tickerSubscription;
  TradingInstrumentsLoaded? _lastLoadedState;

  TradingInstrumentsBloc({
    required TradingInstrumentsRepository repository,
  })  : _repository = repository,
        super(const TradingInstrumentsInitial()) {
    on<LoadInstruments>(_onLoadInstruments);
    on<SearchInstruments>(_onSearchInstruments);
    on<PriceUpdated>(_onPriceUpdated);
    on<ConnectionStatusChanged>(_onConnectionStatusChanged);
    on<RetryLoadInstruments>(_onRetryLoadInstruments);
  }

  Future<void> _onLoadInstruments(
    LoadInstruments event,
    Emitter<TradingInstrumentsState> emit,
  ) async {
    emit(const TradingInstrumentsLoading());

    try {
      final instruments = await _repository.fetchInstruments();
      _connectToTickerStream();

      final loadedState = TradingInstrumentsLoaded(
        instruments: instruments,
        filteredInstruments: instruments,
      );
      _lastLoadedState = loadedState;
      emit(loadedState);
    } on ApiException catch (e) {
      emit(TradingInstrumentsError(message: 'API Error: ${e.message}'));
    } catch (e) {
      emit(TradingInstrumentsError(message: 'Error: ${e.toString()}'));
    }
  }

  void _onSearchInstruments(
    SearchInstruments event,
    Emitter<TradingInstrumentsState> emit,
  ) {
    if (state is TradingInstrumentsLoaded) {
      final currentState = state as TradingInstrumentsLoaded;
      final query = event.query.toLowerCase();

      if (query.isEmpty) {
        final updatedState = currentState.copyWith(
          filteredInstruments: currentState.instruments,
        );
        _lastLoadedState = updatedState;
        emit(updatedState);
      } else {
        final filteredInstruments = currentState.instruments
            .where((instrument) =>
                instrument.symbol.toLowerCase().contains(query) ||
                instrument.description.toLowerCase().contains(query))
            .toList();

        final updatedState = currentState.copyWith(
          filteredInstruments: filteredInstruments,
        );
        _lastLoadedState = updatedState;
        emit(updatedState);
      }
    } else if (_lastLoadedState != null) {
      final query = event.query.toLowerCase();

      if (query.isEmpty) {
        final updatedState = _lastLoadedState!.copyWith(
          filteredInstruments: _lastLoadedState!.instruments,
        );
        _lastLoadedState = updatedState;
        emit(updatedState);
      } else {
        final filteredInstruments = _lastLoadedState!.instruments
            .where((instrument) =>
                instrument.symbol.toLowerCase().contains(query) ||
                instrument.description.toLowerCase().contains(query))
            .toList();

        final updatedState = _lastLoadedState!.copyWith(
          filteredInstruments: filteredInstruments,
        );
        _lastLoadedState = updatedState;
        emit(updatedState);
      }
    }
  }

  void _onPriceUpdated(
    PriceUpdated event,
    Emitter<TradingInstrumentsState> emit,
  ) {
    if (state is TradingInstrumentsLoaded) {
      _updatePriceInState(event, emit, state as TradingInstrumentsLoaded);
    }
    else if (_lastLoadedState != null) {
      _updatePriceInState(event, emit, _lastLoadedState!);
    }
  }

  void _updatePriceInState(
    PriceUpdated event,
    Emitter<TradingInstrumentsState> emit,
    TradingInstrumentsLoaded stateToUpdate
  ) {
    final updatedInstruments = List<TradingInstrument>.from(stateToUpdate.instruments);

    final int index = updatedInstruments.indexWhere(
      (instrument) => instrument.symbol == event.symbol
    );

    if (index != -1) {
      updatedInstruments[index] = updatedInstruments[index].copyWithUpdatedPrice(
        event.price,
      );

      final updatedFilteredInstruments = List<TradingInstrument>.from(stateToUpdate.filteredInstruments);
      final filteredIndex = updatedFilteredInstruments.indexWhere(
        (instrument) => instrument.symbol == updatedInstruments[index].symbol
      );

      if (filteredIndex != -1) {
        updatedFilteredInstruments[filteredIndex] = updatedInstruments[index];
      }

      final updatedState = stateToUpdate.copyWith(
        instruments: updatedInstruments,
        filteredInstruments: updatedFilteredInstruments,
        updateTrigger: event.symbol,
      );
      _lastLoadedState = updatedState;
      emit(updatedState);
    }
  }

  void _onConnectionStatusChanged(
    ConnectionStatusChanged event,
    Emitter<TradingInstrumentsState> emit,
  ) {
    emit(TradingInstrumentsConnectionChanged(status: event.status));

    if (_lastLoadedState != null) {
      final updatedLoadedState = _lastLoadedState!.copyWith(
        connectionStatus: event.status,
      );
      _lastLoadedState = updatedLoadedState;
      emit(updatedLoadedState);
    }
    else if (state is TradingInstrumentsLoaded) {
      final currentState = state as TradingInstrumentsLoaded;
      final updatedState = currentState.copyWith(
        connectionStatus: event.status,
      );
      _lastLoadedState = updatedState;
      emit(updatedState);
    }
  }

  void _onRetryLoadInstruments(
    RetryLoadInstruments event,
    Emitter<TradingInstrumentsState> emit,
  ) async {
    await _onLoadInstruments(const LoadInstruments(), emit);
  }

  void _connectToTickerStream() {
    _tickerSubscription?.cancel();

    add(const ConnectionStatusChanged(status: ConnectionStatus.connecting));

    try {
      _tickerSubscription = _repository.connectToTickerStream().listen(
        (tickData) {
          if (tickData.containsKey('symbol') && tickData.containsKey('price')) {
            final symbol = tickData['symbol'] as String;

            final priceValue = tickData['price'];
            if (priceValue == null) {
              return;
            }

            final price = (priceValue is num) ? priceValue.toDouble() : 0.0;

            if (price > 0) {
              add(PriceUpdated(
                symbol: symbol,
                price: price,
              ));
            }
          }
        },
        onError: (error) {
          add(const ConnectionStatusChanged(status: ConnectionStatus.error));

          Future.delayed(const Duration(seconds: 3), () {
            _onRetryLoadInstruments(
              const RetryLoadInstruments(),
              (state) {
                if (state is TradingInstrumentsState) {
                  add(const ConnectionStatusChanged(status: ConnectionStatus.connecting));
                }
              } as Emitter<TradingInstrumentsState>
            );
          });
        },
        onDone: () {
          add(const ConnectionStatusChanged(status: ConnectionStatus.disconnected));

          Future.delayed(const Duration(seconds: 3), () {
            _onRetryLoadInstruments(
              const RetryLoadInstruments(),
              (state) {
                if (state is TradingInstrumentsState) {
                  add(const ConnectionStatusChanged(status: ConnectionStatus.connecting));
                }
              } as Emitter<TradingInstrumentsState>
            );
          });
        },
      );

      add(const ConnectionStatusChanged(status: ConnectionStatus.connected));
    } catch (e) {
      add(const ConnectionStatusChanged(status: ConnectionStatus.error));
    }
  }

  @override
  Future<void> close() {
    _tickerSubscription?.cancel();
    _repository.dispose();
    return super.close();
  }
}
