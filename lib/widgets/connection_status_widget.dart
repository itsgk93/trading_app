import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/trading_instruments/events/trading_instruments_event.dart';
import '../blocs/trading_instruments/states/trading_instruments_state.dart';
import '../blocs/trading_instruments/trading_instruments_bloc.dart';
import '../utils/connection_status.dart';

class ConnectionStatusWidget extends StatelessWidget {
  const ConnectionStatusWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TradingInstrumentsBloc, TradingInstrumentsState>(
      buildWhen: (previous, current) {
        return current is TradingInstrumentsConnectionChanged ||
            (previous is TradingInstrumentsLoaded &&
                current is TradingInstrumentsLoaded &&
                previous.connectionStatus != current.connectionStatus);
      },
      builder: (context, state) {
        ConnectionStatus status = ConnectionStatus.disconnected;

        if (state is TradingInstrumentsConnectionChanged) {
          status = state.status;
        } else if (state is TradingInstrumentsLoaded) {
          status = state.connectionStatus;
        }

        IconData icon;
        Color color;
        String tooltip;

        switch (status) {
          case ConnectionStatus.connected:
            icon = Icons.wifi;
            color = Colors.green;
            tooltip = 'WebSocket connected';
            break;
          case ConnectionStatus.connecting:
            icon = Icons.wifi_find;
            color = Colors.orange;
            tooltip = 'Connecting to WebSocket...';
            break;
          case ConnectionStatus.disconnected:
            icon = Icons.wifi_off;
            color = Colors.grey;
            tooltip = 'WebSocket disconnected';
            break;
          case ConnectionStatus.error:
            icon = Icons.error_outline;
            color = Colors.red;
            tooltip = 'WebSocket connection error';
            break;
        }

        return Tooltip(
          message: tooltip,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: color,
                size: 24,
              ),
              if (status != ConnectionStatus.connected)
                IconButton(
                  icon: const Icon(Icons.refresh, size: 18),
                  tooltip: 'Reconnect WebSocket',
                  color: Colors.grey,
                  onPressed: () {
                    context.read<TradingInstrumentsBloc>().add(
                          const RetryLoadInstruments(),
                        );
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Reconnecting to price feed...'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                ),
            ],
          ),
        );
      },
    );
  }
}
