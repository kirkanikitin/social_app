import 'package:flutter/material.dart';

class FollowButton extends StatelessWidget {
  final void Function()? onPressed;
  final bool isFollowing;
  final double leftRight;

  const FollowButton({
    super.key,
    required this.onPressed,
    required this.isFollowing,
    required this.leftRight,
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
              padding: EdgeInsets.only(left: leftRight, right: leftRight, bottom: 6, top: 6),
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
