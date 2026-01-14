import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../core/constants/app_colors.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isDarkMode = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: Icon(
            Iconsax.profile_2user,
            color: AppColors.primary,
            size: 28,
          ),
        ),
        title: const Text(
          'Account',
          style: TextStyle(
            color: AppColors.black,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          children: [
            // Profile Section
            _buildProfileSection(),
            const SizedBox(height: 24),

            // Upgrade to PRO Banner
            _buildProBanner(),
            const SizedBox(height: 32),

            // General Section
            _buildSectionHeader('General'),
            const SizedBox(height: 8),
            _buildSettingItem(
              icon: Iconsax.user,
              title: 'Personal Info',
              onTap: () {},
            ),
            _buildSettingItem(
              icon: Iconsax.security_safe,
              title: 'Security',
              onTap: () {},
            ),
            _buildSettingItem(
              icon: Iconsax.global,
              title: 'Language',
              trailingText: 'English (US)',
              onTap: () {},
            ),
            _buildSettingItem(
              icon: Iconsax.moon1,
              title: 'Dark Mode',
              isSwitch: true,
              switchValue: _isDarkMode,
              onSwitchChanged: (val) {
                setState(() => _isDarkMode = val);
              },
              onTap: () {},
            ),

            const SizedBox(height: 24),

            // About Section
            _buildSectionHeader('About'),
            const SizedBox(height: 8),
            _buildSettingItem(
              icon: Iconsax.info_circle,
              title: 'Help Center',
              onTap: () {},
            ),
            _buildSettingItem(
              icon: Iconsax.lock,
              title: 'Privacy Policy',
              onTap: () {},
            ),
            _buildSettingItem(
              icon: Iconsax.information,
              title: 'About EduGenius',
              onTap: () {},
            ),
            _buildSettingItem(
              icon: Iconsax.logout,
              title: 'Logout',
              titleColor: AppColors.primary,
              iconColor: AppColors.primary,
              showArrow: false,
              onTap: () {
                // Handle logout
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileSection() {
    return Row(
      children: [
        CircleAvatar(
          radius: 40,
          backgroundColor: AppColors.primaryMedium,
          backgroundImage: NetworkImage('https://i.pravatar.cc/150?u=saleh'),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Saleh Ahmed',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.black,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'saleh.ahmed@example.com',
                style: TextStyle(fontSize: 14, color: AppColors.grey),
              ),
            ],
          ),
        ),
        Icon(Iconsax.arrow_right_3, color: AppColors.black, size: 20),
      ],
    );
  }

  Widget _buildProBanner() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Iconsax.star1,
              color: AppColors.warning,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Upgrade to PRO!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Enjoy all benefits without restrictions',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Iconsax.arrow_right_3, color: Colors.white, size: 24),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      children: [
        Text(
          title,
          style: TextStyle(
            color: AppColors.grey,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(child: Divider(color: Colors.grey.withOpacity(0.2))),
      ],
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    String? trailingText,
    bool isSwitch = false,
    bool? switchValue,
    Function(bool)? onSwitchChanged,
    bool showArrow = true,
    Color? titleColor,
    Color? iconColor,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: isSwitch ? null : onTap,
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: iconColor ?? AppColors.black, size: 24),
      title: Text(
        title,
        style: TextStyle(
          color: titleColor ?? AppColors.black,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
      trailing: isSwitch
          ? Switch(
              value: switchValue ?? false,
              onChanged: onSwitchChanged,
              activeColor: AppColors.primary,
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (trailingText != null)
                  Text(
                    trailingText,
                    style: const TextStyle(
                      color: AppColors.black,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                if (showArrow) ...[
                  const SizedBox(width: 8),
                  const Icon(
                    Iconsax.arrow_right_3,
                    color: AppColors.black,
                    size: 18,
                  ),
                ],
              ],
            ),
    );
  }
}
