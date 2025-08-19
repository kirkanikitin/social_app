import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:social_app/features/profile/domain/entities/profile-user.dart';
import 'package:social_app/features/profile/presentation/components/button-page.dart';
import 'package:social_app/features/profile/presentation/components/safe-image.dart';
import 'package:social_app/features/profile/presentation/pages/profile-page.dart';
import '../../../auth/domain/entities/app-user.dart';
import '../../../auth/presentation/cubits/auth_cubit.dart';
import '../cubits/profile-cubit.dart';
import 'follow-button.dart';

class UserTile extends StatefulWidget {
  final ProfileUser user;
  final bool isFollowerTab;
  final VoidCallback? onUnfollow;
  const UserTile({
    super.key,
    required this.user,
    required this.isFollowerTab,
    this.onUnfollow,
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
          profileCubit.updateProfile(uid: currentUser!.uid); // обновляем профиль текущего пользователя
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
      trailing: widget.isFollowerTab
          ? MyButtonPage(
        title: 'Delete',
        leftRight: 15,
        onTab: () {

        },
      )
          : FollowButton(
        onPressed: followButtonPressed,
        leftRight: 20,
        isFollowing: widget.user.followers.contains(currentUser!.uid),
      ),
      onTap: () => PersistentNavBarNavigator.pushNewScreen(
        context,
        screen: ProfilePage(uid: widget.user.uid),
        withNavBar: false,
        pageTransitionAnimation: PageTransitionAnimation.cupertino,
      ),
    );
  }
}
