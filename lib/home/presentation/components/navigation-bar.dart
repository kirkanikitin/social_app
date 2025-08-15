import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:social_app/features/post/presentation/pages/upload-post-page.dart';
import 'package:social_app/features/profile/presentation/pages/profile-page.dart';
import 'package:social_app/home/presentation/pages/home-page.dart';
import '../../../features/auth/presentation/cubits/auth_cubit.dart';
import '../../../features/profile/presentation/cubits/profile-cubit.dart';
import '../../../features/profile/presentation/cubits/profile-states.dart';

class HomeNavBar extends StatefulWidget {
  @override
  _HomeNavBarState createState() => _HomeNavBarState();
}

class _HomeNavBarState extends State<HomeNavBar> {
  late PersistentTabController _controller;

  @override
  void initState() {
    super.initState();
    _controller = PersistentTabController(initialIndex: 0);
  }

  List<PersistentBottomNavBarItem> _navBarsItems() {
    return [
      PersistentBottomNavBarItem(
        icon: Icon(Icons.home_filled),
        iconSize: 30,
        title: ("Home"),
        activeColorPrimary: Colors.black87,
        inactiveColorPrimary: Colors.black54,
      ),
      PersistentBottomNavBarItem(
        icon: Icon(Icons.search),
        iconSize: 30,
        title: ("Search"),
        activeColorPrimary: Colors.black87,
        inactiveColorPrimary: Colors.black54,
      ),
      PersistentBottomNavBarItem(
        icon: Icon(Icons.add),
        iconSize: 30,
        title: ("To Create"),
        activeColorPrimary: Colors.black87,
        inactiveColorPrimary: Colors.black54,
      ),
      PersistentBottomNavBarItem(
        icon: Icon(Icons.person_outline),
        iconSize: 30,
        title: ("Profile"),
        activeColorPrimary: Colors.black87,
        inactiveColorPrimary: Colors.black54,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final user = context.read<AuthCubit>().currentUser;
    String? uid = user!.uid;

    List<Widget> _buildScreens() {
      return [
        HomePage(controller: _controller,),
        const Placeholder(),
        Container(),
        ProfilePage(uid: uid ?? 'unknown'),
      ];
    }
    return PersistentTabView(
      context,
      controller: _controller,
      screens: _buildScreens(),
      items: _navBarsItems(),
      isVisible: true,
      decoration: NavBarDecoration(
        border: Border.all(color: Colors.grey.shade300)
      ),
      onItemSelected: (index) async {
        if (index == 2) {
          await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => UploadPostPage(
                onPostUploaded: () {
                  _controller.index = 0;
                },
              ),
            ),
          );
          _controller.index = 0;
        } else if (index == 3) {
          final profileCubit = context.read<ProfileCubit>();
          final uid = context
              .read<AuthCubit>()
              .currentUser!
              .uid;

          if (profileCubit.state is! ProfileLoaded ||
              (profileCubit.state as ProfileLoaded).profileUser.uid != uid) {
            profileCubit.fetchUserProfile(uid, forceRefresh: true);
          }
        } else {
          setState(() {
            _controller.index = index;
          });
        }
      },
      handleAndroidBackButtonPress: true, // Default is true.
      resizeToAvoidBottomInset: true, // This needs to be true if you want to move up the screen on a non-scrollable screen when keyboard appears. Default is true.
      stateManagement: true, // Default is true.
      hideNavigationBarWhenKeyboardAppears: true,
      padding: const EdgeInsets.only(top: 15),
      backgroundColor: Colors.grey.shade100,
      animationSettings: const NavBarAnimationSettings(
        navBarItemAnimation: ItemAnimationSettings( // Navigation Bar's items animation properties.
          duration: Duration(milliseconds: 400),
          curve: Curves.ease,
        ),
        screenTransitionAnimation: ScreenTransitionAnimationSettings( // Screen transition animation on change of selected tab.
          animateTabTransition: true,
          duration: Duration(milliseconds: 200),
          screenTransitionAnimationType: ScreenTransitionAnimationType.slide,
        ),
      ),
      confineToSafeArea: true,
      navBarHeight: kBottomNavigationBarHeight,
      navBarStyle: NavBarStyle.style12,
    );
  }
}






