import 'package:flutter/material.dart';

class FollowButton extends StatelessWidget {
  final void Function()? onPressed;
  final bool isFollowing;

  const FollowButton({
    super.key,
    required this.onPressed,
    required this.isFollowing,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.only(right: 15),
        child: Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: isFollowing ?
                Theme.of(context).colorScheme.secondary :
                Colors.indigoAccent.shade400,
          ),
          child: GestureDetector(
            onTap: onPressed,
            child: Padding(
              padding: const EdgeInsets.only(left: 40, right: 40, bottom: 6, top: 6),
              child: Text(
                isFollowing ? 'Unfollow' : 'Follow',
                style: TextStyle(
                    color: isFollowing ? Colors.black : Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600
                ),
              ),
            ),
          ),
        ),
    );
  }
}
