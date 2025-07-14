import 'package:flutter/material.dart';
import 'package:social_app/features/profile/presentation/pages/post.dart';

class MyTabBar extends StatefulWidget {
  const MyTabBar({super.key});

  @override
  State<MyTabBar> createState() => _MyTabBarState();
}

class _MyTabBarState extends State<MyTabBar>
  with SingleTickerProviderStateMixin {
  late TabController controller;

  @override
  void initState() {
    super.initState();
    controller = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TabBar(
          controller: controller,
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
              icon: Icon(
                Icons.grid_on,
                size: 30,
              ),
            ),
            Tab(
              icon: Icon(
                Icons.play_circle_outlined,
                size: 30,
              ),
            ),
            Tab(
              icon: Icon(
                Icons.person_pin_sharp,
                size: 30,
              ),
            ),
          ],
        ),
        SizedBox(
          width: double.maxFinite,
          height: 300,
          child: TabBarView(
            controller: controller,
            children:  const [
              MyPost(),
              Center(
                child: Text(
                  'Cтраница на стадии разработки))',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ),
              Center(
                child: Text(
                  'Cтраница на стадии разработки))',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
