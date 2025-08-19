import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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

  @override
  void initState() {
    super.initState();
    followersUids = List.from(widget.followers);
    followingUids = List.from(widget.following);
  }

  void removeFromFollowing(String uid) {
    setState(() {
      followingUids.remove(uid);
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: Text(
              widget.userName,
              style: const TextStyle(
                  fontWeight: FontWeight.w700
              ),
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
                onUnfollow: !isFollowerTab
                    ? () => removeFromFollowing(user.uid)
                    : null,
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
