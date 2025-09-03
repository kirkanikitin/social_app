import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:social_app/features/profile/domain/entities/profile-user.dart';
import 'package:social_app/features/profile/presentation/components/button-page.dart';
import 'package:social_app/features/profile/presentation/components/safe-image.dart';
import 'package:social_app/features/profile/presentation/pages/profile-page.dart';
import '../../../auth/domain/entities/app-user.dart';
import '../../../auth/presentation/cubits/auth_cubit.dart';
import '../../../search/presentation/cubit/search-history-cubit.dart';
import '../cubits/profile-cubit.dart';
import 'follow-button.dart';

enum UserTileMode {
  plain,      // без trailing
  history,    // Cancel (удалить из истории)
  delete,     // MyButtonPage Delete
  follower,   // Follow/Unfollow
}

class UserTile extends StatefulWidget {
  final ProfileUser user;
  final bool isFollowerTab;
  final UserTileMode mode;
  final VoidCallback? onUnfollow;
  final VoidCallback? onProfileClosed;
  const UserTile({
    super.key,
    required this.user,
    required this.isFollowerTab,
    this.mode = UserTileMode.plain,
    this.onUnfollow,
    this.onProfileClosed,
  });

  @override
  State<UserTile> createState() => _UserTileState();
}

class _UserTileState extends State<UserTile> {
  late final authCubit = context.read<AuthCubit>();
  late final profileCubit = context.read<ProfileCubit>();
  late AppUser? currentUser = authCubit.currentUser;

  void followButtonPressed() {
    final profileUser = widget.user;
    final isFollowing = profileUser.followers.contains(currentUser!.uid);

    // сначала локально обновляем UI
    setState(() {
      if (isFollowing) {
        profileUser.followers.remove(currentUser!.uid);
        if (!widget.isFollowerTab) {
          widget.onUnfollow?.call(); // сразу удаляем из списка
        }
      } else {
        profileUser.followers.add(currentUser!.uid);
      }
    });

    // Firestore обновляем параллельно
    profileCubit.toggleFollow(currentUser!.uid, profileUser.uid).catchError((_) {
      // откат в случае ошибки
      setState(() {
        if (isFollowing) {
          profileUser.followers.add(currentUser!.uid);
        } else {
          profileUser.followers.remove(currentUser!.uid);
        }
      });
    });
  }

  Widget? _buildTrailing() {
    switch (widget.mode) {
      case UserTileMode.plain:
        return null;

      case UserTileMode.history:
        return GestureDetector(
          onTap: () {
            context.read<SearchHistoryCubit>().removeFromHistory(widget.user.uid);
          },
          child: const Padding(
            padding: EdgeInsets.only(top: 10),
            child: Icon(Icons.close, size: 18, color: Colors.grey),
          ),
        );

      case UserTileMode.delete:
        return MyButtonPage(
          title: 'Delete',
          leftRight: 15,
          onTab: () {

          },
        );

      case UserTileMode.follower:
        return FollowButton(
          onPressed: followButtonPressed,
          leftRight: 20,
          isFollowing: widget.user.followers.contains(currentUser!.uid),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Column(
        children: [
          const SizedBox(height: 5),
          Row(
            children: [
              avatarFromUrl(
                context: context,
                url: widget.user.profileImageUrl,
                size: 55,
              ),
              const SizedBox(width: 15),
              Text(
                widget.user.name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
      trailing: _buildTrailing(),
      onTap: () async {
        PersistentNavBarNavigator.pushNewScreen(
          context,
          screen: ProfilePage(uid: widget.user.uid),
          withNavBar: false,
          pageTransitionAnimation: PageTransitionAnimation.cupertino,
        ).then((_) {
          widget.onProfileClosed?.call();
        });
      },
    );
  }
}
