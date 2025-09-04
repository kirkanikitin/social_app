import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_app/features/search/domain/search-repo.dart';
import '../../../profile/domain/entities/profile-user.dart';

abstract class SearchHistoryState {}

class SearchHistoryInitial extends SearchHistoryState {}

class SearchHistoryLoading extends SearchHistoryState {}

class SearchHistoryLoaded extends SearchHistoryState {
  final List<ProfileUser> history;
  SearchHistoryLoaded(this.history);
}

class SearchHistoryCubit extends Cubit<SearchHistoryState> {
  final SearchRepo repo;
  final String currentUid;

  SearchHistoryCubit({required this.repo, required this.currentUid})
      : super(SearchHistoryInitial());

  Future<void> loadHistory({int? limit}) async {
    emit(SearchHistoryLoading());
    final history = await repo.getHistory(currentUid, limit: limit);
    emit(SearchHistoryLoaded(history));
  }

  Future<void> addToHistory(ProfileUser user) async {
    await repo.addHistory(currentUid, user);
    await loadHistory();
  }

  Future<void> clearHistory() async {
    await repo.clearHistory(currentUid);
    await loadHistory();
  }

  Future<void> removeFromHistory(String uid) async {
    await repo.removeFromHistory(currentUid, uid);
    await loadHistory();
  }
}