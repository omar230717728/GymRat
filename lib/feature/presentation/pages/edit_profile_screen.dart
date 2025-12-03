import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_application_1/core/models/user_model.dart';
import 'package:flutter_application_1/core/services/user_session_service.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _nameController;
  late TextEditingController _usernameController;
  late TextEditingController _emailController;
  late TextEditingController _weightController;
  late TextEditingController _heightController;
  late TextEditingController _ageController;

  bool _isLoading = false;
  bool _isUploadingImage = false;

  @override
  void initState() {
    super.initState();
    final user = UserSessionService.instance.currentUser.value;
    _nameController = TextEditingController(text: user?.name ?? '');
    _usernameController = TextEditingController(text: user?.username ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
    _weightController = TextEditingController(text: user?.weight?.toString() ?? '');
    _heightController = TextEditingController(text: user?.height?.toString() ?? '');
    _ageController = TextEditingController(text: user?.age?.toString() ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  Future<void> _pickAndUploadImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() => _isUploadingImage = true);
      try {
        final file = File(pickedFile.path);
        final userId = FirebaseAuth.instance.currentUser?.uid;
        if (userId == null) return;

        final ref = FirebaseStorage.instance
            .ref()
            .child('user_avatars')
            .child('$userId.jpg');

        await ref.putFile(file);
        final url = await ref.getDownloadURL();

        await UserSessionService.instance.updateUserProfile(photoURL: url);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile picture updated')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error uploading image: $e')),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isUploadingImage = false);
        }
      }
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await UserSessionService.instance.updateUserProfile(
        name: _nameController.text.trim(),
        username: _usernameController.text.trim(),
        // Email is usually not editable directly here without re-auth, 
        // but we'll pass it if changed (UserSessionService handles it)
        // For now, we kept it read-only in UI logic below, but controller has text.
        weight: int.tryParse(_weightController.text.trim()),
        height: int.tryParse(_heightController.text.trim()),
        age: int.tryParse(_ageController.text.trim()),
      );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating profile: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Matte Black Background
    return Scaffold(
      backgroundColor: const Color(0xFF0E0E0E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0E0E0E),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Edit Profile",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: ValueListenableBuilder<UserModel?>(
        valueListenable: UserSessionService.instance.currentUser,
        builder: (context, user, _) {
          if (user == null) return const Center(child: CircularProgressIndicator());

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  // 1. Avatar Section
                  Center(
                    child: GestureDetector(
                      onTap: _pickAndUploadImage,
                      child: Stack(
                        children: [
                          // Glow
                          Container(
                            width: 110,
                            height: 110,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
                                  blurRadius: 50,
                                  spreadRadius: -5,
                                ),
                              ],
                            ),
                          ),
                          // Avatar
                          CircleAvatar(
                            radius: 55,
                            backgroundColor: Colors.grey[800],
                            backgroundImage: user.photoURL != null
                                ? NetworkImage(user.photoURL!)
                                : null,
                            child: user.photoURL == null
                                ? Text(
                                    user.name?.isNotEmpty == true ? user.name![0].toUpperCase() : '?',
                                    style: const TextStyle(fontSize: 40, color: Colors.white),
                                  )
                                : null,
                          ),
                          // Loading Indicator
                          if (_isUploadingImage)
                            const Positioned.fill(
                              child: CircularProgressIndicator(),
                            ),
                          // Camera Icon
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primary,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.black, width: 2),
                              ),
                              child: const Icon(Icons.camera_alt, size: 16, color: Colors.black),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 40),

                  // 2. Form Fields
                  _buildTextField("FULL NAME", _nameController),
                  const SizedBox(height: 20),
                  
                  _buildTextField("EMAIL", _emailController, readOnly: true),
                  const SizedBox(height: 20),
                  
                  _buildTextField("USERNAME", _usernameController),
                  const SizedBox(height: 20),

                  // 3. Stats Row
                  Row(
                    children: [
                      Expanded(child: _buildTextField("HEIGHT (CM)", _heightController, isNumber: true)),
                      const SizedBox(width: 16),
                      Expanded(child: _buildTextField("WEIGHT (KG)", _weightController, isNumber: true)),
                      const SizedBox(width: 16),
                      Expanded(child: _buildTextField("AGE", _ageController, isNumber: true)),
                    ],
                  ),
                  
                  const SizedBox(height: 30),

                  // 4. Joined Date Badge
                  _buildJoinedDateBadge(user.joinDate),

                  const SizedBox(height: 50),

                  // 5. Save Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _saveProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.black)
                          : const Text(
                              "Save Changes",
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {bool readOnly = false, bool isNumber = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[500],
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF141414),
            borderRadius: BorderRadius.circular(16),
          ),
          child: TextFormField(
            controller: controller,
            readOnly: readOnly,
            keyboardType: isNumber ? TextInputType.number : TextInputType.text,
            style: TextStyle(
              color: readOnly ? Colors.grey[500] : Colors.white,
              fontWeight: FontWeight.w500,
            ),
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildJoinedDateBadge(DateTime? date) {
    final dateStr = date != null 
        ? "${date.day}/${date.month}/${date.year}" 
        : "Unknown";

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      decoration: BoxDecoration(
        color: const Color(0xFF141414).withValues(alpha: 0.5), // Lower opacity
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Row(
        children: [
          Icon(Icons.calendar_today, color: Colors.grey[600], size: 20),
          const SizedBox(width: 12),
          Text(
            "Joined: $dateStr",
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
