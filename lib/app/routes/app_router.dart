import 'package:go_router/go_router.dart';
import 'package:impressaa/features/form/form_preview_page.dart';
import 'package:impressaa/features/auth/auth_page.dart';
import 'package:impressaa/features/form/form_page.dart';
import 'package:impressaa/features/form/data/form_models.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/form',
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const AuthPage(),
      ),
      GoRoute(
        path: '/form',
        builder: (context, state) => const FormPage(),
      ),
      GoRoute(
        path: '/form/preview',
        builder: (context, state) {
          final extra = state.extra;

          if (extra == null) {
            // Redirect to form if no data
            return const FormPage();
          }

          try {
            // Handle the map conversion safely
            Map<String, dynamic> dataMap;

            if (extra is Map<String, dynamic>) {
              dataMap = extra;
            } else if (extra is Map) {
              dataMap = Map<String, dynamic>.from(extra);
            } else {
              return const FormPage();
            }

            final formConfig = dataMap['formConfig'] as FormConfigModel?;
            final formDataRaw = dataMap['formData'];

            if (formConfig == null || formDataRaw == null) {
              return const FormPage();
            }

            final formData = formDataRaw is Map<String, dynamic>
                ? formDataRaw
                : Map<String, dynamic>.from(formDataRaw as Map);

            return FormPreviewPage(
              formConfig: formConfig,
              formData: formData,
            );
          } catch (e) {
            // If anything goes wrong, go back to form
            return const FormPage();
          }
        },
      ),
    ],
  );
}
