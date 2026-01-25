import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../data/models/dashboard_model.dart';
import 'dashboard_stat_card.dart';

class DashboardStatsOverview extends StatelessWidget {
  final DashboardStats stats;

  const DashboardStatsOverview({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: DashboardStatCard(
            label: 'quizzes'.tr(),
            value: '${stats.quizCount}',
            icon: Iconsax.task_square,
            color: AppColors.info,
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: DashboardStatCard(
            label: 'avg_score_label'.tr(),
            value: '${stats.avgScore.toStringAsFixed(0)}%',
            icon: Iconsax.chart_21,
            color: AppColors.success,
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: DashboardStatCard(
            label: 'uploaded'.tr(),
            value: '${stats.uploadedCount}',
            icon: Iconsax.document_upload,
            color: AppColors.warning,
          ),
        ),
      ],
    );
  }
}
