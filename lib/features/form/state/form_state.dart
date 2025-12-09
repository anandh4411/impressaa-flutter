import '../data/form_models.dart';

abstract class DynamicFormState {}

class DynamicFormInitial extends DynamicFormState {}

class DynamicFormLoading extends DynamicFormState {}

class DynamicFormLoaded extends DynamicFormState {
  final FormApiResponse formResponse;
  final Map<String, dynamic> formData;

  DynamicFormLoaded({
    required this.formResponse,
    Map<String, dynamic>? formData,
  }) : formData = formData ?? {};

  // Helper getter for fields
  List<FormFieldModel> get fields => formResponse.fields;

  // Helper getter for form config (might be null)
  FormConfigModel? get formConfig => formResponse.form;

  DynamicFormLoaded copyWith({
    FormApiResponse? formResponse,
    Map<String, dynamic>? formData,
  }) {
    return DynamicFormLoaded(
      formResponse: formResponse ?? this.formResponse,
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

class DynamicFormSubmitting extends DynamicFormState {}

class DynamicFormSubmitSuccess extends DynamicFormState {
  final FormSubmissionResponse response;
  DynamicFormSubmitSuccess(this.response);
}

class DynamicFormSubmitError extends DynamicFormState {
  final String message;
  DynamicFormSubmitError(this.message);
}
