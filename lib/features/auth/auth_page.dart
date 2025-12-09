import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import '../../shared/widgets/wave_background.dart';
import '../../core/di/injection.dart';
import 'components/header_section.dart';
import 'components/form_section.dart';
import 'components/help_section.dart';
import 'state/auth_bloc.dart';
import 'data/auth_api_service.dart';
import '../../core/storage/auth_storage.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AuthBloc(
        authApiService: getIt<AuthApiService>(),
        authStorage: getIt<AuthStorage>(),
      ),
      child: const _AuthPageView(),
    );
  }
}

class _AuthPageView extends StatelessWidget {
  const _AuthPageView();

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return CupertinoPageScaffold(
      backgroundColor: theme.colorScheme.primary,
      resizeToAvoidBottomInset: false,
      child: Stack(
        children: [
          // Static background
          const WaveBackground(child: SizedBox.expand()),

          // Content
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  padding: EdgeInsets.fromLTRB(20, 20, 20, bottomPadding + 20),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: constraints.maxHeight - 40),
                    child: Column(
                      children: [
                        const SizedBox(height: 40),
                        const HeaderSection(),
                        const SizedBox(height: 40),
                        FormSection(onSuccess: () => context.go('/form')),
                        if (bottomPadding == 0) ...[
                          const SizedBox(height: 32),
                          const HelpSection(),
                        ],
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
