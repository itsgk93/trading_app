import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trading_app/widgets/error_widget.dart';

import '../blocs/trading_instruments/events/trading_instruments_event.dart';
import '../blocs/trading_instruments/states/trading_instruments_state.dart';
import '../blocs/trading_instruments/trading_instruments_bloc.dart';
import '../widgets/connection_status_widget.dart';
import '../widgets/instrument_list.dart';
import '../widgets/search_bar_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Exinity App', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),),
        centerTitle: true,
        actions: const [
          ConnectionStatusWidget(),
          SizedBox(width: 16),
        ],
      ),
      body: BlocConsumer<TradingInstrumentsBloc, TradingInstrumentsState>(
        listener: (context, state) {
          if (state is TradingInstrumentsError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: ${state.message}'),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 5),
                action: SnackBarAction(
                  label: 'Retry',
                  textColor: Colors.white,
                  onPressed: () {
                    context.read<TradingInstrumentsBloc>().add(
                          const RetryLoadInstruments(),
                        );
                  },
                ),
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is TradingInstrumentsError) {
            return ErrorDisplayWidget(
              errorMessage: state.message,
              onRetry: () => context.read<TradingInstrumentsBloc>().add(
                    const RetryLoadInstruments(),
                  ),
            );
          }

          if (state is TradingInstrumentsLoaded) {
            if (state.instruments.isEmpty) {
              return const Center(
                child: Text('No instruments available'),
              );
            }

            return Column(
              children: [
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: SearchBarWidget(),
                ),

                Expanded(
                  child: InstrumentListWidget(
                    instruments: state.filteredInstruments,
                  ),
                ),
              ],
            );
          }

          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }
}
