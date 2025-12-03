import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/themes/app_theme.dart';
import 'package:flutter_application_1/feature/presentation/widgets/settings_sidebar.dart';

class SettingsSidebarDemo extends StatefulWidget {
  const SettingsSidebarDemo({super.key});

  @override
  State<SettingsSidebarDemo> createState() => _SettingsSidebarDemoState();
}

class _SettingsSidebarDemoState extends State<SettingsSidebarDemo> {
  bool _isOpen = false;
  AppTheme _currentTheme = AppTheme.green;
  AppLanguage _currentLanguage = AppLanguage.english;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Main App Content
        Scaffold(
          appBar: AppBar(
            title: const Text('Settings Sidebar Demo'),
            actions: [
              IconButton(
                icon: const Icon(Icons.settings),
                onPressed: () => setState(() => _isOpen = true),
              ),
            ],
          ),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Press the settings icon to open sidebar'),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => setState(() => _isOpen = true),
                  child: const Text('Open Settings'),
                ),
                const SizedBox(height: 20),
                Text('Current Theme: ${_currentTheme.name}'),
                Text('Current Language: ${_currentLanguage.name}'),
              ],
            ),
          ),
        ),

        // The Sidebar (Z-Index top)
        SettingsSidebar(
          isOpen: _isOpen,
          onClose: () => setState(() => _isOpen = false),
          onThemeChanged: (theme) {
            setState(() => _currentTheme = theme);
            // In real app, call ThemeCubit
          },
          onLanguageChanged: (lang) {
            setState(() => _currentLanguage = lang);
            // In real app, call LanguageCubit
          },
          currentTheme: _currentTheme,
          currentLanguage: _currentLanguage,
          userName: 'John Doe',
          userEmail: 'john.doe@example.com',
          // avatarUrl: 'https://via.placeholder.com/150',
          onNotificationsTap: () => print('Notifications Tapped'),
          onPrivacyTap: () => print('Privacy Tapped'),
          onLogoutTap: () => print('Logout Tapped'),
        ),
      ],
    );
  }
}
