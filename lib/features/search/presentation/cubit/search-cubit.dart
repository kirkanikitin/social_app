import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_app/features/search/presentation/cubit/search-states.dart';
import '../../domain/search-repo.dart';

class SearchCubit extends Cubit<SearchState> {
  final SearchRepo searchRepo;

  SearchCubit({required this.searchRepo}) : super(SearchInitial());

  Future<void> searchUsers(String query) async {
    if (query.isEmpty) {
      emit(SearchInitial());
      return;
    }

    try {
      emit(SearchLoading());
      final user = await searchRepo.searchUser(query);
      emit(SearchLoaded(user));
    }
    catch (e) {
      emit(SearchError('Error fetching search results'));
    }
  }
}