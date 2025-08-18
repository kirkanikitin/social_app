import 'package:flutter/material.dart';

class ProfileStats extends StatelessWidget {
  final int postCount;
  final int followerCount;
  final int followingCount;
  const ProfileStats({
    super.key,
    required this.postCount,
    required this.followerCount,
    required this.followingCount,
  });

  @override
  Widget build(BuildContext context) {
    var textStyleForCount = const TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.bold,
    );
    return Row(
      children: [
        Column(
          children: [
            Text(
              postCount.toString(),
              style: textStyleForCount,
            ),
            const Text('Posts'),
          ],
        ),
        const SizedBox(width: 30),
        Column(
          children: [
            Text(
              followerCount.toString(),
              style: textStyleForCount,
            ),
            const Text('Followers'),
          ],
        ),
        const SizedBox(width: 30),
        Column(
          children: [
            Text(
              followingCount.toString(),
              style: textStyleForCount,
            ),
            const Text('Following'),
          ],
        ),
      ],
    );
  }
}
