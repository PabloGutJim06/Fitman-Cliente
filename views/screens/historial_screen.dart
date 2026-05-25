import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../models/registro_model.dart';
import '../../viewmodels/registro_viewmodel.dart';
import '../../services/auth_service.dart';
import '../../theme/app_colors.dart';
import 'dart:async';
import '../../services/connectivity_service.dart';
import '../../services/sync_service.dart';

class HistorialScreen extends StatefulWidget {
  const HistorialScreen({super.key});

  @override
  State<HistorialScreen> createState() => _HistorialScreenState();
}

class _HistorialScreenState extends State<HistorialScreen> {
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  final ConnectivityService _connectivity = ConnectivityService();
  bool _isOnline = true;
  StreamSubscription<bool>? _connSub;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _cargarRegistros());
    _connectivity.tieneConexion().then((v) {
      if (mounted) setState(() => _isOnline = v);
    });
    _connSub = _connectivity.onConnectivityChanged.listen((online) {
      if (mounted) setState(() => _isOnline = online);
    });
  }

  @override
  void dispose() {
    _connSub?.cancel();
    super.dispose();
  }

  Future<void> _cargarRegistros() async {
    final token = await AuthService().getStoredToken();
    if (token != null && mounted) {
      context.read<RegistroViewModel>().loadRegistros(token);
    }
  }

  DateTime _soloFecha(DateTime dt) => DateTime(dt.year, dt.month, dt.day);
  List<RegistroModel> _eventosDelDia(
      DateTime dia, List<RegistroModel> registros) {
    return registros
        .where((r) => isSameDay(_soloFecha(r.fecha), _soloFecha(dia)))
        .toList();
  }

  List<RegistroModel> _registrosSeleccionados(
      List<RegistroModel> registros) {
    return registros
        .where((r) => isSameDay(_soloFecha(r.fecha), _soloFecha(_selectedDay)))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<RegistroViewModel>(
      builder: (context, registroVM, _) {
        final seleccionados = _registrosSeleccionados(registroVM.registros);

        return Scaffold(
          body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [AppColors.surfaceLight, AppColors.background],
              ),
            ),
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Cabecera con título y chips
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Historial',
                          style: Theme.of(context)
                              .textTheme
                              .displayLarge
                              ?.copyWith(fontSize: 28),
                        ),
                        const SizedBox(height: 8),
                        _buildResumenChips(registroVM, context),
                        if (!_isOnline) ...[
                          const SizedBox(height: 10),
                          _buildOfflineBanner(context),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Calendario
                  _buildCalendario(registroVM),
                  const SizedBox(height: 8),

                  // Divisor con la fecha seleccionada
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        const Icon(Icons.event,
                            size: 14, color: AppColors.textMuted),
                        const SizedBox(width: 6),
                        Text(
                          _formatFechaSeleccionada(_selectedDay),
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(color: AppColors.textMuted),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Lista de registros del día seleccionado
                  Expanded(
                    child: registroVM.isLoading
                        ? const Center(
                      child: CircularProgressIndicator(
                          color: AppColors.primary),
                    )
                        : registroVM.errorMessage != null
                        ? _buildErrorState(
                        registroVM.errorMessage!, context)
                        : seleccionados.isEmpty
                        ? _buildEmptyDayState(context)
                        : ListView.builder(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20),
                      itemCount: seleccionados.length,
                      itemBuilder: (context, index) =>
                          _buildRegistroItem(
                              seleccionados[index], context),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCalendario(RegistroViewModel vm) {
    final theme = Theme.of(context);

    return TableCalendar<RegistroModel>(
      firstDay: DateTime(DateTime.now().year - 2, 1, 1),
      lastDay: DateTime(DateTime.now().year, 12, 31),
      focusedDay: _focusedDay,
      calendarFormat: CalendarFormat.twoWeeks,
      availableCalendarFormats: const {
        CalendarFormat.twoWeeks: '2 semanas',
      },
      selectedDayPredicate: (day) => isSameDay(day, _selectedDay),

      eventLoader: (day) => _eventosDelDia(day, vm.registros),

      onDaySelected: (selectedDay, focusedDay) {
        setState(() {
          _selectedDay = selectedDay;
          _focusedDay = focusedDay;
        });
      },

      onPageChanged: (focusedDay) {
        _focusedDay = focusedDay;
      },

      // Formato de cabecera del calendario
      headerStyle: HeaderStyle(
        formatButtonVisible: false,
        titleCentered: true,
        titleTextStyle: theme.textTheme.bodyLarge!.copyWith(
          fontWeight: FontWeight.bold,
        ),
        leftChevronIcon: const Icon(
          Icons.chevron_left,
          color: AppColors.primary,
        ),
        rightChevronIcon: const Icon(
          Icons.chevron_right,
          color: AppColors.primary,
        ),
        headerPadding: const EdgeInsets.symmetric(vertical: 8),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
        ),
      ),

      // Estilo de los días
      calendarStyle: CalendarStyle(
        // Día de hoy
        todayDecoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.25),
          shape: BoxShape.circle,
        ),
        todayTextStyle: const TextStyle(
          color: AppColors.primary,
          fontWeight: FontWeight.bold,
        ),

        // Día seleccionado
        selectedDecoration: const BoxDecoration(
          color: AppColors.primary,
          shape: BoxShape.circle,
        ),
        selectedTextStyle: const TextStyle(
          color: AppColors.background,
          fontWeight: FontWeight.bold,
        ),

        // Días normales
        defaultTextStyle: const TextStyle(color: AppColors.textPrimary),
        weekendTextStyle:
        const TextStyle(color: AppColors.textSecondary),
        outsideTextStyle:
        const TextStyle(color: AppColors.textMuted),

        markerDecoration: const BoxDecoration(
          color: AppColors.primary,
          shape: BoxShape.circle,
        ),
        markerSize: 5.0,
        markersMaxCount: 1,

        isTodayHighlighted: true,
        cellMargin: const EdgeInsets.all(4),
      ),

      // Fondo del calendario
      calendarBuilders: CalendarBuilders(
      ),

      daysOfWeekStyle: DaysOfWeekStyle(
        weekdayStyle: theme.textTheme.bodyMedium!.copyWith(
          color: AppColors.textSecondary,
          fontSize: 12,
        ),
        weekendStyle: theme.textTheme.bodyMedium!.copyWith(
          color: AppColors.textMuted,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildOfflineBanner(BuildContext context) {
    final theme = Theme.of(context);
    final pendientes = SyncService().totalPendientes;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
            color: AppColors.textMuted.withOpacity(0.25)),
      ),
      child: Row(
        children: [
          const Icon(Icons.wifi_off_rounded,
              color: AppColors.textMuted, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              pendientes > 0
                  ? 'Sin conexión · $pendientes ${pendientes == 1 ? 'entrenamiento' : 'entrenamientos'} se sincronizarán automáticamente'
                  : 'Sin conexión · Mostrando historial guardado',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.textMuted,
                fontSize: 10,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResumenChips(RegistroViewModel vm, BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        _buildChip(
          icon: Icons.fitness_center,
          label: 'Total',
          value: '${vm.totalEntrenamientos}',
          theme: theme,
        ),
        const SizedBox(width: 12),
        _buildChip(
          icon: Icons.calendar_month,
          label: 'Este mes',
          value: '${vm.esteMes}',
          theme: theme,
        ),
      ],
    );
  }

  Widget _buildChip({
    required IconData icon,
    required String label,
    required String value,
    required ThemeData theme,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 18),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.textMuted,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyDayState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.event_available,
              size: 48, color: AppColors.textSecondary),
          const SizedBox(height: 12),
          Text(
            'Sin entrenamientos este día',
            style: Theme.of(context)
                .textTheme
                .bodyLarge
                ?.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message, BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.wifi_off, size: 60, color: AppColors.textSecondary),
          const SizedBox(height: 16),
          Text(
            message,
            style: Theme.of(context)
                .textTheme
                .bodyLarge
                ?.copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            icon: const Icon(Icons.refresh),
            label: const Text('Reintentar'),
            onPressed: _cargarRegistros,
          ),
        ],
      ),
    );
  }

  Widget _buildRegistroItem(RegistroModel registro, BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.check_circle,
                color: AppColors.primary, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  registro.rutinaNombre,
                  style: theme.textTheme.bodyLarge
                      ?.copyWith(fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '${registro.numEjercicios} ejercicios · ${_horaFormateada(registro.fecha)}',
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(color: AppColors.textMuted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatFechaSeleccionada(DateTime fecha) {
    const dias = [
      'Lunes', 'Martes', 'Miércoles', 'Jueves',
      'Viernes', 'Sábado', 'Domingo'
    ];
    const meses = [
      'enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio',
      'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre'
    ];
    return '${dias[fecha.weekday - 1]}, ${fecha.day} de ${meses[fecha.month - 1]}';
  }

  String _horaFormateada(DateTime fecha) {
    final h = fecha.hour.toString().padLeft(2, '0');
    final m = fecha.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}