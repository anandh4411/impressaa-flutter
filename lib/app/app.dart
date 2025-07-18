import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart'
    show ThemeMode, DefaultMaterialLocalizations;
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:google_fonts/google_fonts.dart';

import 'routes/app_router.dart';
import '../core//theme//app_theme.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // Set desired color scheme here
  static const String colorSchemeName = 'blue';

  @override
  Widget build(BuildContext context) {
    return ShadApp.custom(
      themeMode: ThemeMode.system,
      theme: AppTheme.lightTheme(colorSchemeName).copyWith(
        textTheme: ShadTextTheme.fromGoogleFont(GoogleFonts.poppins),
      ),
      darkTheme: AppTheme.darkTheme(colorSchemeName).copyWith(
        textTheme: ShadTextTheme.fromGoogleFont(GoogleFonts.poppins),
      ),
      appBuilder: (context) {
        return CupertinoApp.router(
          title: 'Impressaa',
          theme: CupertinoTheme.of(context),
          routerConfig: AppRouter.router,
          localizationsDelegates: const [
            DefaultMaterialLocalizations.delegate,
            DefaultCupertinoLocalizations.delegate,
            DefaultWidgetsLocalizations.delegate,
          ],
          builder: (context, child) {
            return ShadAppBuilder(child: child!);
          },
        );
      },
    );
  }
}
