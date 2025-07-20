abstract class DynamicFormEvent {}

class DynamicFormLoadRequested extends DynamicFormEvent {
  final String institutionId;
  DynamicFormLoadRequested(this.institutionId);
}

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

class DynamicFormReset extends DynamicFormEvent {}
