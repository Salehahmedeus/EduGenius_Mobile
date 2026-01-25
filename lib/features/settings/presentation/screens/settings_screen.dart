import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';

import '../../../auth/data/services/auth_service.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/theme_manager.dart';
import '../../../../core/widgets/custom_snackbar.dart';
import '../../../../routes.dart';
import '../../../auth/data/models/user_model.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../widgets/settings_profile_header.dart';
import '../widgets/settings_section.dart';
import '../widgets/settings_tile.dart';

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
      appBar: CustomAppBar(title: 'settings'.tr(), showBackButton: false),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
          child: Column(
            children: [
              // Header with Profile
              SettingsProfileHeader(user: _user, isLoading: _isLoadingProfile),
              SizedBox(height: 30.h),

              // Group 3: App Settings
              SettingsSection(
                title: 'appearance'.tr(),
                children: [
                  SettingsTile(
                    icon: Iconsax.global,
                    iconBgColor: const Color(0xFF246BFD),
                    title: 'language'.tr(),
                    trailing: _buildBadge(
                      context.locale.languageCode == 'en'
                          ? 'english'.tr()
                          : 'arabic'.tr(),
                    ),
                    onTap: () => _showLanguageDialog(context),
                    showDivider: true,
                  ),
                  SettingsTile(
                    icon: Iconsax.colorfilter,
                    iconBgColor: const Color(0xFF47D16E),
                    title: 'dark_mode'.tr(),
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
                ],
              ),
              const SizedBox(height: 24),

              // Group 4: Account & Support
              SettingsSection(
                title: 'help_center'.tr(),
                children: [
                  SettingsTile(
                    icon: Iconsax.info_circle,
                    iconBgColor: const Color(0xFFACACAE),
                    title: 'help_center'.tr(),
                    onTap: () {},
                    showDivider: true,
                  ),
                  SettingsTile(
                    icon: Iconsax.logout,
                    iconBgColor: const Color(0xFFF75555),
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
                ],
              ),
              SizedBox(height: 30.h),
            ],
          ),
        ),
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
