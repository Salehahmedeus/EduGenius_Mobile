import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../core/constants/app_colors.dart';

class ChatInputArea extends StatelessWidget {
  final TextEditingController messageController;
  final File? attachedFile;
  final VoidCallback onPickFile;
  final VoidCallback onRemoveFile;
  final VoidCallback onSendMessage;

  const ChatInputArea({
    super.key,
    required this.messageController,
    required this.attachedFile,
    required this.onPickFile,
    required this.onRemoveFile,
    required this.onSendMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: AppColors.getBackground(context),
        border: Border(top: BorderSide(color: AppColors.getBorder(context))),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (attachedFile != null)
              Container(
                margin: EdgeInsets.only(bottom: 12.h),
                padding: EdgeInsets.all(12.r),
                decoration: BoxDecoration(
                  color: AppColors.getSurface(context),
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                  boxShadow: [
                    if (!AppColors.isDark(context))
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: EdgeInsets.all(8.r),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Icon(
                        Iconsax.document_text,
                        size: 20.r,
                        color: AppColors.primary,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            attachedFile!.path.split('/').last,
                            style: GoogleFonts.outfit(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w500,
                              color: AppColors.getTextPrimary(context),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            'ready_to_analyze'.tr(),
                            style: GoogleFonts.outfit(
                              fontSize: 10.sp,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Iconsax.close_circle,
                        color: AppColors.getTextSecondary(context),
                        size: 20.r,
                      ),
                      onPressed: onRemoveFile,
                    ),
                  ],
                ),
              ),
            Container(
              decoration: BoxDecoration(
                color: AppColors.getSurface(context),
                borderRadius: BorderRadius.circular(32.r),
                border: Border.all(color: AppColors.getBorder(context)),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.getTextPrimary(context).withOpacity(0.02),
                    blurRadius: 10.r,
                    offset: Offset(0, 4.h),
                  ),
                ],
              ),
              padding: EdgeInsets.symmetric(vertical: 4.h),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(width: 8.w),
                      IconButton(
                        icon: Icon(
                          Iconsax.paperclip,
                          color: AppColors.getTextSecondary(context),
                          size: 24.r,
                        ),
                        onPressed: onPickFile,
                      ),
                      Expanded(
                        child: TextField(
                          controller: messageController,
                          maxLines: null,
                          style: TextStyle(
                            color: AppColors.getTextPrimary(context),
                          ),
                          decoration: InputDecoration(
                            hintText: 'message_hint'.tr(),
                            hintStyle: TextStyle(
                              color: AppColors.getTextSecondary(context),
                              fontSize: 16.sp,
                            ),
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            filled: false,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 4.w,
                              vertical: 12.h,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 12.w),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        icon: Icon(
                          Iconsax.emoji_happy,
                          color: AppColors.getTextSecondary(context),
                          size: 24.r,
                        ),
                        onPressed: () {},
                      ),
                      IconButton(
                        icon: Icon(
                          Iconsax.microphone_2,
                          color: AppColors.getTextSecondary(context),
                          size: 24.r,
                        ),
                        onPressed: () {},
                      ),
                      SizedBox(width: 4.w),
                      Material(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(24.r),
                        child: InkWell(
                          onTap: onSendMessage,
                          borderRadius: BorderRadius.circular(24.r),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 20.w,
                              vertical: 12.h,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'send'.tr(),
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.white,
                                  ),
                                ),
                                SizedBox(width: 8.w),
                                Icon(
                                  Iconsax.send_1,
                                  color: AppColors.white,
                                  size: 20.r,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 8.w),
                    ],
                  ),
                  SizedBox(height: 4.h),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
