import 'package:social_app/features/auth/domain/entities/app-user.dart';

class ProfileUser extends AppUser {
  final String bio;
  final String profileImageUrl;
  final List<String> followers;
  final List<String> following;

  ProfileUser({
    required super.uid,
    required super.email,
    required super.name,
    required this.bio,
    required this.profileImageUrl,
    required this.followers,
    required this.following,
  });

  ProfileUser copyWith({
    String? newBio,
    String? newProfileImageUrl,
    List<String>? newFollowers,
    List<String>? newFolloing,
  }) {
    return ProfileUser(
        uid: uid,
        email: email,
        name: name,
        bio: newBio ?? bio,
        profileImageUrl: newProfileImageUrl ?? profileImageUrl,
        followers: newFollowers ?? followers,
        following: newFolloing ?? following,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'bio': bio,
      'profileImageUrl': profileImageUrl,
      'followers': followers,
      'following': following,
    };
  }

  factory ProfileUser.fromJson(Map<String, dynamic> json) {
    return ProfileUser(
        uid: json['uid'],
        email: json['email'],
        name: json['name'],
        bio: json['bio'] ?? '',
        profileImageUrl: json['profileImageUrl'] ?? '',
        followers: List<String>.from(json['followers'] ?? []),
        following: List<String>.from(json['following'] ?? []),
    );
  }
}