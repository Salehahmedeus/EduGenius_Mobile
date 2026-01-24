import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_manager.dart';
import 'routes.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() {
  runApp(const EduGeniusApp());
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
            return MaterialApp(
              navigatorKey: navigatorKey,
              title: 'EduGenius',
              debugShowCheckedModeBanner: false,
              theme: AppTheme.light,
              darkTheme: AppTheme.dark,
              themeMode: themeMode,
              initialRoute: Routes.splash,
              routes: Routes.getRoutes(),
            );
          },
        );
      },
    );
  }
}
