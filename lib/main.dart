import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_manager.dart';
import 'routes.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:easy_localization/easy_localization.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('ar')],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      child: const EduGeniusApp(),
    ),
  );
}

class EduGeniusApp extends StatelessWidget {
  const EduGeniusApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return ValueListenableBuilder<ThemeMode>(
          valueListenable: themeManager,
          builder: (context, themeMode, _) {
            // Determine font based on locale
            final isArabic = context.locale.languageCode == 'ar';

            ThemeData lightTheme = AppTheme.light;
            ThemeData darkTheme = AppTheme.dark;

            if (isArabic) {
              lightTheme = lightTheme.copyWith(
                textTheme: GoogleFonts.tajawalTextTheme(lightTheme.textTheme),
              );
              darkTheme = darkTheme.copyWith(
                textTheme: GoogleFonts.tajawalTextTheme(darkTheme.textTheme),
              );
            } else {
              // Optional: Set default font to Outfit if desired globally, matching screens
              lightTheme = lightTheme.copyWith(
                textTheme: GoogleFonts.outfitTextTheme(lightTheme.textTheme),
              );
              darkTheme = darkTheme.copyWith(
                textTheme: GoogleFonts.outfitTextTheme(darkTheme.textTheme),
              );
            }

            return MaterialApp(
              navigatorKey: navigatorKey,
              title: 'EduGenius',
              debugShowCheckedModeBanner: false,
              theme: lightTheme,
              darkTheme: darkTheme,
              themeMode: themeMode,
              localizationsDelegates: context.localizationDelegates,
              supportedLocales: context.supportedLocales,
              locale: context.locale,
              initialRoute: Routes.splash,
              routes: Routes.getRoutes(),
            );
          },
        );
      },
    );
  }
}
