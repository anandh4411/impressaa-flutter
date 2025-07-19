import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import '../../features/../features/auth/auth_page.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/login',
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

// // Cupertino-style placeholder pages
// class LoginPage extends StatelessWidget {
//   const LoginPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return const CupertinoPageScaffold(
//       navigationBar: CupertinoNavigationBar(
//         middle: Text('Login'),
//         border: null,
//       ),
//       child: Center(
//         child: Text('Login with verification code'),
//       ),
//     );
//   }
// }

class FormPage extends StatelessWidget {
  const FormPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('ID Card Form'),
        border: null,
      ),
      child: Center(
        child: Text('Form submission page'),
      ),
    );
  }
}
