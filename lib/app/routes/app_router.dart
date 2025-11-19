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
          final aspectRatio = state.extra as String?; // Aspect ratio passed via extra
          return PhotoCapturePage(
            formId: formId,
            aspectRatio: aspectRatio,
          );
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
              print('ERROR: extra is not a Map: ${extra.runtimeType}');
              return const FormPage();
            }

            final formResponse = dataMap['formResponse'];
            final formDataRaw = dataMap['formData'];
            final photosRaw = dataMap['photos'];

            print('formResponse type: ${formResponse?.runtimeType}');
            print('formDataRaw type: ${formDataRaw?.runtimeType}');
            print('photosRaw type: ${photosRaw?.runtimeType}');

            if (formResponse == null || formDataRaw == null) {
              print('ERROR: Missing formResponse or formData');
              return const FormPage();
            }

            if (formResponse is! FormApiResponse) {
              print('ERROR: formResponse is not FormApiResponse: ${formResponse.runtimeType}');
              return const FormPage();
            }

            // Convert formData - keys can be int or String
            final Map<String, dynamic> formData = {};
            if (formDataRaw is Map) {
              formDataRaw.forEach((key, value) {
                formData[key.toString()] = value;
              });
            }

            // Convert photos map
            final Map<dynamic, File> photos = {};
            if (photosRaw is Map) {
              photosRaw.forEach((key, value) {
                if (value is File) {
                  photos[key] = value;
                }
              });
            }

            print('Successfully parsed data, creating preview page');
            return FormPreviewPage(
              formResponse: formResponse,
              formData: formData,
              photos: photos,
            );
          } catch (e, stackTrace) {
            print('ERROR in preview route: $e');
            print('Stack trace: $stackTrace');
            return const FormPage();
          }
        },
      ),
    ],
  );
}
