import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'data/form_models.dart';

class FormPreviewPage extends StatefulWidget {
  final FormConfigModel formConfig;
  final Map<String, dynamic> formData;
  final File? photo;

  const FormPreviewPage({
    super.key,
    required this.formConfig,
    required this.formData,
    this.photo,
  });

  @override
  State<FormPreviewPage> createState() => _FormPreviewPageState();
}

class _FormPreviewPageState extends State<FormPreviewPage> {
  final ScrollController _scrollController = ScrollController();
  bool _showScrollIndicator = true;
  bool _hasScrolledToBottom = false;
  bool _isConfirmed = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);

    // Check if content is scrollable after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkIfScrollable();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _checkIfScrollable() {
    if (!mounted) return;

    final isScrollable = _scrollController.position.maxScrollExtent > 0;
    setState(() {
      _showScrollIndicator = isScrollable;
      // If not scrollable, user has already "seen everything"
      if (!isScrollable) {
        _hasScrolledToBottom = true;
      }
    });
  }

  void _onScroll() {
    if (!mounted) return;

    // Hide scroll indicator when user starts scrolling
    if (_showScrollIndicator && _scrollController.offset > 50) {
      setState(() {
        _showScrollIndicator = false;
      });
    }

    // Check if scrolled to bottom (with small threshold)
    final isAtBottom = _scrollController.offset >=
        _scrollController.position.maxScrollExtent - 50;

    if (isAtBottom && !_hasScrolledToBottom) {
      setState(() {
        _hasScrolledToBottom = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    return CupertinoPageScaffold(
      backgroundColor: theme.colorScheme.background,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: theme.colorScheme.background,
        border: null,
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () => context.pop(),
          child: Icon(
            CupertinoIcons.back,
            color: theme.colorScheme.foreground,
          ),
        ),
        middle: Text(
          'Preview Form',
          style: TextStyle(
            color: theme.colorScheme.foreground,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Preview Content with Scroll Indicator
            Expanded(
              child: Stack(
                children: [
                  SingleChildScrollView(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Photo Preview (starts directly, no heading)
                        if (widget.photo != null) ...[
                          _buildPhotoPreview(widget.photo!),
                          const SizedBox(height: 24),
                        ],

                        // Form Data Preview
                        ...widget.formConfig.fields.map((field) {
                          final value = widget.formData[field.id];
                          if (value == null ||
                              value.toString().trim().isEmpty) {
                            return const SizedBox.shrink();
                          }

                          return _buildPreviewField(field, value);
                        }),

                        // Confirmation Checkbox (only shows after scrolling to bottom)
                        if (_hasScrolledToBottom) ...[
                          const SizedBox(height: 24),
                          _buildConfirmationCheckbox(theme),
                        ],

                        // Extra spacing at bottom
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),

                  // Scroll Down Indicator
                  if (_showScrollIndicator)
                    Positioned(
                      bottom: 20,
                      left: 0,
                      right: 0,
                      child: _buildScrollIndicator(),
                    ),
                ],
              ),
            ),

            // Bottom Actions
            _buildBottomActions(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildScrollIndicator() {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.7),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Scroll to view all details',
              style: TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 8),
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 8.0),
              duration: const Duration(milliseconds: 800),
              builder: (context, value, child) {
                return Transform.translate(
                  offset: Offset(0, value),
                  child: const Icon(
                    CupertinoIcons.chevron_down,
                    color: Colors.white,
                    size: 16,
                  ),
                );
              },
              onEnd: () {
                // Restart animation
                setState(() {});
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConfirmationCheckbox(ShadThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.muted.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.border,
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShadCheckbox(
            value: _isConfirmed,
            onChanged: (value) {
              setState(() {
                _isConfirmed = value ?? false;
              });
            },
          ),
          const SizedBox(width: 12),
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _isConfirmed = !_isConfirmed;
                });
              },
              child: Text(
                'I confirm that I have reviewed all the information above and verify that it is correct.',
                style: TextStyle(
                  fontSize: 14,
                  color: theme.colorScheme.foreground,
                  height: 1.4,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoPreview(File photoFile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'ID Card Photo',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.check_circle,
                    size: 14,
                    color: Colors.green.shade700,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '35mm × 45mm',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.green.shade700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.grey.shade300,
              width: 1,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: AspectRatio(
              aspectRatio: 35 / 45,
              child: Image.file(
                photoFile,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        const Divider(),
      ],
    );
  }

  Widget _buildPreviewField(FormFieldModel field, dynamic value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            field.label,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value.toString(),
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 8),
          const Divider(),
        ],
      ),
    );
  }

  Widget _buildBottomActions(ShadThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.background,
        border: Border(
          top: BorderSide(
            color: theme.colorScheme.border,
            width: 1,
          ),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: double.infinity,
            child: ShadButton(
              // Disable button if user hasn't confirmed
              onPressed: _isConfirmed ? () => _handleSubmit(context) : null,
              child: const Text('Submit Application'),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ShadButton.outline(
              onPressed: () => context.pop(),
              child: const Text('Edit Form'),
            ),
          ),
        ],
      ),
    );
  }

  void _handleSubmit(BuildContext context) async {
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    // Simulate API submission
    await Future.delayed(const Duration(seconds: 2));

    if (context.mounted) {
      Navigator.of(context).pop(); // Close loading dialog

      // Show success dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text('Success!'),
          content: const Text(
              'Your application has been submitted successfully. Your ID card will be ready soon.'),
          actions: [
            TextButton(
              onPressed: () {
                // Navigate back to login
                context.go('/login');
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }
}
