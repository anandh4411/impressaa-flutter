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
  final dynamic id; // Can be int or String from API
  final String uuid;
  final String label;
  final FormFieldType type;
  final String? placeholder;
  final String? helpText;
  final bool required;
  final List<String>? options; // For select fields
  final FormValidation? validation;
  final String? defaultValue;
  final int order;
  final String? aspectRatio; // For file/image fields (e.g., "35:45")

  const FormFieldModel({
    required this.id,
    required this.uuid,
    required this.label,
    required this.type,
    this.placeholder,
    this.helpText,
    this.required = false,
    this.options,
    this.validation,
    this.defaultValue,
    required this.order,
    this.aspectRatio,
  });

  factory FormFieldModel.fromJson(Map<String, dynamic> json) {
    return FormFieldModel(
      id: json['id'],
      uuid: json['uuid'] ?? '',
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
      defaultValue: json['defaultValue'],
      order: json['order'] ?? 0,
      aspectRatio: json['aspectRatio'],
    );
  }
}

class FormConfigModel {
  final dynamic id; // Can be int or String from API
  final String uuid;
  final String name;
  final String? description;
  final String? institutionName;

  const FormConfigModel({
    required this.id,
    required this.uuid,
    required this.name,
    this.description,
    this.institutionName,
  });

  factory FormConfigModel.fromJson(Map<String, dynamic> json) {
    return FormConfigModel(
      id: json['id'],
      uuid: json['uuid'] ?? '',
      name: json['name'],
      description: json['description'],
      institutionName: json['institutionName'],
    );
  }
}

/// Prefilled data from API
class PrefilledData {
  final String personName;

  PrefilledData({required this.personName});

  factory PrefilledData.fromJson(Map<String, dynamic> json) {
    return PrefilledData(
      personName: json['personName'] ?? '',
    );
  }
}

/// Form response from API (GET /mobile/form)
class FormApiResponse {
  final FormConfigModel? form;
  final List<FormFieldModel> fields;
  final PrefilledData prefilledData;

  FormApiResponse({
    this.form,
    required this.fields,
    required this.prefilledData,
  });

  factory FormApiResponse.fromJson(Map<String, dynamic> json) {
    return FormApiResponse(
      form: json['form'] != null
          ? FormConfigModel.fromJson(json['form'])
          : null,
      fields: (json['fields'] as List? ?? [])
          .map((field) => FormFieldModel.fromJson(field))
          .toList(),
      prefilledData: PrefilledData.fromJson(json['prefilledData'] ?? {}),
    );
  }
}

/// Form submission response
class FormSubmissionResponse {
  final String submissionUuid;
  final String status;
  final String submittedAt;

  FormSubmissionResponse({
    required this.submissionUuid,
    required this.status,
    required this.submittedAt,
  });

  factory FormSubmissionResponse.fromJson(Map<String, dynamic> json) {
    return FormSubmissionResponse(
      submissionUuid: json['submissionUuid'],
      status: json['status'],
      submittedAt: json['submittedAt'],
    );
  }
}
