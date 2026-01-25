import 'package:easy_localization/easy_localization.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../data/models/dashboard_model.dart';

class TopicStrengthChart extends StatelessWidget {
  final List<TopicStrength> topicStrengths;

  const TopicStrengthChart({super.key, required this.topicStrengths});

  @override
  Widget build(BuildContext context) {
    if (topicStrengths.isEmpty) {
      return Container(
        height: 200,
        decoration: BoxDecoration(
          color: AppColors.lightGrey.withOpacity(0.3),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Center(
          child: Text(
            'no_topic_data'.tr(),
            style: GoogleFonts.outfit(
              color: AppColors.getTextSecondary(context),
            ),
          ),
        ),
      );
    }

    return Container(
      height: 320.h,
      padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 16.h),
      decoration: BoxDecoration(
        color: AppColors.getSurface(context),
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(
          color: AppColors.getBorder(context).withOpacity(0.5),
        ),
        boxShadow: [
          if (!AppColors.isDark(context))
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
        ],
      ),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: 100,
          barTouchData: BarTouchData(
            enabled: true,
            touchTooltipData: BarTouchTooltipData(
              getTooltipColor: (_) => AppColors.getSurface(context),
              tooltipBorder: BorderSide(
                color: AppColors.primary.withOpacity(0.2),
              ),
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                String topicName = topicStrengths[groupIndex].topic;
                return BarTooltipItem(
                  '$topicName\n',
                  TextStyle(
                    color: AppColors.getTextPrimary(context),
                    fontWeight: FontWeight.bold,
                    fontSize: 12.sp,
                  ),
                  children: <TextSpan>[
                    TextSpan(
                      text: '${rod.toY.round()}%',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (double value, TitleMeta meta) {
                  final index = value.toInt();
                  if (index >= 0 && index < topicStrengths.length) {
                    String name = topicStrengths[index].topic;
                    if (name.length > 8) name = '${name.substring(0, 8)}...';
                    return Padding(
                      padding: EdgeInsets.only(top: 10.0.h),
                      child: Transform.rotate(
                        angle: -0.2,
                        child: Text(
                          name,
                          style: TextStyle(
                            color: AppColors.getTextSecondary(context),
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 20,
            getDrawingHorizontalLine: (value) => FlLine(
              color: AppColors.getBorder(context).withOpacity(0.3),
              strokeWidth: 1,
            ),
          ),
          borderData: FlBorderData(show: false),
          barGroups: topicStrengths.asMap().entries.map((e) {
            Color barColor = e.value.avgScore >= 80
                ? AppColors.success
                : (e.value.avgScore >= 60
                      ? AppColors.warning
                      : AppColors.error);
            return BarChartGroupData(
              x: e.key,
              barRods: [
                BarChartRodData(
                  toY: e.value.avgScore,
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [barColor.withOpacity(0.7), barColor],
                  ),
                  width: 16.w,
                  borderRadius: BorderRadius.all(Radius.circular(6.r)),
                  backDrawRodData: BackgroundBarChartRodData(
                    show: true,
                    toY: 100,
                    color: AppColors.getBackground(context).withOpacity(0.5),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}
