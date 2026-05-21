// main.dart
import 'package:cliente/viewmodels/edit_profile_viewmodel.dart';
import 'package:cliente/views/screens/loginScreen.dart';
import 'package:cliente/views/screens/splash_screen.dart';
import 'package:flutter/material.dart';
import 'views/screens/main_navigation_screem.dart';
import 'package:provider/provider.dart';
import 'viewmodels/login_viewmodel.dart';
import 'viewmodels/routine_viewmodel.dart';
import 'viewmodels/profile_viewmodel.dart';
import 'viewmodels/registro_viewmodel.dart';
import 'viewmodels/register_viewmodel.dart';
import 'viewmodels/ejercicio_viewmodel.dart';
import 'theme/app_theme.dart';
import 'services/hive_service.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await HiveService.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LoginViewModel()),
        ChangeNotifierProvider(create: (_) => RoutineViewModel()),
        ChangeNotifierProvider(create: (_) => ProfileViewModel()),
        ChangeNotifierProvider(create: (_) => RegistroViewModel()),
        ChangeNotifierProvider(create: (_) => RegisterViewModel()),
        ChangeNotifierProvider(create: (_) => EditProfileViewModel()),
        ChangeNotifierProvider(create: (_) => EjercicioViewModel()),

      ],
      child: const FitManApp(),
    ),
  );
}

class FitManApp extends StatelessWidget {
  const FitManApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FitMan',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),        // Pantalla de inicio
        '/login': (context) => const LoginScreen(),    // Dirección del Login
        '/home': (context) => const MainNavigationScreen(), // Dirección de la Home
      },
    );
  }
}