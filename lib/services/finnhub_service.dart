import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/trading_instrument.dart';
import '../utils/app_exceptions.dart';

class FinnhubService {
  static const String _apiKey = 'cvglm2pr01qmr1uscvn0cvglm2pr01qmr1uscvng';
  static const String _wsUrl = 'wss://ws.finnhub.io';

  static const List<String> _forexSymbols = [
    'OANDA:EUR_USD',
    'OANDA:GBP_USD',
    'OANDA:USD_JPY',
    'OANDA:AUD_USD',
    'OANDA:USD_CAD',
    'OANDA:USD_CHF',
    'OANDA:NZD_USD',
    'OANDA:EUR_GBP',
    'OANDA:EUR_JPY',
    'OANDA:GBP_JPY',
    'OANDA:USD_MXN',
    'OANDA:USD_SGD',
    'OANDA:USD_HKD',
    'OANDA:EUR_CHF',
    'OANDA:AUD_JPY',
  ];

  final http.Client _httpClient;
  WebSocket? _socket;
  final List<String> _subscribedSymbols = [];
  final StreamController<Map<String, dynamic>> _dataStreamController =
      StreamController<Map<String, dynamic>>.broadcast();
  Timer? _reconnectTimer;
  Timer? _heartbeatTimer;
  StreamSubscription? _socketSubscription;
  List<TradingInstrument> _instruments = [];

  FinnhubService({http.Client? httpClient})
      : _httpClient = httpClient ?? http.Client();

  Future<List<TradingInstrument>> fetchInstruments() async {
    _instruments = [];

    try {
      _instruments = _forexSymbols.map((symbol) {
        final parts = symbol.split(':');
        final currencyPair = parts[1];
        final displaySymbol = currencyPair.replaceAll('_', '/');
        final description = displaySymbol;

        const previousClose = 0.0;

        return TradingInstrument(
          symbol: symbol,
          displaySymbol: displaySymbol,
          description: description,
          previousClosePrice: previousClose,
        );
      }).toList();

      _connectWebSocket();
      _setupHeartbeat();

      return _instruments;
    } catch (e) {
      throw ApiException(
        statusCode: 500,
        message: 'An unexpected error occurred: $e',
      );
    }
  }

  Stream<Map<String, dynamic>> connectToTickerStream() {
    return _dataStreamController.stream;
  }

  void _connectWebSocket() async {
    await _socketSubscription?.cancel();
    await _socket?.close();
    try {
      const wsUrl = '$_wsUrl?token=$_apiKey';
      _socket = await WebSocket.connect(wsUrl);

      _socketSubscription = _socket!.listen(
        (dynamic message) {
          _processWebSocketMessage(message);
        },
        onError: (error) {
          _scheduleReconnect();
        },
        onDone: () {
          _scheduleReconnect();
        },
      );

      _subscribedSymbols.clear();
      _subscribeToSymbols();
    } catch (e) {
      _scheduleReconnect();
    }
  }

  void _processWebSocketMessage(dynamic message) {
    if (message is String) {
      try {
        final Map<String, dynamic> data = json.decode(message);

        if (data['type'] == 'error') {
          return;
        }

        if (data.containsKey('data') && data['data'] is List) {
          final List<dynamic> trades = data['data'];

          for (final trade in trades) {
            if (trade is Map<String, dynamic> &&
                trade.containsKey('s') &&
                trade.containsKey('p')) {

              final symbol = trade['s'] as String?;
              if (symbol == null || symbol.isEmpty) {
                continue;
              }

              final priceValue = trade['p'];
              if (priceValue == null) {
                continue;
              }

              final price = (priceValue is num) ? priceValue.toDouble() : 0.0;
              if (price <= 0) {
                continue;
              }

              final instrumentIndex = _instruments.indexWhere(
                (instr) => instr.symbol == symbol
              );

              if (instrumentIndex == -1) {
                continue;
              }

              final instrument = _instruments[instrumentIndex];
              final previousPrice = instrument.currentPrice > 0 ? instrument.currentPrice : null;

              final updateData = {
                'symbol': symbol,
                'price': price,
                'previousPrice': previousPrice,
              };

              _updateInstrumentPrice(symbol, price, previousPrice);
              _dataStreamController.add(updateData);
            }
          }
        }
      } catch (e) {
        // Silent error in production
      }
    }
  }

  void _updateInstrumentPrice(String symbol, double price, [double? previousPrice]) {
    final index = _instruments.indexWhere((instrument) => instrument.symbol == symbol);

    if (index >= 0) {
      _instruments[index] = _instruments[index].copyWithUpdatedPrice(price);
    }
  }

  void _subscribeToSymbols() {
    for (final symbol in _forexSymbols) {
      subscribeToSymbol(symbol);
    }
  }

  void _sendPing() {
    if (_socket != null && _socket!.readyState == WebSocket.open) {
      _socket!.add(json.encode({'type': 'ping'}));
    }
  }

  void _setupHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (_socket != null && _socket!.readyState == WebSocket.open) {
        _sendPing();
      } else {
        timer.cancel();
      }
    });
  }

  void _scheduleReconnect() {
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(const Duration(seconds: 3), () {
      _connectWebSocket();
      _setupHeartbeat();

      for (final symbol in List<String>.from(_subscribedSymbols)) {
        subscribeToSymbol(symbol);
      }
    });
  }

  void subscribeToSymbol(String symbol) {
    if (_socket != null && _socket!.readyState == WebSocket.open) {
      if (!_subscribedSymbols.contains(symbol)) {
        _socket!.add(json.encode({
          'type': 'subscribe',
          'symbol': symbol
        }));

        _subscribedSymbols.add(symbol);
      }
    }
  }

  void unsubscribeFromSymbol(String symbol) {
    if (_socket != null && _socket!.readyState == WebSocket.open) {
      if (_subscribedSymbols.contains(symbol)) {
        _socket!.add(json.encode({
          'type': 'unsubscribe',
          'symbol': symbol
        }));

        _subscribedSymbols.remove(symbol);
      }
    }
  }

  void dispose() {
    _reconnectTimer?.cancel();
    _heartbeatTimer?.cancel();
    _socketSubscription?.cancel();
    _socket?.close();
    _dataStreamController.close();
    _httpClient.close();
  }
}
