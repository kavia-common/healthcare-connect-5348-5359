import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'services/api_client.dart';
import 'services/auth_service.dart';
import 'providers/auth_provider.dart';
import 'providers/consultations_provider.dart';
import 'providers/medical_records_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');

  final apiClient = ApiClient();
  final authService = AuthService(apiClient);

  final authProvider = AuthProvider(authService);
  await authProvider.initialize();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
        ChangeNotifierProvider(create: (_) => ConsultationsProvider(apiClient)),
        ChangeNotifierProvider(create: (_) => MedicalRecordsProvider(apiClient)),
      ],
      child: const RootApp(),
    ),
  );
}
