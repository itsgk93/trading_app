import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/trading_instruments/events/trading_instruments_event.dart';
import '../blocs/trading_instruments/trading_instruments_bloc.dart';

class SearchBarWidget extends StatefulWidget {
  const SearchBarWidget({Key? key}) : super(key: key);

  @override
  State<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isSearching = false;

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onClearSearch() {
    _controller.clear();
    _performSearch('');
    setState(() {
      _isSearching = false;
    });
    _focusNode.unfocus();
  }

  void _performSearch(String query) {
    context.read<TradingInstrumentsBloc>().add(SearchInstruments(query: query));
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 0,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
        child: Row(
          children: [
            Icon(
              Icons.search,
              color: _isSearching
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                decoration: InputDecoration(
                  hintText: 'Search instruments...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(
                    color: Theme.of(context).hintColor,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onChanged: (text) {
                  setState(() {
                    _isSearching = text.isNotEmpty;
                  });
                  _performSearch(text);
                },
                textInputAction: TextInputAction.search,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            if (_isSearching)
              IconButton(
                icon: const Icon(Icons.clear),
                onPressed: _onClearSearch,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                iconSize: 20,
              ),
          ],
        ),
      ),
    );
  }
}
