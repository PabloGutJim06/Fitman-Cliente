// main.dart
import 'package:cliente/views/screens/loginScreen.dart';
import 'package:cliente/views/screens/splash_screen.dart'; // 1. IMPORTAMOS TU SPLASH
import 'package:flutter/material.dart';
import 'views/screens/main_navigation_screem.dart';
import 'package:provider/provider.dart';
import 'viewmodels/login_viewmodel.dart';
import 'viewmodels/routine_viewmodel.dart';
import 'viewmodels/login_viewmodel.dart';
import 'viewmodels/routine_viewmodel.dart';
import 'viewmodels/profile_viewmodel.dart'; // ¡El nuevo cañón!
import 'viewmodels/registro_viewmodel.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LoginViewModel()),
        ChangeNotifierProvider(create: (_) => RoutineViewModel()),
        ChangeNotifierProvider(create: (_) => ProfileViewModel()),
        ChangeNotifierProvider(create: (_) => RegistroViewModel()),
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
      // 2. CAMBIO MÍNIMO: Definimos la Splash como inicio y las rutas para que sepa a dónde ir
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),        // Pantalla de inicio
        '/login': (context) => const LoginScreen(),    // Dirección del Login
        '/home': (context) => const MainNavigationScreen(), // Dirección de la Home
      },
    );
  }
}