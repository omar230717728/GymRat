import 'package:flutter/material.dart';


class ProfileSidebar extends StatelessWidget {
  final bool isOpen;
  final VoidCallback onClose;
  // User Data
  final String name;
  final String email;
  final String? avatarUrl;
  // Stats
  final String weight;
  final String height;
  final String age;
  // Account Info
  final String username;
  final String joinedDate;
  // Callbacks
  final VoidCallback? onEditProfile;
  final VoidCallback? onSettingsTap;

  const ProfileSidebar({
    super.key,
    required this.isOpen,
    required this.onClose,
    required this.name,
    required this.email,
    this.avatarUrl,
    this.weight = "77 kg", // Placeholder default
    this.height = "180 cm", // Placeholder default
    this.age = "24", // Placeholder default
    required this.username,
    required this.joinedDate,
    this.onEditProfile,
    this.onSettingsTap,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final sidebarWidth = screenWidth * 0.85;

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
          right: isOpen ? 0 : -sidebarWidth - 20,
          top: 0,
          bottom: 0,
          width: sidebarWidth,
          child: Container(
             margin: const EdgeInsets.fromLTRB(0, 40, 16, 40),
             decoration: BoxDecoration(
               color: const Color(0xFF0E0E0E), // Matte Black
               borderRadius: BorderRadius.circular(30),
             ),
             child: Material(
               color: Colors.transparent,
               child: Column(
                 children: [
                   const SizedBox(height: 40),
                   // A. Avatar Section
                   _buildAvatarSection(context),
                   
                   const SizedBox(height: 30),
                   
                   // Scrollable Content
                   Expanded(
                     child: ListView(
                       padding: const EdgeInsets.symmetric(horizontal: 20),
                       children: [
                         // B. Account Info Group
                         _buildSectionTitle(context, "ACCOUNT INFO"),
                         const SizedBox(height: 10),
                         _buildAccountInfoContainer(context),
                         
                         const SizedBox(height: 30),
                         
                         // C. Body Stats
                         _buildBodyStatsRow(context),
                         
                         const SizedBox(height: 40),
                         
                         // D. Action Buttons
                         _buildActionButtons(context),
                       ],
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

  Widget _buildAvatarSection(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            // Glow
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: primaryColor.withValues(alpha: 0.6),
                    blurRadius: 60,
                    spreadRadius: -10,
                  ),
                ],
              ),
            ),
            // Avatar
            Container(
              padding: const EdgeInsets.all(3), // Border width
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: primaryColor, width: 2),
              ),
              child: CircleAvatar(
                radius: 50,
                backgroundColor: Colors.grey[800],
                backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl!) : null,
                child: avatarUrl == null
                    ? Text(
                        name.isNotEmpty ? name[0].toUpperCase() : '?',
                        style: const TextStyle(fontSize: 30, color: Colors.white),
                      )
                    : null,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          name,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          email,
          style: TextStyle(
            color: Colors.grey[500],
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: TextStyle(
        color: Theme.of(context).colorScheme.primary,
        fontSize: 12,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildAccountInfoContainer(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF141414),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05), width: 1),
      ),
      child: Column(
        children: [
          _buildInfoRow(context, Icons.person_outline, "Username", username),
          _buildInfoRow(context, Icons.email_outlined, "Email", email),
          _buildInfoRow(context, Icons.calendar_today_outlined, "Joined", joinedDate),
        ],
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
          ),
          const SizedBox(width: 16),
          Text(
            label,
            style: TextStyle(color: Colors.grey[400], fontSize: 14),
          ),
          const Spacer(),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBodyStatsRow(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _buildStatCard(context, "Weight", weight)),
        const SizedBox(width: 12),
        Expanded(child: _buildStatCard(context, "Height", height)),
        const SizedBox(width: 12),
        Expanded(child: _buildStatCard(context, "Age", age)),
      ],
    );
  }

  Widget _buildStatCard(BuildContext context, String label, String fullValue) {
    // Split value and unit (e.g., "77 kg" -> "77", "kg")
    String value = fullValue;
    String unit = "";
    if (fullValue.contains(" ")) {
      final parts = fullValue.split(" ");
      value = parts[0];
      unit = parts.sublist(1).join(" ");
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                ),
              ),
              if (unit.isNotEmpty) ...[
                const SizedBox(width: 4),
                Text(
                  unit,
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: onEditProfile,
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
            child: const Text(
              "Edit Profile",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: onSettingsTap,
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              side: const BorderSide(color: Colors.white24, width: 1.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Text(
              "Settings",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }
}
