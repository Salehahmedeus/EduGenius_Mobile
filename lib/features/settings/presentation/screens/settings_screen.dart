import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../auth/data/services/auth_service.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/theme_manager.dart';
import '../../../../core/widgets/custom_snackbar.dart';
import '../../../../routes.dart';
import '../../../auth/data/models/user_model.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isLoggingOut = false;
  final AuthService _authService = AuthService();
  UserModel? _user;
  bool _isLoadingProfile = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final user = await _authService.getProfile();
      if (mounted) {
        setState(() {
          _user = user;
          _isLoadingProfile = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoadingProfile = false);
      }
    }
  }

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

  void _showLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.getSurface(context),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'language'.tr(),
          style: TextStyle(color: AppColors.getTextPrimary(context)),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(
                'english'.tr(),
                style: TextStyle(color: AppColors.getTextPrimary(context)),
              ),
              trailing: context.locale.languageCode == 'en'
                  ? const Icon(Iconsax.tick_circle, color: AppColors.primary)
                  : null,
              onTap: () {
                context.setLocale(const Locale('en'));
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text(
                'arabic'.tr(),
                style: TextStyle(color: AppColors.getTextPrimary(context)),
              ),
              trailing: context.locale.languageCode == 'ar'
                  ? const Icon(Iconsax.tick_circle, color: AppColors.primary)
                  : null,
              onTap: () {
                context.setLocale(const Locale('ar'));
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark(context);

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
          child: Column(
            children: [
              // Header with Edit button
              _buildHeader(isDark),
              SizedBox(height: 30.h),

              // Group 3: App Settings
              _buildGroupTitle(isDark, 'settings'.tr()),
              _buildGroupContainer(isDark, [
                _buildSettingItem(
                  isDark,
                  icon: Iconsax.global,
                  iconBg: const Color(0xFF246BFD),
                  title: 'language'.tr(),
                  trailing: _buildBadge(
                    context.locale.languageCode == 'en'
                        ? 'english'.tr()
                        : 'arabic'.tr(),
                  ),
                  onTap: () => _showLanguageDialog(context),
                ),
                _buildDivider(isDark),
                _buildSettingItem(
                  isDark,
                  icon: Iconsax.colorfilter,
                  iconBg: const Color(0xFF47D16E),
                  title: 'appearance'.tr(),
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
              _buildGroupTitle(isDark, 'help_center'.tr()),
              // Using Help Center key for section slightly mismatch but okay
              _buildGroupContainer(isDark, [
                _buildSettingItem(
                  isDark,
                  icon: Iconsax.info_circle,
                  iconBg: const Color(0xFFACACAE),
                  title: 'help_center'.tr(),
                  onTap: () {},
                ),
                _buildDivider(isDark),
                _buildSettingItem(
                  isDark,
                  icon: Iconsax.logout,
                  iconBg: const Color(0xFFF75555),
                  title: 'logout'.tr(),
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
              SizedBox(height: 30.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    if (_isLoadingProfile) {
      return const Center(child: CircularProgressIndicator());
    }

    final user = _user;
    final initials = user?.initials ?? 'U';
    final name = user?.name ?? 'User';
    final email = user?.email ?? '';

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: () {},
              child: Text(
                'Edit',
                style: TextStyle(
                  color: AppColors.secondary,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        CircleAvatar(
          radius: 60.r,
          backgroundColor: AppColors.primary,
          child: Text(
            initials,
            style: GoogleFonts.outfit(
              fontSize: 40.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.white,
            ),
          ),
        ),
        SizedBox(height: 16.h),
        Text(
          name,
          style: TextStyle(
            color: AppColors.getTextPrimary(context),
            fontSize: 24.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          email,
          style: TextStyle(
            color: AppColors.getTextSecondary(context),
            fontSize: 14.sp,
          ),
        ),
      ],
    );
  }

  Widget _buildGroupTitle(bool isDark, String title) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(left: 4.w, bottom: 12.h),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          color: AppColors.getTextSecondary(context),
          fontSize: 12.sp,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildGroupContainer(bool isDark, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.getSurface(context),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppColors.getBorder(context)),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildDivider(bool isDark) {
    return Divider(
      height: 1.h,
      thickness: 1.h,
      color: AppColors.getBorder(context),
      indent: 60.w,
      endIndent: 16.w,
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
      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
      leading: Container(
        padding: EdgeInsets.all(8.r),
        decoration: BoxDecoration(
          color: iconBg,
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Icon(icon, color: Colors.white, size: 20.r),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: AppColors.getTextPrimary(context),
          fontSize: 16.sp,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing:
          trailing ??
          Icon(
            Iconsax.arrow_right_3,
            color: AppColors.getTextSecondary(context),
            size: 18.r,
          ),
    );
  }

  Widget _buildBadge(String label) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              color: AppColors.primary,
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(width: 4.w),
          Icon(Iconsax.arrow_right_3, color: AppColors.primary, size: 14.r),
        ],
      ),
    );
  }
}
