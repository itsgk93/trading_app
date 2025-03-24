import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trading_app/core/resources/images.dart';

import '../blocs/trading_instruments/events/trading_instruments_event.dart';
import '../blocs/trading_instruments/states/trading_instruments_state.dart';
import '../blocs/trading_instruments/trading_instruments_bloc.dart';
import '../utils/connection_status.dart';
import 'home_screen.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TradingInstrumentsBloc, TradingInstrumentsState>(
      listener: (context, state) {
        if (state is TradingInstrumentsLoaded) {
          if (state.instruments.isNotEmpty &&
              state.connectionStatus == ConnectionStatus.connected) {
            Future.delayed(const Duration(milliseconds: 500), () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const HomeScreen()),
              );
            });
          }
        }
      },
      builder: (context, state) {
        if (state is TradingInstrumentsInitial) {
          context.read<TradingInstrumentsBloc>().add(const LoadInstruments());
        }

        return Scaffold(
          backgroundColor: const Color(0xff262437),
          body: SafeArea(
            child: Center(
                child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    Images.logo,
                    height: 150,
                  ),
                  const SizedBox(height: 48),
                  _buildStatusSection(context, state),
                ],
              ),
            )),
          ),
        );
      },
    );
  }

  Widget _buildStatusSection(
      BuildContext context, TradingInstrumentsState state) {
    if (state is TradingInstrumentsError) {
      return Column(
        children: [
          const Icon(
            Icons.error_outline,
            size: 48,
            color: Colors.red,
          ),
          const SizedBox(height: 16),
          Text(
            'Error: ${state.message}',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.red),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              context
                  .read<TradingInstrumentsBloc>()
                  .add(const RetryLoadInstruments());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
            child: const Text('Retry'),
          ),
        ],
      );
    } else if (state is TradingInstrumentsLoaded) {
      final isConnected = state.connectionStatus == ConnectionStatus.connected;
      final isConnecting =
          state.connectionStatus == ConnectionStatus.connecting;

      return Column(
        children: [
          if (isConnected)
            const Icon(
              Icons.check_circle,
              size: 48,
              color: Colors.green,
            )
          else if (isConnecting)
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
            )
          else
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
            ),
          const SizedBox(height: 16),
          Text(
            isConnected
                ? 'Connected to price feed!'
                : isConnecting
                    ? 'Connecting to price feed...'
                    : 'Waiting for connection...',
            style: TextStyle(
              color: isConnected
                  ? Colors.green
                  : isConnecting
                      ? Colors.blue
                      : Colors.orange,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      );
    } else {
      return Column(
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
          ),
          const SizedBox(height: 16),
          Text(
            'Loading trading instruments...',
            style: TextStyle(
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      );
    }
  }
}
