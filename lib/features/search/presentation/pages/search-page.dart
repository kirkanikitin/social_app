import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_app/features/search/presentation/cubit/search-cubit.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final searchController = TextEditingController();
  late final searchCubit = context.read<SearchCubit>();

  void onSearchChanger() {
    final query = searchController.text;
    searchCubit.searchUsers(query);
  }

  @override
  void initState() {
    super.initState();
    searchController.addListener(onSearchChanger);
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey.shade200,
        toolbarHeight: 70,
        title: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Theme.of(context).colorScheme.secondary,
          ),
          child: Padding(
            padding: const EdgeInsets.only(left: 15),
            child: TextField(
              cursorColor: Theme.of(context).colorScheme.tertiaryFixed,
              textInputAction: TextInputAction.next,
              controller: searchController,
              decoration: InputDecoration(
                border: InputBorder.none,
                icon: const Icon(Icons.search_sharp),
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
          preferredSize: Size.fromHeight(1),
          child: Divider(
            height: 1,
            thickness: 1,
            color: Theme.of(context).colorScheme.tertiary,
          ),
        ),
      ),
    );
  }
}
