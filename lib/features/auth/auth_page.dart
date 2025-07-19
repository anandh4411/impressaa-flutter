import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import '../../shared/widgets/wave_background.dart';
import 'components/header_section.dart';
import 'components/form_section.dart';
import 'state/auth_bloc.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AuthBloc(),
      child: const _AuthPageView(),
    );
  }
}

class _AuthPageView extends StatelessWidget {
  const _AuthPageView();

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    return CupertinoPageScaffold(
      backgroundColor: theme.colorScheme.primary,
      child: SafeArea(
        child: WaveBackground(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                const Expanded(
                  flex: 3,
                  child: HeaderSection(),
                ),
                Expanded(
                  flex: 4,
                  child: FormSection(
                    onSuccess: () => context.go('/form'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
