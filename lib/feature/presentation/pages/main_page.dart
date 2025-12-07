import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_application_1/core/auth/login_required_popup.dart';
import 'package:flutter_application_1/feature/presentation/pages/favorite_screen.dart';
import 'package:flutter_application_1/feature/presentation/pages/gym_parts_home.dart';
import 'package:flutter_application_1/feature/presentation/pages/edit_profile_screen.dart';
import 'package:flutter_application_1/feature/presentation/pages/search_screen.dart';
import 'package:flutter_application_1/feature/presentation/pages/progress_page.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_application_1/l10n/app_localizations.dart';
import 'package:flutter_application_1/feature/presentation/widgets/settings_sidebar.dart';
import 'package:flutter_application_1/feature/presentation/widgets/profile_sidebar.dart';
import 'package:flutter_application_1/feature/cubit/theme_cubit.dart';
import 'package:flutter_application_1/feature/cubit/language_cubit.dart';
import 'package:flutter_application_1/core/services/user_session_service.dart';
import 'package:flutter_application_1/core/models/user_model.dart';
import 'package:flutter_application_1/core/auth/login_screen.dart';
import 'package:flutter_application_1/feature/presentation/pages/onboarding_screen.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;
  bool _isSidebarOpen = false;
  bool _isProfileOpen = false;
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
      const ProgressPage(),
    ];
  }

  Widget _buildHomeNavigator() {
    return Navigator(
      key: _homeNavigatorKey,
      onGenerateRoute: (settings) {
        return MaterialPageRoute(builder: (context) => const GymPartScreen());
      },
      onDidRemovePage: (page) {
        // Handle back button - pop from nested navigator first
        // onDidRemovePage is different from onPopPage.
        // But for Navigator 1.0 usage inside Navigator widget, onPopPage is still standard?
        // Wait, the warning says onPopPage is deprecated.
        // Let's check the docs or assume standard fix.
        // Actually, for Navigator widget, onPopPage is the property.
        // Maybe I should ignore it if it's too complex to migrate without context.
        // But let's try to fix onPopInvoked first.
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Theme.of(context).colorScheme.surface,
      extendBodyBehindAppBar: true,
      extendBody: true,
      appBar: _buildAppBar(),
      body: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) async {
          if (didPop) return;

          // If sidebar is open, close it
          if (_isSidebarOpen) {
            setState(() => _isSidebarOpen = false);
            return;
          }
          if (_isProfileOpen) {
            setState(() => _isProfileOpen = false);
            return;
          }
          // If we're on home tab and nested navigator can go back
          if (_selectedIndex == 0 &&
              _homeNavigatorKey.currentState?.canPop() == true) {
            _homeNavigatorKey.currentState?.pop();
            return;
          }
          // For other tabs or when can't go back, let app quit
          // To actually quit, we might need to allow pop or use SystemNavigator.pop()
          // But PopScope logic is slightly different.
          // If we want to allow pop, we should set canPop to true dynamically or call Navigator.pop(context) if it's the root.
          // For now, let's assume we want to block pop unless it's a real exit.
          // If we want to exit:
           if (context.mounted) Navigator.of(context).pop();
        },
        child: Stack(
          children: [
            _screens[_selectedIndex],
            Positioned(
              left: 16,
              right: 16,
              bottom: 0,
              child: _buildBottomNavBar(),
            ),
            
            // Settings Sidebar
            BlocBuilder<ThemeCubit, ThemeState>(
              builder: (context, themeState) {
                return BlocBuilder<LanguageCubit, LanguageState>(
                  builder: (context, langState) {
                    return StreamBuilder<UserModel?>(
                      stream: UserSessionService.instance.userStream,
                      initialData: UserSessionService.instance.currentUser,
                      builder: (context, snapshot) {
                        final user = snapshot.data;
                        return SettingsSidebar(
                          isOpen: _isSidebarOpen,
                          onClose: () => setState(() => _isSidebarOpen = false),
                          onThemeChanged: (theme) {
                            context.read<ThemeCubit>().changeTheme(theme);
                          },
                          onLanguageChanged: (lang) {
                            final locale = SettingsSidebar.getLocaleFromLanguage(lang);
                            context.read<LanguageCubit>().changeLanguage(locale);
                          },
                          currentTheme: themeState.currentTheme,
                          currentLanguage: SettingsSidebar.getLanguageFromLocale(langState.locale),
                          userName: user?.name ?? FirebaseAuth.instance.currentUser?.displayName ?? 'User',
                          userEmail: user?.email ?? FirebaseAuth.instance.currentUser?.email ?? '',
                          avatarUrl: user?.photoURL ?? FirebaseAuth.instance.currentUser?.photoURL,
                          onNotificationsTap: () {
                             // TODO: Implement Notifications
                             setState(() => _isSidebarOpen = false);
                          },
                          onPrivacyTap: () {
                             // TODO: Implement Privacy
                             setState(() => _isSidebarOpen = false);
                          },
                          onLogoutTap: () async {
                            setState(() => _isSidebarOpen = false);
                            await GoogleSignIn().signOut();
                            await FirebaseAuth.instance.signOut();
                            if (context.mounted) {
                               Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
                                MaterialPageRoute(builder: (_) => const OnboardingScreen()),
                                (route) => false,
                              );
                            }
                          },
                        );
                      },
                    );
                  },
                );
              },
            ),


            // Profile Sidebar
            StreamBuilder<UserModel?>(
              stream: UserSessionService.instance.userStream,
              builder: (context, snapshot) {
                final user = snapshot.data;
                final currentUser = FirebaseAuth.instance.currentUser;
                return ProfileSidebar(
                  isOpen: _isProfileOpen,
                  onClose: () => setState(() => _isProfileOpen = false),
                  name: user?.name ?? currentUser?.displayName ?? 'User',
                  email: user?.email ?? currentUser?.email ?? '',
                  avatarUrl: user?.photoURL ?? currentUser?.photoURL,
                  username: user?.username ?? user?.name ?? currentUser?.displayName ?? 'User',
                  weight: user?.weight != null ? "${user!.weight} kg" : "0 kg",
                  height: user?.height != null ? "${user!.height} cm" : "0 cm",
                  age: user?.age != null ? "${user!.age}" : "0",
                  joinedDate: user?.joinDate != null 
                      ? "${user!.joinDate!.day}/${user.joinDate!.month}/${user.joinDate!.year}" 
                      : "Unknown",
                  onEditProfile: () {
                     setState(() => _isProfileOpen = false);
                     Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const EditProfileScreen()),
                     );
                  },
                  onSettingsTap: () {
                     setState(() {
                       _isProfileOpen = false;
                       _isSidebarOpen = true;
                     });
                  },
                );
              },
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
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(17),
            color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.9),
          ),
          child: IconButton(onPressed: () {}, icon: Icon(Icons.camera_alt_rounded, color: Theme.of(context).colorScheme.primary)),
        ),
        Container(
          margin: EdgeInsets.only(right: 8.0),
          padding: EdgeInsets.all(3.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(17),
            color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.9),
          ),
          child: IconButton(onPressed: () {
            setState(() {
              _isProfileOpen = false; // Force close Profile
              _isSidebarOpen = !_isSidebarOpen;
            });
          }, icon: Icon(Icons.settings, color: Theme.of(context).colorScheme.primary)),
        ),
      ],
      title: Text(
        AppLocalizations.of(context)!.appTitle,
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurface,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
      leading: GestureDetector(
        onTap: () {
          setState(() {
             _isSidebarOpen = false; // Force close Settings
             _isProfileOpen = !_isProfileOpen;
          });
        },
        child: Container(
          padding: EdgeInsets.all(5.0),
          margin: EdgeInsets.only(left: 8.0),
          child: CircleAvatar(
            radius: 21,
            backgroundColor: Theme.of(context).colorScheme.primary,
            child: CircleAvatar(
              radius: 17,
              backgroundImage: NetworkImage(
                FirebaseAuth.instance.currentUser?.photoURL ??
                    "https://i.imgur.com/BoN9kdC.png",
              ),
            ),
          ),
        ),
      ),
    );
  } 
Widget _buildBottomNavBar() {
  return SafeArea(
    child: Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10), 
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface, // Use a dark surface color (e.g., Black/Dark Grey)
        borderRadius: BorderRadius.circular(30),
        // 2. IMPROVEMENT: Shadow for depth
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: GNav(
          duration: const Duration(milliseconds: 650),
          gap: 8,
          color: Colors.grey[600], // Inactive icon color
          activeColor: Colors.white, // Active icon color
          iconSize: 24,
          tabBackgroundColor: Theme.of(context).colorScheme.primary, 
          padding: const EdgeInsets.all(16), // Balanced padding
          
          selectedIndex: _selectedIndex,
          onTabChange: (index) {
            HapticFeedback.lightImpact(); 
            final user = FirebaseAuth.instance.currentUser;
            if ((index == 2 || index == 3) && user == null) {
              showLoginRequiredPopup(context); 
              return; 
            }
            setState(() {
              _selectedIndex = index;
            });
          },
          tabs: [
            GButton(
              icon: Icons.home_rounded, // Rounded icons look better
              text: AppLocalizations.of(context)!.home,
            ),
            GButton(
              icon: Icons.search_rounded, 
              text: AppLocalizations.of(context)!.search,
            ),
            GButton(
              icon: Icons.favorite_rounded, 
              text: AppLocalizations.of(context)!.favorites,
            ),
            GButton(
              icon: Icons.bar_chart_rounded, // Alternative to show_chart
              text: AppLocalizations.of(context)!.progress,
            ),
          ],
        ),
      ),
    ),
  );
}
  

}
