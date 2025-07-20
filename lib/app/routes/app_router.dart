import 'package:go_router/go_router.dart';
import '../../features/../features/auth/auth_page.dart';
import '../../features/../features/form/form_page.dart';

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
    ],
  );
}
