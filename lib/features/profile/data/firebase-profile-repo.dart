import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:social_app/features/profile/domain/repos/profile-repo.dart';
import '../domain/entities/profile-user.dart';

class FirebaseProfileRepo implements ProfileRepo {
  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;

  @override
  Future<ProfileUser?> fetchUserProfile(String uid) async {
    try {
      final userDoc = await firebaseFirestore.collection('users').doc(uid).get();
      if (userDoc.exists) {
        final userData = userDoc.data();
        if (userData != null) {
          return ProfileUser(
              uid: uid,
              email: userData['email'],
              name: userData['name'],
              bio: userData['bio'] ?? '',
              profileImageUrl: userData['profileImageUrl'].toString(),
          );
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }
  @override
  Future<void> updateProfile(ProfileUser user) async {
    try {
      final ref = FirebaseFirestore.instance.collection('users').doc(user.uid);

      print('Проверяем, существует ли документ...');
      final doc = await ref.get();

      if (!doc.exists) {
        print('Ошибка: документ с UID ${user.uid} не найден!');
        return;
      }

      print('Документ найден, обновляем...');
      await ref.update({
        'bio': user.bio,
        'profileImageUrl': user.profileImageUrl,
      });

      print('Профиль обновлен');
    } catch (e) {
      print('Ошибка при обновлении Firestorm: $e');
    }
  }
}