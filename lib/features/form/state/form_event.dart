abstract class DynamicFormEvent {}

class DynamicFormLoadRequested extends DynamicFormEvent {}

class DynamicFormFieldChanged extends DynamicFormEvent {
  final String fieldId;
  final dynamic value;

  DynamicFormFieldChanged({
    required this.fieldId,
    required this.value,
  });
}

class DynamicFormValidationRequested extends DynamicFormEvent {}

class DynamicFormPreviewRequested extends DynamicFormEvent {}

class DynamicFormSubmitted extends DynamicFormEvent {}

class DynamicFormReset extends DynamicFormEvent {}
