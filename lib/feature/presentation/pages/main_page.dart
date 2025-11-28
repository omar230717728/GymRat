import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/auth/login_required_popup.dart';
import 'package:flutter_application_1/feature/presentation/pages/favorite_screen.dart';
import 'package:flutter_application_1/feature/presentation/pages/gym_parts_home.dart';
import 'package:flutter_application_1/feature/presentation/pages/profile_screen.dart';
import 'package:flutter_application_1/feature/presentation/pages/search_screen.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;
  final GlobalKey<NavigatorState> _homeNavigatorKey =
      GlobalKey<NavigatorState>();

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      _buildHomeNavigator(),
      SearchScreen(),
      SafeArea(child: FavoritesScreen()),
      ProfileScreen(),
    ];
  }

  Widget _buildHomeNavigator() {
    return Navigator(
      key: _homeNavigatorKey,
      onGenerateRoute: (settings) {
        return MaterialPageRoute(builder: (context) => GymPartScreen());
      },
      onPopPage: (route, result) {
        // Handle back button - pop from nested navigator first
        if (!route.didPop(result)) {
          return false;
        }
        return true;
      },
    );
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      extendBodyBehindAppBar: true,
      extendBody:
          true, // ← ADD THIS LINE - allows body to extend behind navigation bar
      appBar: _buildAppBar(),
      body: WillPopScope(
        onWillPop: () async {
          // If we're on home tab and nested navigator can go back
          if (_selectedIndex == 0 &&
              _homeNavigatorKey.currentState?.canPop() == true) {
            _homeNavigatorKey.currentState?.pop();
            return false;
          }
          // For other tabs or when can't go back, let app quit
          return true;
        },
        child: Stack(
          children: [
            _screens[_selectedIndex],
            Positioned(
              left: 16,
              right: 16,
              bottom: 16,
              child: _buildBottomNavBar(),
            ),
          ],
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      actions: [
        Container(
          margin: EdgeInsets.only(right: 8.0),
          padding: EdgeInsets.all(3.0),
          child: IconButton(onPressed: () {}, icon: Icon(Icons.search)),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(17),
            color: Theme.of(context).colorScheme.surface.withOpacity(0.9),
          ),
        ),
        Container(
          margin: EdgeInsets.only(right: 8.0),
          padding: EdgeInsets.all(3.0),
          child: IconButton(onPressed: () {}, icon: Icon(Icons.settings)),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(17),
            color: Theme.of(context).colorScheme.surface.withOpacity(0.9),
          ),
        ),
      ],
      title: Text(
        "GymRat",
        style: TextStyle(
          color: Theme.of(context).colorScheme.onBackground,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
      leading: Container(
        padding: EdgeInsets.all(5.0),
        margin: EdgeInsets.only(left: 8.0),
        child: CircleAvatar(
          radius: 21,
          backgroundColor: Theme.of(context).colorScheme.primary,
          child: CircleAvatar(
            radius: 17,
            backgroundImage: NetworkImage(
              "https://i.imgur.com/BoN9kdC.png", // placeholder profile photo
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavBar() {
    return SafeArea(
      top: false,
      left: false,
      right: false,
      bottom: true,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(31),
        child: Container(
          color: Theme.of(context).colorScheme.primary, // Transparent gray bar
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 7, vertical: 4),
            child: GNav(
              gap: 8,
              color: Colors.white,
              activeColor: Theme.of(context).colorScheme.primary,
              iconSize: 24,
              tabBackgroundColor: Color(0xFF282A2C).withOpacity(0.9),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 19),
              selectedIndex: _selectedIndex,
              onTabChange: (index) {
                final user = FirebaseAuth.instance.currentUser;

                // favorites = index 2, profile = index 3
                if ((index == 2 || index == 3) && user == null) {
                  showLoginRequiredPopup(context);
                  return; // stop navigation
                }

                setState(() {
                  _selectedIndex = index;
                });
              },

              tabs: const [
                GButton(icon: Icons.home, text: 'Home'),
                GButton(icon: Icons.search, text: 'Search'),
                GButton(icon: Icons.favorite, text: 'Favorites'),
                GButton(icon:  Icons.show_chart, text: 'Progress'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
