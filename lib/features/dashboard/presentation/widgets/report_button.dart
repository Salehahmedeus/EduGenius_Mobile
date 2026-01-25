import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../data/models/progress_report_model.dart';

class ReportButton extends StatefulWidget {
  final Future<ProgressReportModel> Function() onGenerateReport;

  const ReportButton({super.key, required this.onGenerateReport});

  @override
  State<ReportButton> createState() => _ReportButtonState();
}

class _ReportButtonState extends State<ReportButton> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56.h,
      child: OutlinedButton(
        onPressed: _isLoading ? null : _handlePress,
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: AppColors.getBorder(context)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
        ),
        child: _isLoading
            ? SizedBox(
                height: 20.r,
                width: 20.r,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.primary,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Iconsax.document_download, size: 20.r),
                  SizedBox(width: 8.w),
                  Text(
                    'Generate Progress Report',
                    style: GoogleFonts.outfit(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.getTextPrimary(context),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Future<void> _handlePress() async {
    setState(() => _isLoading = true);
    try {
      final report = await widget.onGenerateReport();
      if (mounted) {
        _showReportDialog(context, report);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to generate report: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showReportDialog(BuildContext context, ProgressReportModel report) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.getSurface(context),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Iconsax.document_text, color: AppColors.primary),
            SizedBox(width: 12.w),
            Text(
              'progress_report'.tr(),
              style: GoogleFonts.outfit(
                fontWeight: FontWeight.bold,
                color: AppColors.getTextPrimary(context),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'overview'.tr(),
                style: GoogleFonts.outfit(
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                'Total Quizzes: ${report.totalQuizzes}',
                style: GoogleFonts.outfit(
                  color: AppColors.getTextPrimary(context),
                ),
              ),
              Text(
                'Average Score: ${report.averageScore.toStringAsFixed(1)}%',
                style: GoogleFonts.outfit(
                  color: AppColors.getTextPrimary(context),
                ),
              ),
              SizedBox(height: 16.h),
              if (report.strengths.isNotEmpty) ...[
                Text(
                  'Strengths',
                  style: GoogleFonts.outfit(
                    fontWeight: FontWeight.w600,
                    color: AppColors.success,
                  ),
                ),
                SizedBox(height: 4.h),
                ...report.strengths.map(
                  (s) => Row(
                    children: [
                      Icon(
                        Icons.check_circle_outline,
                        size: 16,
                        color: AppColors.success,
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          s,
                          style: GoogleFonts.outfit(
                            fontSize: 12.sp,
                            color: AppColors.getTextSecondary(context),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16.h),
              ],
              if (report.weaknesses.isNotEmpty) ...[
                Text(
                  'Areas for Improvement',
                  style: GoogleFonts.outfit(
                    fontWeight: FontWeight.w600,
                    color: AppColors.warning,
                  ),
                ),
                SizedBox(height: 4.h),
                ...report.weaknesses.map(
                  (w) => Row(
                    children: [
                      Icon(
                        Icons.warning_amber_rounded,
                        size: 16,
                        color: AppColors.warning,
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          w,
                          style: GoogleFonts.outfit(
                            fontSize: 12.sp,
                            color: AppColors.getTextSecondary(context),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16.h),
              ],
              Text(
                'Generated: ${report.generatedAt.toString().split('.')[0]}',
                style: GoogleFonts.outfit(
                  fontSize: 10.sp,
                  color: AppColors.grey,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Close',
              style: GoogleFonts.outfit(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }
}
