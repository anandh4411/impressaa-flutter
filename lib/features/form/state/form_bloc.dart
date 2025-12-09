import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/form_models.dart';
import '../data/form_api_service.dart';
import '../../../core/storage/auth_storage.dart';
import '../../../core/network/models/api_error.dart';
import 'form_event.dart';
import 'form_state.dart';

class DynamicFormBloc extends Bloc<DynamicFormEvent, DynamicFormState> {
  final FormApiService formApiService;
  final AuthStorage authStorage;

  DynamicFormBloc({
    required this.formApiService,
    required this.authStorage,
  }) : super(DynamicFormInitial()) {
    on<DynamicFormLoadRequested>(_onLoadRequested);
    on<DynamicFormFieldChanged>(_onFieldChanged);
    on<DynamicFormValidationRequested>(_onValidationRequested);
    on<DynamicFormPreviewRequested>(_onPreviewRequested);
    on<DynamicFormSubmitted>(_onSubmitted);
    on<DynamicFormReset>(_onReset);
  }

  Future<void> _onLoadRequested(
    DynamicFormLoadRequested event,
    Emitter<DynamicFormState> emit,
  ) async {
    emit(DynamicFormLoading());

    try {
      // Call real API to get form
      final formResponse = await formApiService.getForm();

      // Initialize form data with prefilled values
      final initialFormData = <String, dynamic>{};

      // You could prefill certain fields from formResponse.prefilledData
      // For example: initialFormData['name'] = formResponse.prefilledData.personName;

      emit(DynamicFormLoaded(
        formResponse: formResponse,
        formData: initialFormData,
      ));
    } on ApiException catch (e) {
      emit(DynamicFormError(e.error.message));
    } catch (e) {
      emit(DynamicFormError('Failed to load form'));
    }
  }

  void _onFieldChanged(
    DynamicFormFieldChanged event,
    Emitter<DynamicFormState> emit,
  ) {
    if (state is DynamicFormLoaded) {
      final currentState = state as DynamicFormLoaded;
      final updatedFormData = Map<String, dynamic>.from(currentState.formData);
      updatedFormData[event.fieldId] = event.value;

      emit(currentState.copyWith(formData: updatedFormData));
    }
  }

  void _onValidationRequested(
    DynamicFormValidationRequested event,
    Emitter<DynamicFormState> emit,
  ) {
    if (state is DynamicFormLoaded) {
      final currentState = state as DynamicFormLoaded;
      final errors = _validateForm(currentState.fields, currentState.formData);

      if (errors.isNotEmpty) {
        emit(DynamicFormValidationError(errors));
      }
    }
  }

  void _onPreviewRequested(
    DynamicFormPreviewRequested event,
    Emitter<DynamicFormState> emit,
  ) {
    if (state is DynamicFormLoaded) {
      final currentState = state as DynamicFormLoaded;
      final errors = _validateForm(currentState.fields, currentState.formData);

      if (errors.isNotEmpty) {
        emit(DynamicFormValidationError(errors));
      } else {
        // Form is valid, proceed to preview
        // This will be handled by the UI to navigate to preview page
      }
    }
  }

  Future<void> _onSubmitted(
    DynamicFormSubmitted event,
    Emitter<DynamicFormState> emit,
  ) async {
    if (state is! DynamicFormLoaded) return;

    final currentState = state as DynamicFormLoaded;

    // Validate before submission
    final errors = _validateForm(currentState.fields, currentState.formData);
    if (errors.isNotEmpty) {
      emit(DynamicFormValidationError(errors));
      return;
    }

    emit(DynamicFormSubmitting());

    try {
      // Submit form to API
      final response = await formApiService.submitForm(currentState.formData);

      emit(DynamicFormSubmitSuccess(response));

      // Auto-logout after successful submission
      final refreshToken = authStorage.getRefreshToken();
      if (refreshToken != null) {
        // Note: AuthApiService logout would need to be called here
        // but we don't have access to it in this BLoC
        // Instead, we'll just clear local auth and let the app router handle it
        await authStorage.clearAuth();
      }
    } on ApiException catch (e) {
      emit(DynamicFormSubmitError(e.error.message));
      // Return to loaded state so user can try again
      emit(currentState);
    } catch (e) {
      emit(DynamicFormSubmitError('Form submission failed. Please try again.'));
      emit(currentState);
    }
  }

  void _onReset(DynamicFormReset event, Emitter<DynamicFormState> emit) {
    emit(DynamicFormInitial());
  }

  Map<String, String> _validateForm(
    List<FormFieldModel> fields,
    Map<String, dynamic> formData,
  ) {
    final errors = <String, String>{};

    for (final field in fields) {
      // Skip file type fields - they are validated separately in the UI
      if (field.type == FormFieldType.file) {
        continue;
      }

      final value = formData[field.id.toString()];

      // Required field validation
      if (field.required &&
          (value == null || value.toString().trim().isEmpty)) {
        errors[field.id.toString()] = '${field.label} is required';
        continue;
      }

      // Skip further validation if field is empty and not required
      if (value == null || value.toString().trim().isEmpty) continue;

      // Type-specific validation
      final error = _validateFieldValue(field, value);
      if (error != null) {
        errors[field.id.toString()] = error;
      }
    }

    return errors;
  }

  String? _validateFieldValue(FormFieldModel field, dynamic value) {
    final stringValue = value.toString();

    // Length validation
    if (field.validation?.minLength != null &&
        stringValue.length < field.validation!.minLength!) {
      return 'Minimum ${field.validation!.minLength} characters required';
    }

    if (field.validation?.maxLength != null &&
        stringValue.length > field.validation!.maxLength!) {
      return 'Maximum ${field.validation!.maxLength} characters allowed';
    }

    // Type-specific validation
    switch (field.type) {
      case FormFieldType.email:
        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
            .hasMatch(stringValue)) {
          return 'Please enter a valid email address';
        }
        break;
      case FormFieldType.phone:
        if (!RegExp(r'^\+?[\d\s\-\(\)]{10,}$').hasMatch(stringValue)) {
          return 'Please enter a valid phone number';
        }
        break;
      case FormFieldType.number:
        if (double.tryParse(stringValue) == null) {
          return 'Please enter a valid number';
        }
        break;
      default:
        break;
    }

    return null;
  }
}
