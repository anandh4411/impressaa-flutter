import '../../../core/network/api_client.dart';
import '../../../core/network/models/api_response.dart';
import 'form_models.dart';

class FormApiService {
  final ApiClient apiClient;

  FormApiService(this.apiClient);

  /// Get form with fields and prefilled data
  Future<FormApiResponse> getForm() async {
    final response = await apiClient.get('/mobile/form');

    final apiResponse = ApiResponse.fromJson(
      response.data,
      (data) => FormApiResponse.fromJson(data),
    );

    if (!apiResponse.success || apiResponse.data == null) {
      throw Exception(apiResponse.message ?? 'Failed to load form');
    }

    return apiResponse.data!;
  }

  /// Submit form data
  Future<FormSubmissionResponse> submitForm(
      Map<String, dynamic> formData) async {
    final response = await apiClient.post(
      '/mobile/form/submit',
      data: {'formData': formData},
    );

    final apiResponse = ApiResponse.fromJson(
      response.data,
      (data) => FormSubmissionResponse.fromJson(data),
    );

    if (!apiResponse.success || apiResponse.data == null) {
      throw Exception(apiResponse.message ?? 'Form submission failed');
    }

    return apiResponse.data!;
  }
}
