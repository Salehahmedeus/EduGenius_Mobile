import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../data/models/material_model.dart';

class MaterialCard extends StatelessWidget {
  final MaterialModel material;
  final Function(int) onDelete;
  final VoidCallback onTap;

  const MaterialCard({
    super.key,
    required this.material,
    required this.onDelete,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isPdf = material.fileType.toLowerCase().contains('pdf');
    final iconColor = isPdf ? AppColors.error : AppColors.primary;

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: AppColors.getSurface(context),
        border: Border.all(color: AppColors.getBorder(context)),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
        onTap: onTap,
        leading: Container(
          padding: EdgeInsets.all(10.r),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Icon(
            isPdf ? Iconsax.document_text : Iconsax.document,
            color: iconColor,
            size: 24.r,
          ),
        ),
        title: Text(
          material.fileName,
          style: TextStyle(
            fontSize: 15.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.getTextPrimary(context),
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          '${material.fileType.toUpperCase()} • ${DateFormat('HH:mm').format(material.createdAt)}',
          style: TextStyle(
            fontSize: 12.sp,
            color: AppColors.getTextSecondary(context),
          ),
        ),
        trailing: PopupMenuButton<String>(
          icon: Icon(
            Iconsax.more,
            color: AppColors.getTextSecondary(context),
            size: 18.r,
          ),
          onSelected: (value) {
            if (value == 'delete') {
              onDelete(material.id);
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'delete',
              child: Text(
                'delete'.tr(),
                style: const TextStyle(color: AppColors.error),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
