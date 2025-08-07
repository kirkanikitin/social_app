import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:social_app/features/auth/domain/entities/app-user.dart';
import 'package:social_app/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:social_app/features/post/presentation/pages/upload-post-page.dart';
import 'package:social_app/features/profile/presentation/components/bio-box.dart';
import 'package:social_app/features/profile/presentation/components/button-page.dart';
import 'package:social_app/features/profile/presentation/components/tab-bar.dart';
import 'package:social_app/features/profile/presentation/cubits/profile-cubit.dart';
import 'package:social_app/features/profile/presentation/cubits/profile-states.dart';
import 'package:social_app/features/profile/presentation/components/drawer.dart';

import 'edit-profile-page.dart';

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

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileCubit, ProfileState>(
        builder: (context, state) {
          if (state is ProfileLoaded) {
            final user = state.profileUser;
            return Scaffold(
              appBar: AppBar(
                backgroundColor: Theme.of(context).colorScheme.primary,
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
                          GestureDetector(
                            onTap: () {
                              PersistentNavBarNavigator.pushNewScreen(
                                  context,
                                  screen: const UploadPostPage(onPostUploaded: null),
                                  withNavBar: false,
                                  pageTransitionAnimation: PageTransitionAnimation.slideRight,
                              );
                            },
                            child: const Padding(
                              padding: EdgeInsets.only(right: 30, top: 1),
                              child: Image(
                                image: AssetImage('lib/assets/icons/add.png'),
                                width: 26,

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
                            child: const Image(
                              image: AssetImage('lib/assets/icons/menu.png'),
                              width: 30,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              body: ListView(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 35, left: 25),
                    child: Row(
                      children: [
                        CachedNetworkImage(
                          imageUrl: user.profileImageUrl,
                          placeholder: (context, url) =>
                              CircularProgressIndicator(color: Theme.of(context).colorScheme.inverseSurface),
                          errorWidget: (context, url, error) =>
                              Container(
                                height: 92,
                                width: 92,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(50),
                                  border: Border.all(
                                    color: Theme.of(context).colorScheme.inversePrimary
                                  ),
                                  color: Theme.of(context).colorScheme.secondary,
                                ),
                                child: Icon(
                                  Icons.person,
                                  size: 54,
                                  color: Theme.of(context).colorScheme.inverseSurface,
                                ),
                              ),
                          imageBuilder: (context, imageProvider) =>
                            Container(
                              height: 92,
                              width: 92,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                image: DecorationImage(
                                  image: imageProvider,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 280),
                    child: Container(
                      child: Center(
                        child: BioBox(text: user.bio),
                      ),
                    ),
                  ),
                  if (widget.uid == currentUser!.uid) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: Row(
                        children: [
                          MyButtonPage(
                            title: 'Edit Profile',
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
                            title: 'Share your profile',
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
                          MyButtonPage(
                            title: 'Follow',
                            onTab: () {
                            },
                          ),
                          MyButtonPage(
                            title: 'Message',
                            onTab: () {
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 25),
                  MyTabBar(uidProfile: currentUser!.uid),
                ],
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
