enum FormFieldType {
  text,
  email,
  phone,
  number,
  textarea,
  select,
  date,
  file,
}

class FormValidation {
  final int? minLength;
  final int? maxLength;
  final String? pattern;
  final String? errorMessage;

  const FormValidation({
    this.minLength,
    this.maxLength,
    this.pattern,
    this.errorMessage,
  });

  factory FormValidation.fromJson(Map<String, dynamic> json) {
    return FormValidation(
      minLength: json['minLength'],
      maxLength: json['maxLength'],
      pattern: json['pattern'],
      errorMessage: json['errorMessage'],
    );
  }
}

class FormFieldModel {
  final String id;
  final String label;
  final FormFieldType type;
  final String? placeholder;
  final String? helpText;
  final bool required;
  final List<String>? options; // For select fields
  final FormValidation? validation;
  final int order;

  const FormFieldModel({
    required this.id,
    required this.label,
    required this.type,
    this.placeholder,
    this.helpText,
    this.required = false,
    this.options,
    this.validation,
    required this.order,
  });

  factory FormFieldModel.fromJson(Map<String, dynamic> json) {
    return FormFieldModel(
      id: json['id'],
      label: json['label'],
      type: FormFieldType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => FormFieldType.text,
      ),
      placeholder: json['placeholder'],
      helpText: json['helpText'],
      required: json['required'] ?? false,
      options:
          json['options'] != null ? List<String>.from(json['options']) : null,
      validation: json['validation'] != null
          ? FormValidation.fromJson(json['validation'])
          : null,
      order: json['order'] ?? 0,
    );
  }
}

class FormConfigModel {
  final String id;
  final String institutionId;
  final String title;
  final String? description;
  final List<FormFieldModel> fields;

  const FormConfigModel({
    required this.id,
    required this.institutionId,
    required this.title,
    this.description,
    required this.fields,
  });

  factory FormConfigModel.fromJson(Map<String, dynamic> json) {
    return FormConfigModel(
      id: json['id'],
      institutionId: json['institutionId'],
      title: json['title'],
      description: json['description'],
      fields: (json['fields'] as List)
          .map((field) => FormFieldModel.fromJson(field))
          .toList()
        ..sort((a, b) => a.order.compareTo(b.order)),
    );
  }
}
