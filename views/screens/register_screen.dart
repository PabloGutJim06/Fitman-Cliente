import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/register_viewmodel.dart';
import '../../viewmodels/login_viewmodel.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final PageController _pageController = PageController();
  int _paginaActual = 0;
  static const int _totalPasos = 4;

  final _nombreCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  final _edadCtrl = TextEditingController();
  final _pesoCtrl = TextEditingController();
  final _alturaCtrl = TextEditingController();

  @override
  void dispose() {
    _pageController.dispose();
    _nombreCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _edadCtrl.dispose();
    _pesoCtrl.dispose();
    _alturaCtrl.dispose();
    super.dispose();
  }

  void _irA(int pagina) {
    _pageController.animateToPage(
      pagina,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
    setState(() => _paginaActual = pagina);
  }

  void _siguiente() {
    if (_paginaActual < _totalPasos - 1) _irA(_paginaActual + 1);
  }

  void _anterior() {
    if (_paginaActual > 0) _irA(_paginaActual - 1);
  }

  Future<void> _registrar() async {
    final vm = context.read<RegisterViewModel>();
    final loginVM = context.read<LoginViewModel>();

    final success = await vm.registrar();
    if (!mounted) return;

    if (success) {
      await loginVM.login(vm.email.trim(), vm.password);
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(context, '/home', (_) => false);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(vm.errorMessage ?? 'Error al crear la cuenta'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final vm = context.watch<RegisterViewModel>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Column(
                children: [
                  Row(
                    children: [
                      // Botón atrás
                      if (_paginaActual > 0)
                        IconButton(
                          icon: const Icon(Icons.arrow_back_ios,
                              color: AppColors.textSecondary, size: 20),
                          onPressed: _anterior,
                        )
                      else
                        IconButton(
                          icon: const Icon(Icons.close,
                              color: AppColors.textSecondary, size: 20),
                          onPressed: () => Navigator.pop(context),
                        ),
                      Expanded(
                        child: Text(
                          'Paso ${_paginaActual + 1} de $_totalPasos',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyMedium
                              ?.copyWith(color: AppColors.textMuted),
                        ),
                      ),
                      const SizedBox(width: 48),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TweenAnimationBuilder<double>(
                    tween: Tween(
                      begin: 0,
                      end: (_paginaActual + 1) / _totalPasos,
                    ),
                    duration: const Duration(milliseconds: 400),
                    builder: (context, value, _) => LinearProgressIndicator(
                      value: value,
                      backgroundColor: AppColors.surface,
                      color: AppColors.primary,
                      minHeight: 6,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildPaso1(theme, vm),
                  _buildPaso2(theme, vm),
                  _buildPaso3(theme, vm),
                  _buildPaso4(theme, vm),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaso1(ThemeData theme, RegisterViewModel vm) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          const Icon(Icons.person_outline,
              color: AppColors.primary, size: 48),
          const SizedBox(height: 16),
          Text('Crea tu cuenta',
              style: theme.textTheme.displayLarge
                  ?.copyWith(fontSize: 28, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('Solo necesitas unos segundos',
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: 36),
          _buildCampo(
            controller: _nombreCtrl,
            label: 'Nombre',
            icon: Icons.badge_outlined,
            theme: theme,
            onChanged: (v) => vm.actualizarPaso1(nombre: v),
          ),
          const SizedBox(height: 16),
          _buildCampo(
            controller: _emailCtrl,
            label: 'Email',
            icon: Icons.email_outlined,
            theme: theme,
            tipo: TextInputType.emailAddress,
            onChanged: (v) => vm.actualizarPaso1(email: v),
          ),
          const SizedBox(height: 16),
          _buildCampo(
            controller: _passCtrl,
            label: 'Contraseña (mín. 6 caracteres)',
            icon: Icons.lock_outlined,
            theme: theme,
            esPassword: true,
            onChanged: (v) => vm.actualizarPaso1(password: v),
          ),
          const SizedBox(height: 36),
          _buildBotonSiguiente(
            label: 'CONTINUAR',
            habilitado: vm.paso1Valido,
            onPressed: _siguiente,
            theme: theme,
          ),
        ],
      ),
    );
  }

  Widget _buildPaso2(ThemeData theme, RegisterViewModel vm) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          const Icon(Icons.monitor_weight_outlined,
              color: AppColors.primary, size: 48),
          const SizedBox(height: 16),
          Text('Cuéntanos sobre ti',
              style: theme.textTheme.displayLarge
                  ?.copyWith(fontSize: 28, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('Opcional — puedes completarlo más tarde en tu perfil',
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: 36),
          Row(
            children: [
              Expanded(
                child: _buildCampo(
                  controller: _edadCtrl,
                  label: 'Edad',
                  icon: Icons.cake_outlined,
                  theme: theme,
                  tipo: TextInputType.number,
                  onChanged: (v) => vm.actualizarPaso2(
                    edad: int.tryParse(v),
                    pesoActual: double.tryParse(_pesoCtrl.text),
                    altura: double.tryParse(_alturaCtrl.text),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildCampo(
                  controller: _pesoCtrl,
                  label: 'Peso (kg)',
                  icon: Icons.monitor_weight_outlined,
                  theme: theme,
                  tipo: const TextInputType.numberWithOptions(decimal: true),
                  onChanged: (v) => vm.actualizarPaso2(
                    edad: int.tryParse(_edadCtrl.text),
                    pesoActual: double.tryParse(v),
                    altura: double.tryParse(_alturaCtrl.text),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildCampo(
                  controller: _alturaCtrl,
                  label: 'Altura (cm)',
                  icon: Icons.height_rounded,
                  theme: theme,
                  tipo: const TextInputType.numberWithOptions(decimal: true),
                  onChanged: (v) => vm.actualizarPaso2(
                    edad: int.tryParse(_edadCtrl.text),
                    pesoActual: double.tryParse(_pesoCtrl.text),
                    altura: double.tryParse(v),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 36),
          _buildBotonSiguiente(
            label: 'CONTINUAR',
            habilitado: true,
            onPressed: _siguiente,
            theme: theme,
          ),
          const SizedBox(height: 12),
          Center(
            child: TextButton(
              onPressed: () {
                vm.actualizarPaso2(edad: null, pesoActual: null);
                _siguiente();
              },
              child: Text(
                'Saltar por ahora',
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: AppColors.textMuted),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaso3(ThemeData theme, RegisterViewModel vm) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          const Icon(Icons.flag_outlined, color: AppColors.primary, size: 48),
          const SizedBox(height: 16),
          Text(
            'Personaliza tu experiencia',
            style: theme.textTheme.displayLarge
                ?.copyWith(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text(
            'Puedes cambiarlo cuando quieras desde tu perfil',
            style: theme.textTheme.bodyMedium
                ?.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 28),

          _buildSectionLabel('Tu nivel', theme),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 2.2,
            children: [
              _buildGridNivel(
                valor: 'principiante',
                icono: Icons.directions_walk_rounded,
                titulo: 'Principiante',
                seleccionado: vm.nivel == 'principiante',
                onTap: () => vm.seleccionarNivel(
                  vm.nivel == 'principiante' ? null : 'principiante',
                ),
                theme: theme,
              ),
              _buildGridNivel(
                valor: 'intermedio',
                icono: Icons.directions_run_rounded,
                titulo: 'Intermedio',
                seleccionado: vm.nivel == 'intermedio',
                onTap: () => vm.seleccionarNivel(
                  vm.nivel == 'intermedio' ? null : 'intermedio',
                ),
                theme: theme,
              ),
              _buildGridNivel(
                valor: 'avanzado',
                icono: Icons.sports_martial_arts_rounded,
                titulo: 'Avanzado',
                seleccionado: vm.nivel == 'avanzado',
                onTap: () => vm.seleccionarNivel(
                  vm.nivel == 'avanzado' ? null : 'avanzado',
                ),
                theme: theme,
              ),
              _buildGridNivel(
                valor: 'culturista',
                icono: Icons.emoji_events_rounded,
                titulo: 'Culturista',
                seleccionado: vm.nivel == 'culturista',
                onTap: () => vm.seleccionarNivel(
                  vm.nivel == 'culturista' ? null : 'culturista',
                ),
                theme: theme,
              ),
            ],
          ),

          const SizedBox(height: 28),

          _buildSectionLabel('Tu objetivo', theme),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildGridNivel(
                  valor: 'perder peso',
                  icono: Icons.trending_down_rounded,
                  titulo: 'Perder\npeso',
                  seleccionado: vm.objetivo == 'perder peso',
                  onTap: () => vm.seleccionarObjetivo(
                    vm.objetivo == 'perder peso' ? null : 'perder peso',
                  ),
                  theme: theme,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildGridNivel(
                  valor: 'ganar músculo',
                  icono: Icons.trending_up_rounded,
                  titulo: 'Ganar\nmúsculo',
                  seleccionado: vm.objetivo == 'ganar músculo',
                  onTap: () => vm.seleccionarObjetivo(
                    vm.objetivo == 'ganar músculo' ? null : 'ganar músculo',
                  ),
                  theme: theme,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildGridNivel(
                  valor: 'mantener peso',
                  icono: Icons.balance_rounded,
                  titulo: 'Mantener\npeso',
                  seleccionado: vm.objetivo == 'mantener peso',
                  onTap: () => vm.seleccionarObjetivo(
                    vm.objetivo == 'mantener peso' ? null : 'mantener peso',
                  ),
                  theme: theme,
                ),
              ),
            ],
          ),

          const Spacer(),

          _buildBotonSiguiente(
            label: 'CONTINUAR',
            habilitado: true,
            onPressed: _siguiente,
            theme: theme,
          ),
          const SizedBox(height: 12),
          Center(
            child: TextButton(
              onPressed: () {
                vm.seleccionarNivel(null);
                vm.seleccionarObjetivo(null);
                _siguiente();
              },
              child: Text(
                'Saltar por ahora',
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: AppColors.textMuted),
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildGridNivel({
    required String valor,
    required IconData icono,
    required String titulo,
    required bool seleccionado,
    required VoidCallback onTap,
    required ThemeData theme,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        decoration: BoxDecoration(
          color: seleccionado
              ? AppColors.primary.withOpacity(0.12)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: seleccionado ? AppColors.primary : Colors.transparent,
            width: 1.5,
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icono,
              color: seleccionado
                  ? AppColors.primary
                  : AppColors.textSecondary,
              size: 22,
            ),
            const SizedBox(height: 6),
            Text(
              titulo,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 11,
                color: seleccionado
                    ? AppColors.primary
                    : AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String label, ThemeData theme) {
    return Text(
      label.toUpperCase(),
      style: theme.textTheme.bodyMedium?.copyWith(
        color: AppColors.textMuted,
        fontSize: 11,
        letterSpacing: 1.2,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildCardSeleccionable({
    required String valor,
    required IconData icono,
    required String titulo,
    required String subtitulo,
    required bool seleccionado,
    required VoidCallback onTap,
    required ThemeData theme,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: seleccionado
              ? AppColors.primary.withOpacity(0.12)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: seleccionado ? AppColors.primary : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icono,
              color: seleccionado
                  ? AppColors.primary
                  : AppColors.textSecondary,
              size: 28,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titulo,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: seleccionado
                          ? AppColors.primary
                          : AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    subtitulo,
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(color: AppColors.textMuted),
                  ),
                ],
              ),
            ),
            AnimatedOpacity(
              opacity: seleccionado ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 200),
              child: const Icon(Icons.check_circle,
                  color: AppColors.primary, size: 20),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaso4(ThemeData theme, RegisterViewModel vm) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          const Icon(Icons.check_circle_outline,
              color: AppColors.primary, size: 48),
          const SizedBox(height: 16),
          Text('Todo listo, ${vm.nombre.split(' ').first}',
              style: theme.textTheme.displayLarge?.copyWith(
                  fontSize: 28, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('Confirma tus datos antes de crear la cuenta',
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: 32),

          // Resumen
          _buildResumenTile(Icons.badge_outlined, 'Nombre', vm.nombre, theme),
          _buildResumenTile(Icons.email_outlined, 'Email', vm.email, theme),
          if (vm.edad != null)
            _buildResumenTile(
                Icons.cake_outlined, 'Edad', '${vm.edad} años', theme),
          if (vm.pesoActual != null)
            _buildResumenTile(Icons.fitness_center, 'Peso',
                '${vm.pesoActual} kg', theme),
          if (vm.objetivo != null)
            _buildResumenTile(
                Icons.flag_outlined, 'Objetivo', vm.objetivo!, theme),
          if (vm.nivel != null)
            _buildResumenTile(
              Icons.bar_chart_rounded,
              'Nivel',
              _capitalizarPrimera(vm.nivel!),
              theme,
            ),
          if (vm.objetivo != null)
            _buildResumenTile(
              Icons.flag_outlined,
              'Objetivo',
              _capitalizarPrimera(vm.objetivo!),
              theme,
            ),
          const Spacer(),

          // Botón crear cuenta
          Consumer<RegisterViewModel>(
            builder: (context, vm, _) => SizedBox(
              width: double.infinity,
              height: 58,
              child: OutlinedButton(
                style: AppTheme.primaryButtonStyle,
                onPressed: vm.isLoading ? null : _registrar,
                child: vm.isLoading
                    ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: AppColors.background),
                )
                    : Text(
                  'CREAR CUENTA',
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResumenTile(
      IconData icon, String label, String value, ThemeData theme) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.textSecondary, size: 18),
          const SizedBox(width: 12),
          Text(label,
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: AppColors.textSecondary)),
          const Spacer(),
          Text(value,
              style: theme.textTheme.bodyLarge
                  ?.copyWith(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildCampo({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required ThemeData theme,
    TextInputType tipo = TextInputType.text,
    bool esPassword = false,
    required ValueChanged<String> onChanged,
  }) {
    return TextField(
      controller: controller,
      obscureText: esPassword,
      keyboardType: tipo,
      style: theme.textTheme.bodyLarge,
      onChanged: onChanged,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: AppColors.textSecondary, size: 20),
        labelText: label,
        labelStyle: theme.textTheme.bodyMedium
            ?.copyWith(color: AppColors.textSecondary),
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
          const BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
    );
  }

  Widget _buildBotonSiguiente({
    required String label,
    required bool habilitado,
    required VoidCallback onPressed,
    required ThemeData theme,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 58,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor:
          habilitado ? AppColors.primary : AppColors.surface,
          foregroundColor:
          habilitado ? AppColors.background : AppColors.textMuted,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16)),
        ),
        onPressed: habilitado ? onPressed : null,
        child: Text(
          label,
          style: theme.textTheme.labelLarge
              ?.copyWith(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
    );
  }
  String _capitalizarPrimera(String texto) =>
      texto.isEmpty ? texto : texto[0].toUpperCase() + texto.substring(1);
}