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
          final followers = List<String>.from(userData['followers'] ?? []);
          final following = List<String>.from(userData['following'] ?? []);

          return ProfileUser(
              uid: uid,
              email: userData['email'],
              name: userData['name'],
              bio: userData['bio'] ?? '',
              profileImageUrl: userData['profileImageUrl'].toString(),
              followers: followers,
              following: following
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

  @override
  Future<void> toggleFollow(String currentUid, String targetUid) async {
    try {
      final currentUserDoc =
        await firebaseFirestore.collection('users').doc(currentUid).get();
      final targetUserDoc =
      await firebaseFirestore.collection('users').doc(targetUid).get();

      if (currentUserDoc.exists && targetUserDoc.exists) {
        final currentUserData = currentUserDoc.data();
        final targetUserData = targetUserDoc.data();

        if (currentUserData != null && targetUserData != null) {
          final List<String> currentFollowing =
              List<String>.from(currentUserData['following'] ?? []);

          if (currentFollowing.contains(targetUid)) {
            await firebaseFirestore.collection('users').doc(currentUid).update({
              'following': FieldValue.arrayRemove([targetUid])
            });
            await firebaseFirestore.collection('users').doc(targetUid).update({
              'followers': FieldValue.arrayRemove([currentUid])
            });
          }
        } else {
          await firebaseFirestore.collection('users').doc(currentUid).update({
            'following': FieldValue.arrayUnion([targetUid])
          });
          await firebaseFirestore.collection('users').doc(targetUid).update({
            'followers': FieldValue.arrayUnion([currentUid])
          });
        }
      }
    } catch (e) {}
  }

}