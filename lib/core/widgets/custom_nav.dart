import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../constants/app_colors.dart';
import 'package:easy_localization/easy_localization.dart';

class CustomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.getBackground(context),
        boxShadow: [
          BoxShadow(
            color: AppColors.isDark(context)
                ? Colors.black.withOpacity(0.3)
                : Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                context,
                icon: Iconsax.messages_1,
                label: 'chat'.tr(),
                index: 0,
              ),
              _buildNavItem(
                context,
                icon: Iconsax.book,
                label: 'materials'.tr(),
                index: 1,
              ),
              _buildNavItem(
                context,
                icon: Iconsax.element_3,
                label: 'dashboard'.tr(),
                index: 2,
              ),
              _buildNavItem(
                context,
                icon: Iconsax.note_2,
                label: 'quiz'.tr(),
                index: 3,
              ),
              _buildNavItem(
                context,
                icon: Iconsax.setting_2,
                label: 'settings'.tr(),
                index: 4,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required int index,
  }) {
    final isActive = currentIndex == index;
    final activeColor = AppColors.primary;
    final inactiveColor = AppColors.getTextSecondary(context);

    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        color: Colors.transparent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: isActive ? activeColor : inactiveColor, size: 26),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isActive ? activeColor : inactiveColor,
                fontSize: 11,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
