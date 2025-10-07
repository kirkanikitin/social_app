import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../profile/presentation/components/user-tile.dart';
import '../cubit/search-history-cubit.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {

  @override
  void initState() {
    super.initState();
    context.read<SearchHistoryCubit>().loadHistory(); // без limit → вся история
  }

  void removeHistory(BuildContext context) async {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            contentPadding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
            insetPadding: const EdgeInsets.symmetric(vertical: 60, horizontal: 60),
            backgroundColor: Theme.of(context).colorScheme.primary,
            title: const Text(
                'Clear your search history?',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                )
            ),
            content: const Text(
                'You will not be able to cancel this action.'
                    ' If you clear your search history,'
                    ' the accounts you searched for may still be shown in the recommended results.',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w300,
                )
            ),
            actions: [
              Column(
                children: [
                  Divider(
                    height: 1,
                    thickness: 1,
                    color: Theme.of(context).colorScheme.tertiary,
                  ),
                  TextButton(
                    onPressed: () {
                      context.read<SearchHistoryCubit>().clearHistory();
                      Navigator.of(context).pop();
                    },
                    child: const Text(
                      'Clear everything',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: Colors.red,
                      ),
                    ),
                  ),
                  Divider(
                    height: 1,
                    thickness: 1,
                    color: Theme.of(context).colorScheme.tertiary,
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text(
                      'Not now',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              )
            ],
          );
        }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
        centerTitle: true,
        title: const Text(
          'Recent requests',
          style: TextStyle(
            fontWeight: FontWeight.w600,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          IconButton(
            onPressed: () {
              removeHistory(context);
            },
            icon: const Icon(
              Icons.history,
              size: 26,
              color: Colors.blue,
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(
            height: 1,
            thickness: 1,
            color: Theme.of(context).colorScheme.tertiary,
          ),
        ),
      ),
      body: BlocBuilder<SearchHistoryCubit, SearchHistoryState>(
          builder: (context, historyState) {
            if (historyState is SearchHistoryLoaded) {
              final history = historyState.history;

              if (history.isEmpty) {
                return const Center(child: Text('The story is empty'));
              }

              return ListView(
                children: history.map((u) => UserTile(
                  user: u,
                  isFollowerTab: false,
                  mode: UserTileMode.history,
                )).toList(),
              );
            }
              return const Center(child: CircularProgressIndicator());
        }
      ),
    );
  }
}
