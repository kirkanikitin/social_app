import 'package:social_app/features/auth/domain/entities/app-user.dart';

import '../../../profile/domain/entities/profile-user.dart';

abstract class AuthRepo {
  Future<AppUser?> loginWithEmailPassword(String email, String password);
  Future<AppUser?> registerWithEmailPassword(String name, String email, String password);
  Future<ProfileUser?> loginWithGoogle();
  Future<void> logout();
  Future<AppUser?> getCurrentUser();
}