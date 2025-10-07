import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_app/features/profile/presentation/components/user-tile.dart';
import 'package:social_app/features/search/presentation/cubit/search-cubit.dart';
import 'package:social_app/features/search/presentation/cubit/search-states.dart';
import 'package:social_app/features/search/presentation/pages/history-page.dart';

import '../cubit/search-history-cubit.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController searchController = TextEditingController();


  @override
  void initState() {
    super.initState();
    searchController.addListener(() {
      final value = searchController.text.trim();
      final searchCubit = context.read<SearchCubit>();

      if (value.isEmpty) {
        // если поле пустое → показываем историю
        context.read<SearchHistoryCubit>().loadHistory(limit: 10);
      } else {
        // если есть текст → делаем поиск
        searchCubit.searchUsers(value);
      }
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(), // закрываем клавиатуру
      behavior: HitTestBehavior.translucent,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
          toolbarHeight: 70,
          title: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Theme.of(context).colorScheme.primary,
            ),
            child: Padding(
              padding: const EdgeInsets.only(left: 15),
              child: TextField(
                cursorColor: Theme.of(context).colorScheme.tertiaryFixed,
                textInputAction: TextInputAction.next,
                controller: searchController,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  icon: Icon(
                      Icons.search_sharp,
                      color: Theme.of(context).colorScheme.secondaryFixed,
                  ),
                  hintText: 'Search',
                  hintStyle: TextStyle(
                    color: Theme.of(context).colorScheme.secondaryFixed,
                    fontWeight: FontWeight.w500
                  ),
                  iconColor: Colors.black54,
                ),
              ),
            ),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Divider(
              height: 1,
              thickness: 1,
              color: Theme.of(context).colorScheme.tertiary,
            ),
          ),
        ),
        body: BlocBuilder<SearchCubit, SearchState>(
          builder: (context, state) {
            if (searchController.text.isEmpty) {
              final historyState = context.watch<SearchHistoryCubit>().state;

              if (historyState is SearchHistoryLoaded) {
                final history = historyState.history;

                if (history.isEmpty) {
                  return const Center(child: Text('The story is empty'));
                }

                return ListView(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 20, left: 15, right: 15),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                           Text(
                            'Recent',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Theme.of(context).colorScheme.secondaryContainer,
                            )
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                  context, MaterialPageRoute(
                                  builder: (context) => const HistoryPage()
                                ),
                              );
                            },
                            child: const Text(
                                'All',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.blue,
                                )
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    ...history.map((u) => UserTile(
                      user: u,
                      isFollowerTab: false,
                      mode: UserTileMode.history,
                      onProfileClosed: () {
                        context.read<SearchHistoryCubit>().addToHistory(u);
                      },
                    )),
                  ]
                );
              }

              return const Center(child: CircularProgressIndicator());
            }

            /// когда есть активный поиск
            if (state is SearchLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is SearchLoaded) {
              if (state.users.isEmpty) {
                return const Center(child: Text('The user was not found'));
              }

              return ListView(
                children: state.users
                    .map((u) => UserTile(
                  user: u!,
                  isFollowerTab: false,
                  mode: UserTileMode.plain,
                  /// добавляем в историю при переходе в профиль
                  onProfileClosed: () {
                    context.read<SearchHistoryCubit>().addToHistory(u);
                  },
                )).toList(),
              );
            } else if (state is SearchError) {
              return Center(child: Text('Error: ${state.message}'));
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}
