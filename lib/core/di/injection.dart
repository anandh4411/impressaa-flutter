import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../storage/auth_storage.dart';
import '../network/api_client.dart';
import '../../features/auth/data/auth_api_service.dart';
import '../../features/form/data/form_api_service.dart';

final getIt = GetIt.instance;

Future<void> setupDependencies() async {
  // Core dependencies
  final sharedPreferences = await SharedPreferences.getInstance();
  getIt.registerSingleton<SharedPreferences>(sharedPreferences);

  // Auth Storage
  getIt.registerSingleton<AuthStorage>(AuthStorage(sharedPreferences));

  // API Client with token expiry callback
  getIt.registerSingleton<ApiClient>(
    ApiClient(
      authStorage: getIt<AuthStorage>(),
      onTokenExpired: () async {
        // Clear auth data when token expires
        await getIt<AuthStorage>().clearAuth();
        // Note: Navigation to login will be handled by the app router
      },
    ),
  );

  // API Services
  getIt.registerSingleton<AuthApiService>(
    AuthApiService(getIt<ApiClient>()),
  );
  getIt.registerSingleton<FormApiService>(
    FormApiService(getIt<ApiClient>()),
  );
}
