import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'blocs/trading_instruments/trading_instruments_bloc.dart';
import 'repositories/trading_instruments_repository.dart';
import 'screens/splash_screen.dart';
import 'services/finnhub_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final finnhubService = FinnhubService();

    final tradingInstrumentsRepository = TradingInstrumentsRepository(
      service: finnhubService,
    );

    final tradingInstrumentsBloc = TradingInstrumentsBloc(
      repository: tradingInstrumentsRepository,
    );

    return MultiBlocProvider(
      providers: [
        BlocProvider<TradingInstrumentsBloc>(
          create: (context) => tradingInstrumentsBloc,
        ),
      ],
      child: MaterialApp(
        title: 'Forex Trading App',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          scaffoldBackgroundColor: Colors.grey[100],
          appBarTheme: AppBarTheme(
            backgroundColor: Colors.white,
            foregroundColor: Colors.blue[800],
            elevation: 0,
          ),
          cardTheme: CardTheme(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        debugShowCheckedModeBanner: false,
        home: const SplashScreen(),
      ),
    );
  }
}
