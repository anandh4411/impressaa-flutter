import 'package:flutter/widgets.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

/// Global toast utility for consistent toast notifications across the app
/// Toasts appear at the top of the screen for better visibility
class ToastHelper {
  /// Show a success toast at the top of the screen
  static void showSuccess(
    BuildContext context, {
    required String title,
    String? description,
    Duration duration = const Duration(seconds: 3),
  }) {
    ShadToaster.of(context).show(
      ShadToast(
        title: Text(title),
        description: description != null ? Text(description) : null,
        duration: duration,
        alignment: Alignment.topCenter,
      ),
    );
  }

  /// Show an error/destructive toast at the top of the screen
  static void showError(
    BuildContext context, {
    required String title,
    String? description,
    Duration duration = const Duration(seconds: 4),
  }) {
    ShadToaster.of(context).show(
      ShadToast.destructive(
        title: Text(title),
        description: description != null ? Text(description) : null,
        duration: duration,
        alignment: Alignment.topCenter,
      ),
    );
  }

  /// Show an info toast at the top of the screen
  static void showInfo(
    BuildContext context, {
    required String title,
    String? description,
    Duration duration = const Duration(seconds: 3),
  }) {
    ShadToaster.of(context).show(
      ShadToast(
        title: Text(title),
        description: description != null ? Text(description) : null,
        duration: duration,
        alignment: Alignment.topCenter,
      ),
    );
  }

  /// Show a warning toast at the top of the screen
  static void showWarning(
    BuildContext context, {
    required String title,
    String? description,
    Duration duration = const Duration(seconds: 3),
  }) {
    ShadToaster.of(context).show(
      ShadToast.destructive(
        title: Text(title),
        description: description != null ? Text(description) : null,
        duration: duration,
        alignment: Alignment.topCenter,
      ),
    );
  }
}
