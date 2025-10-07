import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_app/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:social_app/features/profile/presentation/components/user-tile.dart';
import '../../domain/entities/profile-user.dart';
import '../cubits/profile-cubit.dart';

class FollowerPage extends StatefulWidget {
  final List<String> followers;
  final List<String> following;
  final String userName;
  const FollowerPage({
    super.key,
    required this.followers,
    required this.following,
    required this.userName,
  });

  @override
  State<FollowerPage> createState() => _FollowerPageState();
}

class _FollowerPageState extends State<FollowerPage> {
  late List<String> followersUids;
  late List<String> followingUids;
  final Set<String> _removedFollowing = <String>{};
  late ProfileCubit profileCubit = context.read<ProfileCubit>();
  late AuthCubit authCubit = context.read<AuthCubit>();

  @override
  void initState() {
    super.initState();
    followersUids = List.from(widget.followers);
    followingUids = List.from(widget.following);
  }

  void removeFromFollowing(String uid) {
    setState(() {
      followingUids.remove(uid);
      _removedFollowing.add(uid);
    });
  }

  Future<void> _refreshUserLists() async {
    final updated =
    await profileCubit.getUserProfile(authCubit.currentUser!.uid);

    if (updated != null && mounted) {
      setState(() {
        followersUids = List.from(updated.followers);
        followingUids = List.from(updated.following);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope<List<String>>(
        canPop: false,
        onPopInvokedWithResult: (bool didPop, List<String>? result) {
      if (didPop) return;
      Navigator.of(context).pop(_removedFollowing.toList());
    },
    child: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
            centerTitle: true,
            title: Text(
              widget.userName,
              style: const TextStyle(
                  fontWeight: FontWeight.w700
              ),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new),
              onPressed: () {
                profileCubit.fetchUserProfile(authCubit.currentUser!.uid);
                Navigator.of(context).pop(_removedFollowing.toList());
              },
            ),
            bottom: TabBar(
                labelColor: Colors.black,
                indicatorPadding: const EdgeInsets.symmetric(horizontal: 30),
                indicatorSize: TabBarIndicatorSize.tab,
                indicatorWeight: 2.5,
                indicatorColor: Colors.black,
                dividerColor: Theme.of(context).colorScheme.tertiary,
                dividerHeight: 0.5,
                unselectedLabelColor: Theme.of(context).colorScheme.inverseSurface,
                tabs: const [
                  Tab(
                    child: Text(
                        'Followers',
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600
                        )
                    ),
                  ),
                  Tab(
                    child: Text(
                        'Following',
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600
                        )
                    ),
                  ),
                ]
            ),
          ),
          body: TabBarView(
              children: [
                _buildUserList(followersUids, 'No followers', context, true),
                _buildUserList(followingUids, 'No Following', context, false),
              ]
          ),
        )
      )
    );
  }

  Widget _buildUserList(
      List<String> uids,
      String emptyMessage,
      BuildContext context,
      bool isFollowerTab,
      ) {
    return uids.isEmpty
        ? Center(child: Text(emptyMessage))
        : ListView.builder(
      itemCount: uids.length,
      itemBuilder: (context, index) {
        final uid = uids[index];
        return FutureBuilder<ProfileUser?>(
          future: context.read<ProfileCubit>().getUserProfile(uid),
          builder: (context, snapshot) {
            if (snapshot.hasData && snapshot.data != null) {
              final user = snapshot.data!;
              return UserTile(
                user: user,
                isFollowerTab: isFollowerTab,
                mode: isFollowerTab
                    ? UserTileMode.delete
                    : UserTileMode.follower,
                onUnfollow: !isFollowerTab
                    ? () => removeFromFollowing(user.uid)
                    : null,
                onProfileClosed: _refreshUserLists,
              );
            } else if (snapshot.connectionState ==
                ConnectionState.waiting) {
              return const ListTile(title: Text('Loading...'));
            } else {
              return const ListTile(title: Text('User not found...'));
            }
          },
        );
      },
    );
  }
}
