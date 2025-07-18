import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart'
    show ThemeMode, DefaultMaterialLocalizations, Brightness, Colors;
import 'package:shadcn_ui/shadcn_ui.dart';
import 'routes/app_router.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ShadApp.custom(
      themeMode: ThemeMode.system,
      theme: ShadThemeData(
        brightness: Brightness.light,
        colorScheme: const ShadSlateColorScheme.light(),
      ),
      darkTheme: ShadThemeData(
        brightness: Brightness.dark,
        colorScheme: const ShadSlateColorScheme.dark(
          background: Colors.black, // Pure black background
          card: Color(0xFF1a1a1a), // Dark gray for cards
        ),
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
