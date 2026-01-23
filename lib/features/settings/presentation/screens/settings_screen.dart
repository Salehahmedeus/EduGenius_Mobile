import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../../../auth/data/services/auth_service.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/theme_manager.dart';
import '../../../../core/widgets/custom_snackbar.dart';
import '../../../../routes.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isLoggingOut = false;
  final AuthService _authService = AuthService();

  Future<void> _handleLogout() async {
    if (_isLoggingOut) return;

    setState(() => _isLoggingOut = true);

    try {
      await _authService.logout();

      if (mounted) {
        CustomSnackbar.showSuccess(context, 'Logged out successfully');
        Navigator.pushNamedAndRemoveUntil(
          context,
          Routes.welcome,
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        CustomSnackbar.showError(context, e.toString());
      }
    } finally {
      if (mounted) setState(() => _isLoggingOut = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark(context);

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            children: [
              // Header with Edit button
              _buildHeader(isDark),
              const SizedBox(height: 30),

              // Group 1: Academic Profile
              _buildGroupTitle(isDark, 'Academic Profile'),
              _buildGroupContainer(isDark, [
                _buildSettingItem(
                  isDark,
                  icon: Iconsax.teacher,
                  iconBg: const Color(0xFF246BFD),
                  title: 'Study Level',
                  trailing: _buildBadge('University'),
                  onTap: () {},
                ),
                _buildDivider(isDark),
                _buildSettingItem(
                  isDark,
                  icon: Iconsax.book_1,
                  iconBg: const Color(0xFF47D16E),
                  title: 'My Subjects',
                  onTap: () {},
                ),
              ]),
              const SizedBox(height: 24),

              // Group 2: AI Tutor Preferences
              _buildGroupTitle(isDark, 'AI Tutor Preferences'),
              _buildGroupContainer(isDark, [
                _buildSettingItem(
                  isDark,
                  icon: Iconsax.status_up,
                  iconBg: const Color(0xFF9145FF),
                  title: 'Response Style',
                  trailing: _buildBadge('Detailed'),
                  onTap: () {},
                ),
                _buildDivider(isDark),
                _buildSettingItem(
                  isDark,
                  icon: Iconsax.volume_high,
                  iconBg: const Color(0xFFFF981F),
                  title: 'Tutor Voice',
                  onTap: () {},
                ),
              ]),
              const SizedBox(height: 24),

              // Group 3: App Settings
              _buildGroupTitle(isDark, 'App Settings'),
              _buildGroupContainer(isDark, [
                _buildSettingItem(
                  isDark,
                  icon: Iconsax.notification,
                  iconBg: const Color(0xFFACACAE),
                  title: 'Notifications',
                  onTap: () {},
                ),
                _buildDivider(isDark),
                _buildSettingItem(
                  isDark,
                  icon: Iconsax.global,
                  iconBg: const Color(0xFF246BFD),
                  title: 'Language',
                  trailing: _buildBadge('English'),
                  onTap: () {},
                ),
                _buildDivider(isDark),
                _buildSettingItem(
                  isDark,
                  icon: Iconsax.colorfilter,
                  iconBg: const Color(0xFF47D16E),
                  title: 'Appearance',
                  trailing: ValueListenableBuilder<ThemeMode>(
                    valueListenable: themeManager,
                    builder: (context, mode, _) {
                      return Switch(
                        value: mode == ThemeMode.dark,
                        onChanged: (val) => themeManager.toggleTheme(),
                        activeThumbColor: AppColors.white,
                        activeTrackColor: AppColors.success,
                      );
                    },
                  ),
                  onTap: () {},
                ),
              ]),
              const SizedBox(height: 24),

              // Group 4: Account & Support
              _buildGroupTitle(isDark, 'Support'),
              _buildGroupContainer(isDark, [
                _buildSettingItem(
                  isDark,
                  icon: Iconsax.info_circle,
                  iconBg: const Color(0xFFACACAE),
                  title: 'Help Center',
                  onTap: () {},
                ),
                _buildDivider(isDark),
                _buildSettingItem(
                  isDark,
                  icon: Iconsax.logout,
                  iconBg: const Color(0xFFF75555),
                  title: 'Log Out',
                  trailing: _isLoggingOut
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : null,
                  onTap: _handleLogout,
                ),
              ]),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: () {},
              child: const Text(
                'Edit',
                style: TextStyle(
                  color: AppColors.secondary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        CircleAvatar(
          radius: 60,
          backgroundColor: isDark
              ? AppColors.darkItem
              : const Color(0xFFE5E7EB),
          backgroundImage: const NetworkImage(
            'https://api.dicebear.com/7.x/avataaars/png?seed=Zachery&backgroundColor=b6e3f4',
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Zachery Williamson',
          style: TextStyle(
            color: isDark ? AppColors.darkTextPrimary : const Color(0xFF1F2937),
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'zachery.williamson94@gmail.com',
          style: TextStyle(
            color: isDark
                ? AppColors.darkTextSecondary
                : const Color(0xFF6B7280),
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildGroupTitle(bool isDark, String title) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          color: isDark ? AppColors.darkTextSecondary : const Color(0xFF6B7280),
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildGroupContainer(bool isDark, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : const Color(0xFFE5E7EB),
        ),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildDivider(bool isDark) {
    return Divider(
      height: 1,
      thickness: 1,
      color: isDark ? AppColors.darkBorder : const Color(0xFFE5E7EB),
      indent: 60,
      endIndent: 16,
    );
  }

  Widget _buildSettingItem(
    bool isDark, {
    required IconData icon,
    required Color iconBg,
    required String title,
    Widget? trailing,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: iconBg,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isDark ? AppColors.darkTextPrimary : const Color(0xFF1F2937),
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing:
          trailing ??
          Icon(
            Iconsax.arrow_right_3,
            color: isDark
                ? AppColors.darkTextSecondary
                : const Color(0xFFD1D5DB),
            size: 18,
          ),
    );
  }

  Widget _buildBadge(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 4),
          const Icon(Iconsax.arrow_right_3, color: AppColors.primary, size: 14),
        ],
      ),
    );
  }
}
