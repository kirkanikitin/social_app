

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:social_app/features/profile/domain/entities/profile-user.dart';
import 'package:social_app/features/search/domain/search-repo.dart';

class FireBaseSearchRepo implements SearchRepo {
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

}