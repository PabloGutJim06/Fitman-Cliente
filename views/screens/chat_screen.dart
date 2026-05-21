import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import '../../models/routine_model.dart';
import '../../models/user_model.dart';
import '../../viewmodels/profile_viewmodel.dart';
import '../../viewmodels/routine_viewmodel.dart';
import '../../viewmodels/login_viewmodel.dart';
import '../../config/api_config.dart';
import '../../theme/app_colors.dart';

class _ChatMessage {
  final String rol;
  final String contenido;

  const _ChatMessage({required this.rol, required this.contenido});

  Map<String, dynamic> toApiJson() => {
    'role': rol,
    'content': contenido,
  };
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _inputCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  final List<_ChatMessage> _messages = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _enviarBienvenida());
  }

  @override
  void dispose() {
    _inputCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  String _buildSystemPrompt(UserModel? user, List<RoutineModel> rutinas) {
    final nombreUsuario = user?.nombre ?? 'Usuario';
    final nivel = user?.nivel ?? 'no especificado';
    final objetivo = user?.objetivo ?? 'no especificado';
    final peso =
    user?.pesoActual != null ? '${user!.pesoActual} kg' : 'no especificado';
    final altura =
    user?.altura != null ? '${user!.altura} cm' : 'no especificada';
    final edad =
    user?.edad != null ? '${user!.edad} años' : 'no especificada';

    final rutinasResumen = rutinas.isEmpty
        ? 'No tiene rutinas creadas todavía.'
        : rutinas.map((r) {
      final ejerciciosReales =
      r.ejercicios.where((e) => !e.isDescanso).toList();
      return '- "${r.nombre}": ${ejerciciosReales.length} ejercicios '
          '(${ejerciciosReales.take(3).map((e) => e.nombre).join(', ')}'
          '${ejerciciosReales.length > 3 ? '...' : ''})';
    }).join('\n');

    return '''Eres el asistente personal de fitness de FitMan, una app de entrenamiento.
Tu nombre es "Asistente FitMan".

DATOS DEL USUARIO:
- Nombre: $nombreUsuario
- Nivel: $nivel
- Objetivo: $objetivo
- Peso: $peso
- Altura: $altura
- Edad: $edad

RUTINAS ACTUALES DEL USUARIO:
$rutinasResumen

INSTRUCCIONES:
- Responde SIEMPRE en español.
- Eres un experto en fitness, nutrición y entrenamiento.
- Personaliza tus respuestas con los datos del usuario cuando sea relevante.
- Si el usuario pregunta sobre sus rutinas, usa los datos reales de arriba.
- Sé conciso — respuestas cortas y directas, máximo 3-4 párrafos.
- Usa un tono motivador pero profesional.
- No inventes datos del usuario que no estén en el contexto.
- Si el usuario pregunta algo fuera del fitness, redirige amablemente al tema.''';
  }

  Future<void> _enviarBienvenida() async {
    final user = context.read<ProfileViewModel>().user;
    final nombre = user?.nombre.split(' ').first ?? 'atleta';
    final rutinas = context.read<RoutineViewModel>().routines;
    final numRutinas = rutinas.length;

    final bienvenida = numRutinas > 0
        ? '¡Hola $nombre! Veo que tienes $numRutinas ${numRutinas == 1 ? 'rutina activa' : 'rutinas activas'}. Soy tu asistente de fitness personal. ¿En qué puedo ayudarte hoy?'
        : '¡Hola $nombre! Soy tu asistente de fitness personal. Todavía no tienes rutinas — ¿quieres que te ayude a crear una?';

    setState(() {
      _messages.add(_ChatMessage(rol: 'assistant', contenido: bienvenida));
    });
  }

  Future<void> _enviar() async {
    final texto = _inputCtrl.text.trim();
    if (texto.isEmpty || _isLoading) return;

    _inputCtrl.clear();

    setState(() {
      _messages.add(_ChatMessage(rol: 'user', contenido: texto));
      _isLoading = true;
    });

    _scrollAlFinal();

    try {
      final user = context.read<ProfileViewModel>().user;
      final rutinas = context.read<RoutineViewModel>().routines;
      final token = context.read<LoginViewModel>().user?.token ?? '';
      final systemPrompt = _buildSystemPrompt(user, rutinas);

      final messagesPayload =
      _messages.map((m) => m.toApiJson()).toList();

      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/chat'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'system': systemPrompt,
          'messages': messagesPayload,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final respuesta = data['content'] as String;
        setState(() {
          _messages
              .add(_ChatMessage(rol: 'assistant', contenido: respuesta));
        });
      } else {
        final data = jsonDecode(response.body);
        setState(() {
          _messages.add(_ChatMessage(
            rol: 'assistant',
            contenido: data['error'] ??
                'Lo siento, tuve un problema al procesar tu mensaje.',
          ));
        });
      }
    } catch (e) {
      setState(() {
        _messages.add(const _ChatMessage(
          rol: 'assistant',
          contenido:
          'Error de conexión. Comprueba tu red e inténtalo de nuevo.',
        ));
      });
    } finally {
      setState(() => _isLoading = false);
      _scrollAlFinal();
    }
  }

  void _scrollAlFinal() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios,
              color: AppColors.primary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.15),
                shape: BoxShape.circle,
                border: Border.all(
                    color: AppColors.primary.withOpacity(0.4), width: 1),
              ),
              child: const Icon(Icons.fitness_center,
                  color: AppColors.primary, size: 18),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Asistente FitMan',
                    style: theme.textTheme.bodyLarge
                        ?.copyWith(fontWeight: FontWeight.bold)),
                Text('en línea',
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(color: AppColors.primary, fontSize: 11)),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollCtrl,
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 12),
              itemCount: _messages.length + (_isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (_isLoading && index == _messages.length) {
                  return _buildTypingIndicator(theme);
                }
                return _buildMessage(_messages[index], theme);
              },
            ),
          ),
          Container(
            color: AppColors.surface,
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 12,
              bottom: MediaQuery.of(context).padding.bottom + 12,
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _inputCtrl,
                    style: theme.textTheme.bodyLarge,
                    maxLines: null,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _enviar(),
                    decoration: InputDecoration(
                      hintText: 'Escribe un mensaje...',
                      hintStyle: theme.textTheme.bodyMedium
                          ?.copyWith(color: AppColors.textMuted),
                      filled: true,
                      fillColor: AppColors.surfaceLight,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: const BorderSide(
                            color: AppColors.primary, width: 1.5),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: _enviar,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _isLoading
                          ? AppColors.surfaceLight
                          : AppColors.primary.withOpacity(0.15),
                      border: Border.all(
                        color: _isLoading
                            ? AppColors.textMuted.withOpacity(0.3)
                            : AppColors.primary,
                        width: 1.5,
                      ),
                    ),
                    child: Icon(
                      Icons.arrow_upward_rounded,
                      color: _isLoading
                          ? AppColors.textMuted
                          : AppColors.primary,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessage(_ChatMessage msg, ThemeData theme) {
    final esUsuario = msg.rol == 'user';

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment:
        esUsuario ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!esUsuario) ...[
            Container(
              width: 28,
              height: 28,
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withOpacity(0.12),
                border: Border.all(
                    color: AppColors.primary.withOpacity(0.3), width: 1),
              ),
              child: const Icon(Icons.fitness_center,
                  color: AppColors.primary, size: 14),
            ),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: esUsuario
                    ? AppColors.primary.withOpacity(0.12)
                    : AppColors.surface,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(esUsuario ? 16 : 4),
                  bottomRight: Radius.circular(esUsuario ? 4 : 16),
                ),
                border: Border.all(
                  color: esUsuario
                      ? AppColors.primary.withOpacity(0.3)
                      : AppColors.surfaceLight,
                  width: 1,
                ),
              ),
              child: Text(
                msg.contenido,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: esUsuario
                      ? AppColors.primary
                      : AppColors.textPrimary,
                  height: 1.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            width: 28,
            height: 28,
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary.withOpacity(0.12),
              border: Border.all(
                  color: AppColors.primary.withOpacity(0.3), width: 1),
            ),
            child: const Icon(Icons.fitness_center,
                color: AppColors.primary, size: 14),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
                bottomRight: Radius.circular(16),
                bottomLeft: Radius.circular(4),
              ),
              border: Border.all(color: AppColors.surfaceLight, width: 1),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(3, (i) {
                return TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: 1),
                  duration: Duration(milliseconds: 600 + i * 150),
                  builder: (_, v, __) => Container(
                    width: 6,
                    height: 6,
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.textMuted.withOpacity(
                          0.4 + 0.6 * (v < 0.5 ? v * 2 : (1 - v) * 2)),
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}