import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:social_app/features/auth/domain/entities/app-user.dart';
import 'package:social_app/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:social_app/features/post/presentation/pages/photo-editor-page.dart';
import 'package:social_app/features/profile/presentation/components/bio-box.dart';
import 'package:social_app/features/profile/presentation/components/button-page.dart';
import 'package:social_app/features/profile/presentation/components/follow-button.dart';
import 'package:social_app/features/profile/presentation/components/profile-stats.dart';
import 'package:social_app/features/profile/presentation/cubits/profile-cubit.dart';
import 'package:social_app/features/profile/presentation/cubits/profile-states.dart';
import 'package:social_app/features/profile/presentation/pages/drawer-page.dart';
import 'package:social_app/features/profile/presentation/pages/post-profile.dart';
import '../../../post/presentation/cubits/post-cubit.dart';
import '../components/safe-image.dart';
import 'edit-profile-page.dart';
import 'follower-page.dart';

class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  _SliverTabBarDelegate(this.tabBar);

  @override
  double get minExtent => tabBar.preferredSize.height;
  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverTabBarDelegate oldDelegate) {
    return false;
  }
}


class ProfilePage extends StatefulWidget {
  final String uid;
  const ProfilePage({
    super.key,
    required this.uid,
  });

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
  with SingleTickerProviderStateMixin {
  late final authCubit = context.read<AuthCubit>();
  late final profileCubit = context.read<ProfileCubit>();
  late AppUser? currentUser = authCubit.currentUser;
  late TabController controller;

  @override
  void initState() {
    super.initState();
    controller = TabController(length: 3, vsync: this);
    profileCubit.fetchUserProfile(widget.uid);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void followButtonPressed() {
   final profileState = profileCubit.state;
    if (profileState is! ProfileLoaded) {
      return;
    }
    final profileUser = profileState.profileUser;
    final isFollowing = profileUser.followers.contains(currentUser!.uid);

    setState(() {
      if (isFollowing) {
        profileUser.followers.remove(currentUser!.uid);
      } else {
        profileUser.followers.add(currentUser!.uid);
      }
    });

    profileCubit.toggleFollow(currentUser!.uid, widget.uid).catchError((error) {
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
    return BlocBuilder<ProfileCubit, ProfileState>(
        builder: (context, state) {
          if (state is ProfileLoaded) {
            final user = state.profileUser;
            final userPosts = context.watch<PostCubit>().getPostsByUser(widget.uid);
            final postCount = userPosts.length;
            return Scaffold(
              appBar: AppBar(
                backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
                title: Padding(
                  padding: const EdgeInsets.only(left: 5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Text(
                            user.name,
                            style: const TextStyle(
                                fontWeight: FontWeight.w700
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                        if (widget.uid == currentUser!.uid) ...[
                          GestureDetector(
                            onTap: () {
                              PersistentNavBarNavigator.pushNewScreen(
                                  context,
                                  screen: const PhotoEditorPage(),
                                  withNavBar: false,
                                  pageTransitionAnimation: PageTransitionAnimation.slideRight,
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(right: 30, top: 1),
                              child: Image(
                                image: const AssetImage('lib/assets/icons/add.png'),
                                width: 26,
                                color: Theme.of(context).colorScheme.secondaryContainer,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              PersistentNavBarNavigator.pushNewScreen(
                                context,
                                screen: const MyDrawer(),
                                withNavBar: false,
                                pageTransitionAnimation: PageTransitionAnimation.cupertino,
                              );
                            },
                            child: Image(
                              image: const AssetImage('lib/assets/icons/menu.png'),
                              width: 30,
                              color: Theme.of(context).colorScheme.secondaryContainer,
                            ),
                          ),
                        ] else ...[
                          GestureDetector(
                            onTap: () {},
                            child: const Icon(
                                Icons.more_horiz_rounded,
                                color: Colors.black45,
                                size: 27,
                            ),
                            ),
                          ]
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              body: NestedScrollView(
                  headerSliverBuilder: (context, innerBoxIsScrolled) => [
                    SliverToBoxAdapter(
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 35, left: 25),
                            child: Row(
                              children: [
                                avatarFromUrl(
                                  context: context,
                                  url: user.profileImageUrl,
                                  size: 92,
                                ),
                                const SizedBox(width: 20),
                                ProfileStats(
                                  postCount: postCount,
                                  followerCount: user.followers.length,
                                  followingCount: user.following.length,
                                  onTap: () async {
                                    final result = await PersistentNavBarNavigator.pushNewScreen(
                                      context,
                                      screen: FollowerPage(
                                        followers: user.followers,
                                        following: user.following,
                                        userName: user.name,
                                      ),
                                      withNavBar: false,
                                      pageTransitionAnimation: PageTransitionAnimation.cupertino,
                                    );

                                    final removed = result as List<String>?;
                                    if (removed != null && removed.isNotEmpty && mounted) {
                                      setState(() {
                                        user.following.removeWhere((uid) => removed.contains(uid));
                                      });
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 25, bottom: 10),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: BioBox(text: user.bio),
                            ),
                          ),
                          if (widget.uid == currentUser!.uid) ...[
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 15),
                              child: Row(
                                children: [
                                  MyButtonPage(
                                    title: 'Edit Profile',
                                    leftRight: 40,
                                    onTab: () {
                                      PersistentNavBarNavigator.pushNewScreen(
                                        context,
                                        screen: EditProfilePage(user: user),
                                        withNavBar: false,
                                        pageTransitionAnimation: PageTransitionAnimation.cupertino,
                                      );
                                    },
                                  ),
                                  MyButtonPage(
                                    title: 'Share it',
                                    leftRight: 40,
                                    onTab: () {
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ] else ...[
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 15),
                              child: Row(
                                children: [
                                  FollowButton(
                                    onPressed: followButtonPressed,
                                    leftRight: 40,
                                    isFollowing: user.followers.contains(currentUser!.uid),
                                  ),
                                  MyButtonPage(
                                    title: 'Message',
                                    leftRight: 40,
                                    onTab: () {
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                          const SizedBox(height: 25),
                        ],
                      ),
                    ),
                    SliverPersistentHeader(
                      pinned: true,
                      delegate: _SliverTabBarDelegate(
                        TabBar(
                          controller: controller,
                          labelColor: Theme.of(context).colorScheme.secondaryContainer,
                          indicatorPadding: const EdgeInsets.symmetric(horizontal: 30),
                          indicatorSize: TabBarIndicatorSize.tab,
                          indicatorWeight: 2.5,
                          indicatorColor: Theme.of(context).colorScheme.secondaryContainer,
                          dividerColor: Theme.of(context).colorScheme.tertiary,
                          dividerHeight: 0.5,
                          unselectedLabelColor: Theme.of(context).colorScheme.inverseSurface,
                          tabs: const [
                            Tab(icon: Icon(Icons.grid_on, size: 30,)),
                            Tab(icon: Icon(Icons.play_circle_outlined, size: 30)),
                            Tab(icon: Icon(Icons.person_pin_sharp, size: 30)),
                          ],
                        ),
                      ),
                    ),
                  ],
                  body: TabBarView(
                    controller: controller,
                      children: [
                        MyPost(uid: widget.uid),
                        const Center(child: Text("Страница на стадии разработки")),
                        const Center(child: Text("Страница на стадии разработки")),
                      ],
                    ),
                  ),
                );
              } else if (state is ProfileLoading) {
                return Scaffold(
                  body: Center(
                    child: CircularProgressIndicator(
                    color: Theme.of(context).colorScheme.inverseSurface,
                  ),
                ),
              );
            } else {
              return const Center(
                child: Text('No profile found..'),
              );
            }
        }
    );
  }
}
