// views/screens/login_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/login_viewmodel.dart';
import '../screens/main_navigation_screem.dart'; // Recuerda corregir este typo algún día ;)
// ¡IMPACTO! Aquí traemos nuestras balas de pintura:
import '../../theme/app_colors.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // 1. Los Controladores: ¡Nuestra munición!
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    // ¡REGLA DE ORO! Siempre libera los controladores para evitar fugas de memoria
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    final viewModel = context.read<LoginViewModel>();

    // Disparamos el login
    final success = await viewModel.login(
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );

    if (success && mounted) {
      // Hissatsu: ¡Navegación sin retorno!
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
      );
    } else if (mounted) {
      // Si falla, disparamos nuestra bomba de humo roja centralizada
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('¡Error de acceso! Revisa tus credenciales, pirata.',
              style: Theme.of(context).textTheme.bodyLarge),
          backgroundColor: AppColors.error, // Antes: Colors.redAccent
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<LoginViewModel>().isLoading;
    // ¡Sacamos el catalejo! Obtenemos el tema una sola vez
    final theme = Theme.of(context);

    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: Container(
              width: constraints.maxWidth,
              height: constraints.maxHeight,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  // Reemplazamos grises quemados por nuestro sistema
                  colors: [AppColors.surfaceLight, AppColors.background],
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Pasamos el tema a nuestro widget extractor
                    _buildHeader(theme),
                    const SizedBox(height: 60),

                    // Input de Email
                    _buildTextField(
                      controller: _emailController,
                      hint: 'Email',
                      icon: Icons.email,
                      theme: theme,
                    ),
                    const SizedBox(height: 20),

                    // Input de Password
                    _buildTextField(
                      controller: _passwordController,
                      hint: 'Contraseña',
                      icon: Icons.lock,
                      isPassword: true,
                      theme: theme,
                    ),
                    const SizedBox(height: 40),

                    // Botón de Entrada Dinámico
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : _handleLogin,
                        style: ElevatedButton.styleFrom(
                          // Disparamos con el color de marca (Neón).
                          // Si prefieres el verde oscuro clásico, usa AppColors.success
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: isLoading
                            ? const CircularProgressIndicator(color: AppColors.background) // Círculo oscuro para verse en el neón
                            : Text(
                          'ENTRAR',
                          // Hacemos que la tipografía herede y modifique lo mínimo
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: AppColors.background, // Texto oscuro para contrastar con el neón
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // Widget auxiliar: Se le pasa ThemeData para no buscar en el context inútilmente
  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    required ThemeData theme,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      style: theme.textTheme.bodyLarge,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: AppColors.textSecondary),
        hintText: hint,
        hintStyle: theme.textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
        filled: true,
        fillColor: AppColors.textPrimary.withOpacity(0.1), // Transparencia usando color central
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            // ¡HISSATSU FIX! En BoxDecoration se usa 'color', no 'backgroundColor'
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(15),
          ),
          child: const Icon(Icons.fitness_center, size: 50, color: AppColors.background),
        ),
        const SizedBox(height: 20),
        Text('FitMan', style: theme.textTheme.displayLarge?.copyWith(fontSize: 48, fontWeight: FontWeight.w900)),
      ],
    );
  }
}