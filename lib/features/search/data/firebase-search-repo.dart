import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:social_app/features/profile/domain/entities/profile-user.dart';
import 'package:social_app/features/search/domain/search-repo.dart';

class FireBaseSearchRepo implements SearchRepo {
  final fireStore = FirebaseFirestore.instance;

  @override
  Future<List<ProfileUser?>> searchUser(String query) async {
    try {
      final result = await FirebaseFirestore.instance
          .collection('users')
          .where('name', isGreaterThanOrEqualTo: query)
          .where('name', isLessThanOrEqualTo: '$query\uf8ff')
          .get();
      return result.docs
          .map((doc) => ProfileUser.fromJson(doc.data()))
          .toList();
    }
    catch (e) {
      throw Exception('Error searching users: $e');
    }
  }

  @override
  Future<void> addHistory(String currentUid, ProfileUser user) async {
    await fireStore
        .collection('users')
        .doc(currentUid)
        .collection('searchHistory')
        .doc(user.uid)
        .set({
      'uid': user.uid,
      'name': user.name.isNotEmpty ? user.name : 'Unknown',
      'profileImageUrl': user.profileImageUrl ?? '',
      'visitedAt': DateTime.now().millisecondsSinceEpoch,
    });
  }

  @override
  Future<List<ProfileUser>> getHistory(String currentUid, {int? limit}) async {
    var query = fireStore
        .collection('users')
        .doc(currentUid)
        .collection('searchHistory')
        .orderBy('visitedAt', descending: true);

    if (limit != null) {
      query = query.limit(limit);
    }

    final snapshot = await query.get();

    return snapshot.docs.map((doc) {
      return ProfileUser.fromJson(doc.data());
    }).toList();
  }

  @override
  Future<void> clearHistory(String currentUid) async {
    final ref = fireStore.collection('users').doc(currentUid).collection('searchHistory');
    final batch = fireStore.batch();
    final docs = await ref.get();
    for (var doc in docs.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }

  @override
  Future<void> removeFromHistory(String currentUid, String uid) async {
    await fireStore
        .collection('users')
        .doc(currentUid)
        .collection('searchHistory')
        .doc(uid)
        .delete();
  }
}