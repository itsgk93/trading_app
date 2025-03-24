import 'dart:developer' as developer;

class AppLogger {
  static const String webSocket = 'WebSocket';
  static const String priceUpdate = 'PriceUpdate';
  static const String bloc = 'Bloc';
  static const String repository = 'Repository';
  static const String service = 'Service';
  static const String ui = 'UI';

  static void info(String message, {String tag = 'App'}) {
    developer.log(
      message,
      name: tag,
      level: 800, 
    );
    _printFormatted(tag, 'INFO', message);
  }

  static void debug(String message, {String tag = 'App'}) {
    developer.log(
      message,
      name: tag,
      level: 500, 
    );
    _printFormatted(tag, 'DEBUG', message);
  }

  static void warning(String message, {String tag = 'App'}) {
    developer.log(
      message,
      name: tag,
      level: 900,
    );
    _printFormatted(tag, 'WARN', message);
  }

  static void error(String message, {String tag = 'App', Object? error, StackTrace? stackTrace}) {
    developer.log(
      message,
      name: tag,
      level: 1000, 
      error: error,
      stackTrace: stackTrace,
    );
    _printFormatted(tag, 'ERROR', message);
    if (error != null) {
      print('  └─ Error: $error');
    }
    if (stackTrace != null) {
      print('  └─ StackTrace: ${stackTrace.toString().split('\n').first}...');
    }
  }

  static void webSocketMessage(String message) {
    debug(message, tag: webSocket);
  }

  static void logPriceUpdate(String symbol, double price) {
    debug('Symbol: $symbol, Price: $price', tag: priceUpdate);
  }

  static void _printFormatted(String tag, String level, String message) {
    final now = DateTime.now();
    final timeFormatted = '${_pad(now.hour)}:${_pad(now.minute)}:${_pad(now.second)}.${_pad(now.millisecond, 3)}';

    String levelColor;
    switch (level) {
      case 'INFO':
        levelColor = '\x1B[32m'; 
        break;
      case 'DEBUG':
        levelColor = '\x1B[36m'; 
        break;
      case 'WARN':
        levelColor = '\x1B[33m';
        break;
      case 'ERROR':
        levelColor = '\x1B[31m';
        break;
      default:
        levelColor = '\x1B[37m'; 
    }

    const reset = '\x1B[0m';
    const tagColor = '\x1B[35m';

    print('$timeFormatted $levelColor$level$reset [$tagColor$tag$reset] $message');
  }

  static String _pad(int n, [int width = 2]) {
    return n.toString().padLeft(width, '0');
  }
}
