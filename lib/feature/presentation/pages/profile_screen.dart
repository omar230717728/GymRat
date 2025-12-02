import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_application_1/core/themes/app_theme.dart';
import 'package:flutter_application_1/feature/cubit/theme_cubit.dart';
import 'package:flutter_application_1/feature/cubit/language_cubit.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_application_1/core/services/data_uploader.dart';
import 'package:flutter_application_1/l10n/app_localizations.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  Map<String, dynamic>? userData;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final doc =
        await _firestore.collection('users').doc(user.uid).get();

    setState(() {
      userData = doc.data();
      _loading = false;
    });
  }

  Future<void> _editField({
    required String title,
    required String initialValue,
    required String field,
  }) async {
    final controller = TextEditingController(text: initialValue);

    await showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.editTitle(title)),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(hintText: "Enter new $title"),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(AppLocalizations.of(context)!.cancel),
            ),
            ElevatedButton(
              onPressed: () async {
                final newValue = controller.text.trim();
                if (newValue.isNotEmpty) {
                  await _firestore
                      .collection('users')
                      .doc(_auth.currentUser!.uid)
                      .update({field: newValue});

                  setState(() {
                    userData?[field] = newValue;
                  });
                }
                Navigator.pop(context);
              },
              child: Text(AppLocalizations.of(context)!.save),
            )
          ],
        );
      },
    );
  }

  Future<void> _logout() async {
    await _auth.signOut();
    Navigator.pop(context); // return to previous screen
  }

  Future<void> _pickAndUploadImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() => _loading = true);
      try {
        final file = File(pickedFile.path);
        final ref = FirebaseStorage.instance
            .ref()
            .child('user_avatars')
            .child('${_auth.currentUser!.uid}.jpg');

        await ref.putFile(file);
        final url = await ref.getDownloadURL();

        await _auth.currentUser!.updatePhotoURL(url);
        await _firestore.collection('users').doc(_auth.currentUser!.uid).update({
          'photoURL': url,
        });

        setState(() {
          _loading = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.profilePictureUpdated)),
        );
      } catch (e) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.errorUploadingImage(e.toString()))),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_loading || userData == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final createdAt = (userData!['createdAt'] as Timestamp?)?.toDate();
    final joined = createdAt != null
        ? "${createdAt.day}/${createdAt.month}/${createdAt.year}"
        : "Unknown";

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ---------- AVATAR + NAME ----------
              GestureDetector(
                onTap: _pickAndUploadImage,
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 45,
                      backgroundColor: theme.colorScheme.primary,
                      child: CircleAvatar(
                        radius: 42,
                        backgroundImage: _auth.currentUser?.photoURL != null
                            ? NetworkImage(_auth.currentUser!.photoURL!)
                            : const AssetImage("assets/images/avatar.png")
                                as ImageProvider,
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.camera_alt, size: 16, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: Text(
                      userData!['name'] ?? "No Name",
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 6),
                  InkWell(
                    onTap: () => _editField(
                      title: "Name",
                      initialValue: userData!['name'] ?? "",
                      field: "name",
                    ),
                    child: Icon(Icons.edit,
                        size: 20, color: theme.colorScheme.primary),
                  )
                ],
              ),

              const SizedBox(height: 10),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    userData!['email'] ?? "",
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: () => _editField(
                      title: "Email",
                      initialValue: userData!['email'] ?? "",
                      field: "email",
                    ),
                    child: Icon(Icons.edit,
                        size: 18, color: theme.colorScheme.primary),
                  )
                ],
              ),

              const SizedBox(height: 20),

              // ---------- STATS DASHBOARD ----------
              _buildStatsSection(theme, joined),

              const SizedBox(height: 25),

              // ---------- THEME SELECTOR ----------
              _buildThemeSelector(context),

              const SizedBox(height: 25),

              // ---------- LANGUAGE SELECTOR ----------
              _buildLanguageSelector(context),

              const SizedBox(height: 30),

              // ---------- LOGOUT ----------
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _logout,
                  child: Text(AppLocalizations.of(context)!.logout),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsSection(ThemeData theme, String joinedDate) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(AppLocalizations.of(context)!.recentProgress,
            style: theme.textTheme.bodyLarge
                ?.copyWith(fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildStatCard(AppLocalizations.of(context)!.favorites, "${userData!['favoritesCount'] ?? 0}",
                Icons.favorite, theme),
            _buildStatCard(AppLocalizations.of(context)!.totalWorkouts, "0", Icons.fitness_center, theme),
            _buildStatCard(AppLocalizations.of(context)!.weeklyStreak, "🔥 0", Icons.local_fire_department, theme),
          ],
        ),

        const SizedBox(height: 16),

        Text(
          "Joined: $joinedDate",
          style:
              theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, ThemeData theme) {
    return Container(
      width: 100,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withOpacity(0.18),
            blurRadius: 8,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: theme.colorScheme.primary, size: 28),
          const SizedBox(height: 6),
          Text(value,
              style: theme.textTheme.bodyLarge
                  ?.copyWith(fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 4),
          Text(title, style: theme.textTheme.bodyMedium),
        ],
      ),
    );
  }

  Widget _buildThemeSelector(BuildContext context) {
    final themeCubit = context.watch<ThemeCubit>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.theme,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),

        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _themeButton(context, "Green", AppTheme.green,
                themeCubit.state.currentTheme == AppTheme.green),
            _themeButton(context, "Red", AppTheme.red,
                themeCubit.state.currentTheme == AppTheme.red),
            _themeButton(context, "Blue", AppTheme.blue,
                themeCubit.state.currentTheme == AppTheme.blue),
            _themeButton(context, "Purple", AppTheme.purple,
                themeCubit.state.currentTheme == AppTheme.purple),
            _themeButton(context, "Orange", AppTheme.orange,
                themeCubit.state.currentTheme == AppTheme.orange),
            _themeButton(context, "Neon", AppTheme.darkNeon,
                themeCubit.state.currentTheme == AppTheme.darkNeon),
          ],
        ),
        const SizedBox(height: 20),
        Center(
          child: TextButton(
            onPressed: () async {
              await DataUploader().uploadData();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(AppLocalizations.of(context)!.dataUploaded)),
              );
            },
            child: Text(AppLocalizations.of(context)!.seedData),
          ),
        ),
      ],
    );
  }

  Widget _buildLanguageSelector(BuildContext context) {
    final languageCubit = context.watch<LanguageCubit>();
    final currentLocale = languageCubit.state.locale;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.language,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _languageButton(context, "English", const Locale('en'), currentLocale),
            _languageButton(context, "Türkçe", const Locale('tr'), currentLocale),
            _languageButton(context, "Deutsch", const Locale('de'), currentLocale),
            _languageButton(context, "العربية", const Locale('ar'), currentLocale),
            _languageButton(context, "Русский", const Locale('ru'), currentLocale),
          ],
        ),
      ],
    );
  }

  Widget _languageButton(BuildContext context, String title, Locale locale, Locale currentLocale) {
    final isSelected = locale.languageCode == currentLocale.languageCode;
    return GestureDetector(
      onTap: () {
        context.read<LanguageCubit>().changeLanguage(locale);
      },
      child: Container(
        width: 100,
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.surface,
          border: Border.all(
            color: Theme.of(context).colorScheme.primary,
            width: 2,
          ),
        ),
        child: Center(
          child: Text(
            title,
            style: TextStyle(
              color: isSelected
                  ? Theme.of(context).colorScheme.onPrimary
                  : Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }

  Widget _themeButton(BuildContext context, String title, AppTheme theme,
      bool isSelected) {
    return GestureDetector(
      onTap: () {
        context.read<ThemeCubit>().changeTheme(theme);
      },
      child: Container(
        width: 140,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.surface,
          border: Border.all(
            color: Theme.of(context).colorScheme.primary,
            width: 2,
          ),
        ),
        child: Center(
          child: Text(
            title,
            style: TextStyle(
              color: isSelected
                  ? Theme.of(context).colorScheme.onPrimary
                  : Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
