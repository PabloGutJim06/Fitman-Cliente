// views/main_navigation_screen.dart
import 'package:cliente/views/screens/profileScreen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'my_routines_screen.dart';
// ✅ NUEVO: importamos la pantalla de historial
import 'historial_screen.dart';
import '../../viewmodels/routine_viewmodel.dart';
import '../../viewmodels/profile_viewmodel.dart';
// ✅ NUEVO: importamos el RegistroViewModel
import '../../viewmodels/registro_viewmodel.dart';
import '../../services/auth_service.dart';
import '../../theme/app_colors.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _fetchDatosIniciales();
  }

  Future<void> _fetchDatosIniciales() async {
    final token = await AuthService().getStoredToken();
    if (token != null && mounted) {
      // Lanzamos las tres cargas — rutinas, perfil y registros
      Provider.of<RoutineViewModel>(context, listen: false).loadRoutines(token);
      // ✅ NUEVO: cargamos registros al arrancar para que los chips
      // del historial y el perfil ya tengan datos desde el primer frame
      Provider.of<RegistroViewModel>(context, listen: false).loadRegistros(token);
      try {
        await Provider.of<ProfileViewModel>(context, listen: false)
            .loadUserProfile(token);
        if (Provider.of<ProfileViewModel>(context, listen: false).user == null) {
          _volverAlLogin();
        }
      } catch (e) {
        _volverAlLogin();
      }
    } else {
      _volverAlLogin();
    }
  }

  void _volverAlLogin() {
    if (mounted) {
      AuthService().logout();
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final List<Widget> screens = [
      const MyRoutinesScreen(),
      // ✅ Sustituimos el placeholder por la pantalla real
      const HistorialScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: theme.colorScheme.primary,
        unselectedItemColor: AppColors.textMuted,
        backgroundColor: AppColors.surface,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.fitness_center),
            label: 'Rutinas',
          ),
          // ✅ Icono y label actualizados — ya no es "Ejercicios"
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'Historial',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}