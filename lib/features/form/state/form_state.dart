import '../data/form_models.dart';

abstract class DynamicFormState {}

class DynamicFormInitial extends DynamicFormState {}

class DynamicFormLoading extends DynamicFormState {}

class DynamicFormLoaded extends DynamicFormState {
  final FormConfigModel formConfig;
  final Map<String, dynamic> formData;

  DynamicFormLoaded({
    required this.formConfig,
    this.formData = const {},
  });

  DynamicFormLoaded copyWith({
    FormConfigModel? formConfig,
    Map<String, dynamic>? formData,
  }) {
    return DynamicFormLoaded(
      formConfig: formConfig ?? this.formConfig,
      formData: formData ?? this.formData,
    );
  }
}

class DynamicFormError extends DynamicFormState {
  final String message;
  DynamicFormError(this.message);
}

class DynamicFormValidationError extends DynamicFormState {
  final Map<String, String> errors;
  DynamicFormValidationError(this.errors);
}
