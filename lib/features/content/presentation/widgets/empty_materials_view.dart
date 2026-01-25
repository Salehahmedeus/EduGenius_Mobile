import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../core/constants/app_colors.dart';

class EmptyMaterialsView extends StatelessWidget {
  final String searchQuery;
  final VoidCallback onClearSearch;

  const EmptyMaterialsView({
    super.key,
    required this.searchQuery,
    required this.onClearSearch,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Iconsax.folder_open,
            size: 80.r,
            color: AppColors.getSurface(context),
          ),
          SizedBox(height: 16.h),
          Text(
            searchQuery.isNotEmpty
                ? 'no_results'.tr(args: [searchQuery])
                : 'no_materials_found'.tr(),
            style: TextStyle(
              fontSize: 18.sp,
              color: AppColors.getTextSecondary(context),
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'upload_first_material'.tr(),
            style: TextStyle(
              color: AppColors.getTextSecondary(context),
              fontSize: 14.sp,
            ),
          ),
          if (searchQuery.isNotEmpty)
            TextButton(
              onPressed: onClearSearch,
              child: Text('clear_search'.tr()),
            ),
        ],
      ),
    );
  }
}
