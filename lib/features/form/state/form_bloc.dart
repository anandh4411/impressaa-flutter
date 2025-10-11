import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/form_models.dart';
import 'form_event.dart';
import 'form_state.dart';

class DynamicFormBloc extends Bloc<DynamicFormEvent, DynamicFormState> {
  DynamicFormBloc() : super(DynamicFormInitial()) {
    on<DynamicFormLoadRequested>(_onLoadRequested);
    on<DynamicFormFieldChanged>(_onFieldChanged);
    on<DynamicFormValidationRequested>(_onValidationRequested);
    on<DynamicFormPreviewRequested>(_onPreviewRequested);
    on<DynamicFormReset>(_onReset);
  }

  Future<void> _onLoadRequested(
    DynamicFormLoadRequested event,
    Emitter<DynamicFormState> emit,
  ) async {
    emit(DynamicFormLoading());

    try {
      // Simulate API call - replace with actual API
      await Future.delayed(const Duration(seconds: 1));

      // Mock form configuration
      final mockFormConfig = _getMockFormConfig(event.institutionId);

      emit(DynamicFormLoaded(formConfig: mockFormConfig));
    } catch (e) {
      emit(DynamicFormError('Failed to load form configuration'));
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
      final errors =
          _validateForm(currentState.formConfig, currentState.formData);

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
      final errors =
          _validateForm(currentState.formConfig, currentState.formData);

      if (errors.isNotEmpty) {
        emit(DynamicFormValidationError(errors));
      } else {
        // Form is valid, proceed to preview
        // This will be handled by the UI to navigate to preview page
      }
    }
  }

  void _onReset(DynamicFormReset event, Emitter<DynamicFormState> emit) {
    emit(DynamicFormInitial());
  }

  Map<String, String> _validateForm(
    FormConfigModel formConfig,
    Map<String, dynamic> formData,
  ) {
    final errors = <String, String>{};

    for (final field in formConfig.fields) {
      final value = formData[field.id];

      // Required field validation
      if (field.required &&
          (value == null || value.toString().trim().isEmpty)) {
        errors[field.id] = '${field.label} is required';
        continue;
      }

      // Skip further validation if field is empty and not required
      if (value == null || value.toString().trim().isEmpty) continue;

      // Type-specific validation
      final error = _validateFieldValue(field, value);
      if (error != null) {
        errors[field.id] = error;
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

  // Mock data for testing - replace with actual API call
  FormConfigModel _getMockFormConfig(String institutionId) {
    return FormConfigModel(
      id: 'form_1',
      institutionId: institutionId,
      title: 'Student ID Card Application',
      description: 'Please fill out all required information for your ID card',
      fields: [
        const FormFieldModel(
          id: 'full_name',
          label: 'Full Name',
          type: FormFieldType.text,
          placeholder: 'Enter your full name',
          required: true,
          validation: FormValidation(minLength: 2, maxLength: 50),
          order: 1,
        ),
        const FormFieldModel(
          id: 'email',
          label: 'Email Address',
          type: FormFieldType.email,
          placeholder: 'Enter your email',
          required: true,
          order: 2,
        ),
        const FormFieldModel(
          id: 'phone',
          label: 'Phone Number',
          type: FormFieldType.phone,
          placeholder: '+1 (555) 123-4567',
          required: true,
          order: 3,
        ),
        const FormFieldModel(
          id: 'class',
          label: 'Class/Department',
          type: FormFieldType.select,
          required: true,
          options: ['10A', '10B', '11A', '11B', '12A', '12B'],
          order: 4,
        ),
        const FormFieldModel(
          id: 'address',
          label: 'Address',
          type: FormFieldType.textarea,
          placeholder: 'Enter your complete address',
          helpText: 'Please provide your current residential address',
          required: false,
          order: 5,
        ),
      ],
    );
  }
}
