import '../models/trading_instrument.dart';
import '../services/finnhub_service.dart';

class TradingInstrumentsRepository {
  final FinnhubService _service;

  TradingInstrumentsRepository({FinnhubService? service})
      : _service = service ?? FinnhubService();

  Future<List<TradingInstrument>> fetchInstruments() async {
    final instruments = await _service.fetchInstruments();
    return instruments;
  }

  Stream<Map<String, dynamic>> connectToTickerStream() {
    return _service.connectToTickerStream();
  }

  Future<TradingInstrument?> getInstrumentBySymbol(String symbol) async {
    final instruments = await fetchInstruments();
    try {
      return instruments.firstWhere((instrument) => instrument.symbol == symbol);
    } catch (e) {
      return null;
    }
  }

  void subscribeToSymbol(String symbol) {
    _service.subscribeToSymbol(symbol);
  }

  void unsubscribeFromSymbol(String symbol) {
    _service.unsubscribeFromSymbol(symbol);
  }

  void dispose() {
    _service.dispose();
  }
}
