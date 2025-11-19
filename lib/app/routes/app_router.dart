import 'dart:io';
import 'package:go_router/go_router.dart';
import 'package:impressaa/features/splash/splash_page.dart';
import 'package:impressaa/features/form/form_preview_page.dart';
import 'package:impressaa/features/form/photo_capture_page.dart';
import 'package:impressaa/features/auth/auth_page.dart';
import 'package:impressaa/features/form/form_page.dart';
import 'package:impressaa/features/form/data/form_models.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/', // Changed to '/' to show splash first
    routes: [
      // Splash Screen Route
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const AuthPage(),
      ),
      GoRoute(
        path: '/form',
        builder: (context, state) => const FormPage(),
      ),
      GoRoute(
        path: '/form/photo',
        builder: (context, state) {
          final formId = state.uri.queryParameters['formId'];
          return PhotoCapturePage(formId: formId);
        },
      ),
      GoRoute(
        path: '/form/preview',
        builder: (context, state) {
          final extra = state.extra;

          if (extra == null) {
            return const FormPage();
          }

          try {
            Map<String, dynamic> dataMap;

            if (extra is Map<String, dynamic>) {
              dataMap = extra;
            } else if (extra is Map) {
              dataMap = Map<String, dynamic>.from(extra);
            } else {
              return const FormPage();
            }

            final formResponse = dataMap['formResponse'] as FormApiResponse?;
            final formDataRaw = dataMap['formData'];
            final photo = dataMap['photo'] as File?;

            if (formResponse == null || formDataRaw == null) {
              return const FormPage();
            }

            final formData = formDataRaw is Map<String, dynamic>
                ? formDataRaw
                : Map<String, dynamic>.from(formDataRaw as Map);

            return FormPreviewPage(
              formResponse: formResponse,
              formData: formData,
              photo: photo,
            );
          } catch (e) {
            return const FormPage();
          }
        },
      ),
    ],
  );
}
