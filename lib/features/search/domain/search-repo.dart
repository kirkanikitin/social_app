import 'package:social_app/features/profile/domain/entities/profile-user.dart';

abstract class SearchRepo {
  Future<List<ProfileUser?>> searchUser(String query);
  Future<void> addHistory(String currentUid, ProfileUser user);
  Future<List<ProfileUser>> getHistory(String currentUid, {int? limit});
  Future<void> clearHistory(String currentUid);
  Future<void> removeFromHistory(String currentUid, String uid);
}

