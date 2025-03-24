import 'dart:async';

import 'package:flutter/material.dart';
import '../services/finnhub_service.dart';
import '../utils/connection_status.dart';
import 'trading_instrument.dart';

class TradingInstrumentsProvider with ChangeNotifier {
  final FinnhubService _service;
  List<TradingInstrument> _instruments = [];
  List<TradingInstrument> _filteredInstruments = [];
  bool _isLoading = false;
  String _errorMessage = '';
  ConnectionStatus _connectionStatus = ConnectionStatus.disconnected;
  StreamSubscription? _tickerSubscription;

  TradingInstrumentsProvider(this._service);

  List<TradingInstrument> get instruments => _filteredInstruments;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  ConnectionStatus get connectionStatus => _connectionStatus;

  Future<void> initialize() async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      _instruments = await _service.fetchInstruments();
      _filteredInstruments = _instruments;
      _isLoading = false;
      _errorMessage = '';
      _connectToTickerStream();
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'API Error: ${e.toString()}';
      notifyListeners();
    }
  }

  void _connectToTickerStream() {
    _setConnectionStatus(ConnectionStatus.connecting);

    _tickerSubscription = _service.connectToTickerStream().listen(
      (tickData) {
        // Process ticker data
        if (tickData.containsKey('symbol') && tickData.containsKey('price')) {
          final symbol = tickData['symbol'] as String;
          final price = (tickData['price'] as num).toDouble();
          final previousClose = tickData.containsKey('previousClose')
              ? (tickData['previousClose'] as num).toDouble()
              : null;

          _updateInstrumentPrice(symbol, price, previousClose: previousClose);
        }
      },
      onError: (error) {
        _setConnectionStatus(ConnectionStatus.error);
      },
      onDone: () {
        _setConnectionStatus(ConnectionStatus.disconnected);
      },
    );

    _setConnectionStatus(ConnectionStatus.connected);
  }

  void _setConnectionStatus(ConnectionStatus status) {
    _connectionStatus = status;
    notifyListeners();
  }

  void searchInstruments(String query) {
    if (query.isEmpty) {
      _filteredInstruments = _instruments;
    } else {
      final lowerCaseQuery = query.toLowerCase();
      _filteredInstruments = _instruments.where((instrument) {
        return instrument.symbol.toLowerCase().contains(lowerCaseQuery) ||
               instrument.description.toLowerCase().contains(lowerCaseQuery);
      }).toList();
    }
    notifyListeners();
  }

  void _updateInstrumentPrice(String symbol, double price, {double? previousClose}) {
    final index = _instruments.indexWhere((i) => i.symbol == symbol);
    if (index != -1) {
      final updatedInstrument = _instruments[index].copyWithUpdatedPrice(
        price,
        previousClose: previousClose,
      );

      _instruments = List.from(_instruments)
        ..[index] = updatedInstrument;

      final filteredIndex = _filteredInstruments.indexWhere((i) => i.symbol == symbol);
      if (filteredIndex != -1) {
        _filteredInstruments = List.from(_filteredInstruments)
          ..[filteredIndex] = updatedInstrument;
      }

      notifyListeners();
    }
  }

  Future<void> retry() async {
    await initialize();
  }

  @override
  void dispose() {
    _tickerSubscription?.cancel();
    _service.dispose();
    super.dispose();
  }
}
