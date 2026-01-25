import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../../core/constants/app_colors.dart';

class InsightsList extends StatelessWidget {
  final List<String> insights;

  const InsightsList({super.key, required this.insights});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: insights.map((insight) {
        // Format text: Remove decimals from % and handle **bold**
        String cleanText = insight.replaceAllMapped(
          RegExp(r'(\d+)\.0+%|(\d+\.\d+?)0+%'),
          (match) {
            String numStr = match.group(1) ?? match.group(2) ?? '';
            if (numStr.isEmpty) return match.group(0)!;
            double val =
                double.tryParse(match.group(0)!.replaceAll('%', '')) ?? 0;
            return '${val.toStringAsFixed(0)}%';
          },
        );

        cleanText = cleanText.replaceAllMapped(RegExp(r'(\d+\.\d+)%'), (match) {
          double val = double.tryParse(match.group(1)!) ?? 0;
          return '${val.toStringAsFixed(0)}%';
        });

        List<InlineSpan> spans = [];
        final boldRegex = RegExp(r'\*\*(.*?)\*\*');
        int lastIndex = 0;

        for (final match in boldRegex.allMatches(cleanText)) {
          if (match.start > lastIndex) {
            spans.add(
              TextSpan(
                text: cleanText.substring(lastIndex, match.start),
                style: GoogleFonts.outfit(
                  fontSize: 14.sp,
                  color: AppColors.getTextPrimary(context),
                  height: 1.5,
                ),
              ),
            );
          }
          spans.add(
            TextSpan(
              text: match.group(1),
              style: GoogleFonts.outfit(
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
                height: 1.5,
              ),
            ),
          );
          lastIndex = match.end;
        }

        if (lastIndex < cleanText.length) {
          spans.add(
            TextSpan(
              text: cleanText.substring(lastIndex),
              style: GoogleFonts.outfit(
                fontSize: 14.sp,
                color: AppColors.getTextPrimary(context),
                height: 1.5,
              ),
            ),
          );
        }

        return Container(
          margin: EdgeInsets.only(bottom: 12.h),
          padding: EdgeInsets.all(16.r),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.05),
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: AppColors.primary.withOpacity(0.1)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(8.r),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  Iconsax.magic_star,
                  color: AppColors.primary,
                  size: 18.r,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: RichText(text: TextSpan(children: spans)),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
