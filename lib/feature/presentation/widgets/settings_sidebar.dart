import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/themes/app_theme.dart';
import 'package:flutter_application_1/l10n/app_localizations.dart';

enum AppLanguage {
  english,
  turkish,
  german,
  spanish,
  french,
  arabic,
}

class SettingsSidebar extends StatelessWidget {
  final bool isOpen;
  final VoidCallback onClose;
  final ValueChanged<AppTheme> onThemeChanged;
  final ValueChanged<AppLanguage> onLanguageChanged;
  final AppTheme currentTheme;
  final AppLanguage currentLanguage;
  final String userName;
  final String userEmail;
  final String? avatarUrl;
  final VoidCallback? onNotificationsTap;
  final VoidCallback? onPrivacyTap;
  final VoidCallback? onLogoutTap;

  const SettingsSidebar({
    super.key,
    required this.isOpen,
    required this.onClose,
    required this.onThemeChanged,
    required this.onLanguageChanged,
    required this.currentTheme,
    required this.currentLanguage,
    required this.userName,
    required this.userEmail,
    this.avatarUrl,
    this.onNotificationsTap,
    this.onPrivacyTap,
    this.onLogoutTap,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final sidebarWidth = screenWidth * 0.8;

    return Stack(
      children: [
        // Overlay
        AnimatedOpacity(
          duration: const Duration(milliseconds: 300),
          opacity: isOpen ? 1.0 : 0.0,
          child: IgnorePointer(
            ignoring: !isOpen,
            child: GestureDetector(
              onTap: onClose,
              child: Container(
                color: Colors.black54,
              ),
            ),
          ),
        ),

        // Sidebar
        AnimatedPositioned(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          left: isOpen ? 16 : -sidebarWidth - 20, // Hide completely offscreen
          top: 90,
          bottom: 50,
          width: sidebarWidth,
          child: Material(
            color: const Color(0xFF101010),
            borderRadius: BorderRadius.circular(24),
            elevation: 10,
            shadowColor: Colors.black.withValues(alpha: 0.5),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Column(
                children: [
                  // Header / Close Button
                  // Removed as per user request (toggle via settings icon instead)
                  SizedBox(height: 24), // Add some top padding instead

                  // Scrollable Content
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      children: [
                        // Profile Section
                        _buildProfileSection(),
                        const SizedBox(height: 24),
                        const Divider(color: Color(0xFF333333), thickness: 1),
                        const SizedBox(height: 24),

                        // Theme Section
                        _ExpandableSection(
                          title: AppLocalizations.of(context)!.theme,
                          icon: Icons.palette,
                          isExpanded: true,
                          themeColor: _getThemeColor(currentTheme),
                          child: _buildThemeSelector(),
                        ),
                        const SizedBox(height: 16),

                        // Language Section
                        _ExpandableSection(
                          title: AppLocalizations.of(context)!.language,
                          icon: Icons.language,
                          themeColor: _getThemeColor(currentTheme),
                          child: _buildLanguageSelector(),
                        ),
                        const SizedBox(height: 24),

                        // Action Rows
                        _buildActionRow(AppLocalizations.of(context)!.notifications, Icons.notifications_none, onNotificationsTap),
                        _buildActionRow(AppLocalizations.of(context)!.privacy, Icons.privacy_tip_outlined, onPrivacyTap),
                      ],
                    ),
                  ),

                  // Logout Button
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: onLogoutTap,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF181818),
                          foregroundColor: _getThemeColor(currentTheme),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          AppLocalizations.of(context)!.logout,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileSection() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            color: _getThemeColor(currentTheme),
            shape: BoxShape.circle,
          ),
          child: CircleAvatar(
            radius: 24,
            backgroundColor: Colors.grey[800],
            backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl!) : null,
            child: avatarUrl == null
                ? Text(
                    userName.isNotEmpty ? userName[0].toUpperCase() : '?',
                    style: const TextStyle(color: Colors.white),
                  )
                : null,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                userName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                userEmail,
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 14,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildThemeSelector() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: AppTheme.values.map((theme) {
        final isSelected = theme == currentTheme;
        return GestureDetector(
          onTap: () => onThemeChanged(theme),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _getThemeColor(theme),
              shape: BoxShape.circle,
              border: isSelected
                  ? Border.all(color: Colors.white, width: 3)
                  : null,
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: _getThemeColor(theme).withValues(alpha: 0.6),
                        blurRadius: 8,
                        spreadRadius: 2,
                      )
                    ]
                  : null,
            ),
          ),
        );
      }).toList(),
    );
  }

  Color _getThemeColor(AppTheme theme) {
    switch (theme) {
      case AppTheme.green: return const Color(0xFFB3F02E); // Neon Green
      case AppTheme.red: return Colors.redAccent;
      case AppTheme.blue: return Colors.blueAccent;
      case AppTheme.purple: return Colors.purpleAccent;
      case AppTheme.orange: return Colors.orangeAccent;
      case AppTheme.darkNeon: return Colors.cyanAccent;
    }
  }

  Widget _buildLanguageSelector() {
    final themeColor = _getThemeColor(currentTheme);
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: AppLanguage.values.map((lang) {
        final isSelected = lang == currentLanguage;
        return GestureDetector(
          onTap: () => onLanguageChanged(lang),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? themeColor : Colors.transparent, 
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected ? themeColor : Colors.grey[700]!,
              ),
            ),
            child: Text(
              _getLanguageName(lang),
              style: TextStyle(
                color: isSelected ? Colors.black : Colors.grey[400],
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 12,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  String _getLanguageName(AppLanguage lang) {
    switch (lang) {
      case AppLanguage.english: return 'English';
      case AppLanguage.turkish: return 'Türkçe';
      case AppLanguage.german: return 'Deutsch';
      case AppLanguage.spanish: return 'Español';
      case AppLanguage.french: return 'Français';
      case AppLanguage.arabic: return 'العربية';
    }
  }

  static AppLanguage getLanguageFromLocale(Locale locale) {
    switch (locale.languageCode) {
      case 'tr': return AppLanguage.turkish;
      case 'de': return AppLanguage.german;
      case 'es': return AppLanguage.spanish;
      case 'fr': return AppLanguage.french;
      case 'ar': return AppLanguage.arabic;
      default: return AppLanguage.english;
    }
  }

  static Locale getLocaleFromLanguage(AppLanguage lang) {
    switch (lang) {
      case AppLanguage.turkish: return const Locale('tr');
      case AppLanguage.german: return const Locale('de');
      case AppLanguage.spanish: return const Locale('es');
      case AppLanguage.french: return const Locale('fr');
      case AppLanguage.arabic: return const Locale('ar');
      default: return const Locale('en');
    }
  }

  Widget _buildActionRow(String title, IconData icon, VoidCallback? onTap) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFF181818),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: _getThemeColor(currentTheme), size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(color: Colors.white, fontSize: 14),
      ),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
      onTap: onTap,
    );
  }
}

class _ExpandableSection extends StatefulWidget {
  final String title;
  final IconData icon;
  final Widget child;
  final bool isExpanded;
  final Color themeColor;

  const _ExpandableSection({
    required this.title,
    required this.icon,
    required this.child,
    this.isExpanded = false,
    required this.themeColor,
  });

  @override
  State<_ExpandableSection> createState() => _ExpandableSectionState();
}

class _ExpandableSectionState extends State<_ExpandableSection> with SingleTickerProviderStateMixin {
  late bool _isExpanded;
  late AnimationController _controller;
  late Animation<double> _iconTurns;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.isExpanded;
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _iconTurns = Tween<double>(begin: 0.0, end: 0.25).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    if (_isExpanded) {
      _controller.value = 1.0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF181818),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          ListTile(
            onTap: _handleTap,
            leading: Icon(widget.icon, color: widget.themeColor, size: 20),
            title: Text(
              widget.title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            trailing: RotationTransition(
              turns: _iconTurns,
              child: const Icon(Icons.chevron_right, color: Colors.grey),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            alignment: Alignment.topCenter,
            child: _isExpanded
                ? Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: widget.child,
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}
