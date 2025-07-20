import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import '../data/form_models.dart';

class DynamicFormField extends StatelessWidget {
  final FormFieldModel field;
  final dynamic value;
  final ValueChanged<dynamic> onChanged;
  final String? errorText;

  const DynamicFormField({
    super.key,
    required this.field,
    required this.value,
    required this.onChanged,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    switch (field.type) {
      case FormFieldType.text:
      case FormFieldType.email:
      case FormFieldType.phone:
      case FormFieldType.number:
        return _buildTextInput();
      case FormFieldType.textarea:
        return _buildTextArea();
      case FormFieldType.select:
        return _buildSelect();
      case FormFieldType.date:
        return _buildDatePicker();
      case FormFieldType.file:
        return _buildFilePicker();
    }
  }

  Widget _buildTextInput() {
    return ShadInputFormField(
      id: field.id,
      label: Text(field.label),
      placeholder: field.placeholder != null ? Text(field.placeholder!) : null,
      description: field.helpText != null ? Text(field.helpText!) : null,
      keyboardType: _getKeyboardType(),
      inputFormatters: _getInputFormatters(),
      onChanged: onChanged,
      validator: (value) => errorText,
    );
  }

  Widget _buildTextArea() {
    return ShadTextareaFormField(
      id: field.id,
      label: Text(field.label),
      placeholder: field.placeholder != null ? Text(field.placeholder!) : null,
      description: field.helpText != null ? Text(field.helpText!) : null,
      onChanged: onChanged,
      validator: (value) => errorText,
    );
  }

  Widget _buildSelect() {
    return ShadSelectFormField<String>(
      id: field.id,
      label: Text(field.label),
      placeholder: Text(field.placeholder ??
          'Select ${field.label}'), // Always provide placeholder
      description: field.helpText != null ? Text(field.helpText!) : null,
      selectedOptionBuilder: (context, value) => Text(value),
      options: field.options
              ?.map((option) => ShadOption(value: option, child: Text(option)))
              .toList() ??
          [],
      onChanged: onChanged,
      validator: (value) => errorText,
    );
  }

  Widget _buildDatePicker() {
    return ShadDatePickerFormField(
      id: field.id,
      label: Text(field.label),
      description: field.helpText != null ? Text(field.helpText!) : null,
      onChanged: onChanged,
      validator: (value) => errorText,
    );
  }

  Widget _buildFilePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          field.label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              const Icon(Icons.upload_file, size: 32, color: Colors.grey),
              const SizedBox(height: 8),
              const Text(
                'Tap to upload file',
                style: TextStyle(color: Colors.grey),
              ),
              if (field.helpText != null) ...[
                const SizedBox(height: 4),
                Text(
                  field.helpText!,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ],
          ),
        ),
        if (errorText != null) ...[
          const SizedBox(height: 4),
          Text(
            errorText!,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.red,
            ),
          ),
        ],
      ],
    );
  }

  TextInputType _getKeyboardType() {
    switch (field.type) {
      case FormFieldType.email:
        return TextInputType.emailAddress;
      case FormFieldType.phone:
        return TextInputType.phone;
      case FormFieldType.number:
        return TextInputType.number;
      default:
        return TextInputType.text;
    }
  }

  List<TextInputFormatter>? _getInputFormatters() {
    switch (field.type) {
      case FormFieldType.number:
        return [FilteringTextInputFormatter.digitsOnly];
      case FormFieldType.phone:
        return [FilteringTextInputFormatter.allow(RegExp(r'[\d\s\-\(\)\+]'))];
      default:
        return null;
    }
  }
}
