import 'package:social_app/features/profile/domain/entities/profile-user.dart';

abstract class SearchRepo {
  Future<List<ProfileUser?>> searchUser(String query);
}

