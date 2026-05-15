// views/screens/splash_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/login_viewmodel.dart';
// ¡HISSATSU! Nuestra paleta de colores de la Gran Flota
import '../../theme/app_colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Como vigías en la noche, comprobamos el horizonte (sesión)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAuth();
    });
  }

  Future<void> _checkAuth() async {
    final loginVM = Provider.of<LoginViewModel>(context, listen: false);
    bool hasSession = await loginVM.checkSession();

    if (!mounted) return;

    if (hasSession) {
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    // ¡IMPACTO DE CONSTANTES!
    // Como AppColors.background y AppColors.primary son constantes,
    // podemos añadir 'const' a todo el Scaffold. ¡Rendimiento máximo!
    return const Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ¡El relámpago de neón centralizado!
            Icon(
              Icons.flash_on,
              size: 100,
              color: AppColors.primary, // Antes Color(0xFFADFF2F)
            ),
            SizedBox(height: 20),
            // Forma moderna y limpia de aplicar color al indicador
            CircularProgressIndicator(
              color: AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }
}