import 'package:flutter/material.dart';
import 'package:flutter_application_1/Widgets/todoListWidget.dart';
import 'package:flutter_application_1/extensions/HexToColor.dart';
import 'package:get/get.dart';
import '../controllers/authController.dart';
import '../controllers/theme_controller.dart';
import '../controllers/localeController.dart';
import '../l10n.dart';
import 'dart:convert';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_time_picker_spinner/flutter_time_picker_spinner.dart';
import 'package:fl_chart/fl_chart.dart';
import '../controllers/socketController.dart';
import '../controllers/connectedUsersController.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  final ThemeController themeController = Get.find<ThemeController>();
  final LocaleController localeController = Get.find<LocaleController>();
  final SocketController socketController = Get.find<SocketController>();
  final AuthController authController = Get.find<AuthController>();
  final ConnectedUsersController connectedUsersController =
      Get.find<ConnectedUsersController>();
  final AudioPlayer _audioPlayer = AudioPlayer();

  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay = DateTime.now();
  Map<DateTime, List<String>> _events = {};
  Map<String, double> _progressData = {};
  String currentTime = "";
  final TextEditingController _textController =
      TextEditingController(); // Controlador para la caja de texto

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.8, end: 1.2).animate(_controller);

    // Conectar el socket si hay un usuario logueado
    if (authController.getUserId.isNotEmpty) {
      socketController.connectSocket(authController.getUserId);

      // Escuchar actualizaciones del estado de usuarios
      socketController.socket.on('update-user-status', (data) {
        print('Actualización del estado de usuarios: $data');
        connectedUsersController.updateConnectedUsers(List<String>.from(data));
      });
    }

    _loadEvents();
    _updateTime();
    _checkAndNotifyEvents();
  }

  void _addEvent(String event, TimeOfDay time) {
    if (event.isNotEmpty) {
      setState(() {
        final formattedTime = time.format(context);
        final fullEvent = '$event - $formattedTime';
        if (_events[_selectedDay] != null) {
          _events[_selectedDay]?.add(fullEvent);
        } else {
          _events[_selectedDay!] = [fullEvent];
        }
      });
      _saveEvents();
    }
  }

  Future<void> _loadEvents() async {
    final prefs = await SharedPreferences.getInstance();
    final String? eventsString = prefs.getString('events');
    if (eventsString != null) {
      final Map<String, dynamic> eventsMap = jsonDecode(eventsString);
      setState(() {
        _events = eventsMap.map((key, value) {
          final date = DateTime.parse(key);
          return MapEntry(date, List<String>.from(value));
        });
      });
    }
  }

  Future<void> _saveEvents() async {
    final prefs = await SharedPreferences.getInstance();
    final Map<String, List<String>> eventsMap = _events.map((key, value) {
      return MapEntry(key.toIso8601String(), value);
    });
    final String eventsString = jsonEncode(eventsMap);
    prefs.setString('events', eventsString);
  }

  void _updateTime() {
    setState(() {
      currentTime = DateFormat('HH:mm:ss').format(DateTime.now());
    });
    Future.delayed(Duration(seconds: 1), _updateTime);
  }

  void _checkAndNotifyEvents() {
    Timer.periodic(const Duration(seconds: 1), (timer) {
      final now = DateTime.now();
      final todayEvents = _events[_selectedDay ?? DateTime.now()] ?? [];

      for (String event in todayEvents) {
        final parts = event.split(' - ');
        if (parts.length == 2) {
          final eventName = parts[0];
          final eventTimeString = parts[1];
          try {
            final eventTime = DateFormat('HH:mm').parse(eventTimeString);
            if (now.hour == eventTime.hour &&
                now.minute == eventTime.minute &&
                now.second == 0) {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text(AppLocalizations.of(context)
                          ?.translate('notification_title') ??
                      'Notification'),
                  content: Text(AppLocalizations.of(context)
                          ?.translate('event_time_message') ??
                      'It\'s time for the event: $eventName'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cerrar'),
                    ),
                  ],
                ),
              );

              // Reproducir sonido personalizado
              _audioPlayer.play(AssetSource('assets/alert_sound.mp3'));
            }
          } catch (e) {
            print('Error al analizar la hora del evento: $eventTimeString');
          }
        }
      }
    });
  }

  void _logout() {
    if (authController.getUserId.isNotEmpty) {
      socketController.disconnectUser(authController.getUserId);

      authController.setUserId('');
      connectedUsersController.updateConnectedUsers([]);
    }

    Get.offAllNamed('/login');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _showAddEventDialog(BuildContext context) {
    final TextEditingController eventController = TextEditingController();
    DateTime selectedTime = DateTime.now();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(AppLocalizations.of(context)?.translate('add_class') ??
              'Add Class'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: eventController,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)
                          ?.translate('class_name_label') ??
                      'Class Name',
                ),
              ),

              SizedBox(height: 16),
              Text(
                AppLocalizations.of(context)?.translate('select_time_label') ??
                    'Select Time:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),

              // Usamos un contenedor con un tamaño fijo y desplazamiento
              Container(
                height: 200,
                child: TimePickerSpinner(
                  is24HourMode: true,
                  normalTextStyle: TextStyle(fontSize: 18, color: Colors.grey),
                  highlightedTextStyle:
                      TextStyle(fontSize: 24, color: Colors.blue),
                  spacing: 100,
                  itemHeight: 50,
                  isForce2Digits: true,
                  onTimeChange: (time) {
                    setState(() {
                      selectedTime = time;
                    });
                  },
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(AppLocalizations.of(context)?.translate('cancel') ??
                  'Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                _addEvent(
                    eventController.text, TimeOfDay.fromDateTime(selectedTime));
                Navigator.pop(context);
              },
              child: Text(
                  AppLocalizations.of(context)?.translate('save') ?? 'Save'),
            ),
          ],
        ),
      ),
    );
  }

  // En _buildProgressCharts:
  List<Widget> _buildProgressCharts() {
    final Map<String, double> progressData = {};

    _events.forEach((date, events) {
      for (var event in events) {
        final parts = event.split(' - ');
        if (parts.isNotEmpty) {
          final subject = parts[0];
          progressData[subject] = (progressData[subject] ?? 0.0) + 0.1;
        }
      }
    });

    return [
      SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: progressData.entries.map((entry) {
            // Elegir el color basado en el progreso.
            Color progressColor = entry.value >= 0.8
                ? Colors.green
                : entry.value >= 0.5
                    ? Colors.orange
                    : Colors.red;

            return Padding(
              padding: const EdgeInsets.only(right: 20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    height: 100,
                    width: 100,
                    child: PieChart(
                      PieChartData(
                        sections: [
                          PieChartSectionData(
                            value: entry.value * 100,
                            title: "${(entry.value * 100).toStringAsFixed(1)}%",
                            color: progressColor,
                            radius: 30,
                          ),
                          PieChartSectionData(
                            value: (1 - entry.value) * 100,
                            title: "",
                            color: Colors.grey.shade300,
                            radius: 30,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Text(
                    entry.key,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title:
            Text(AppLocalizations.of(context)?.translate('home') ?? 'Inicio'),
        backgroundColor: theme.appBarTheme.backgroundColor,
        actions: [
          IconButton(
            icon: Icon(
              themeController.themeMode.value == ThemeMode.dark
                  ? Icons.light_mode
                  : Icons.dark_mode,
              color: theme.iconTheme.color,
            ),
            onPressed: themeController.toggleTheme,
          ),
          IconButton(
            icon: Icon(Icons.language, color: theme.textTheme.bodyLarge?.color),
            onPressed: () {
              if (localeController.currentLocale.value.languageCode == 'es') {
                localeController.changeLanguage('en');
              } else {
                localeController.changeLanguage('es');
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.person_search),
            onPressed: () {
              Get.toNamed('/perfil');
            },
            tooltip: 'Buscar perfiles',
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Cerrar sesión',
          ),
        ],
      ),
body: SingleChildScrollView(
  padding: const EdgeInsets.all(16.0),
  child: Stack(  // Usamos un Stack para permitir la colocación de Positioned
    children: [
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sección del calendario y eventos
          Container(
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(16.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 8.0,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            padding: const EdgeInsets.all(16.0),
            margin: const EdgeInsets.only(bottom: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Fila con el calendario, clases para el día y TodoList
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Calendario
                    Container(
                      width: MediaQuery.of(context).size.width * 0.5,
                      child: GestureDetector(
                        onDoubleTap: () {
                          if (_selectedDay != null) {
                            _showAddEventDialog(context);
                          }
                        },
                        child: TableCalendar(
                          locale: 'es_ES',
                          firstDay: DateTime(2000),
                          lastDay: DateTime(2100),
                          focusedDay: _focusedDay,
                          selectedDayPredicate: (day) {
                            return isSameDay(_selectedDay, day);
                          },
                          onDaySelected: (selectedDay, focusedDay) {
                            setState(() {
                              _selectedDay = selectedDay;
                              _focusedDay = focusedDay;
                            });
                          },
                          eventLoader: (day) => _events[day] ?? [],
                          calendarStyle: CalendarStyle(
                            selectedDecoration: BoxDecoration(
                              color: Colors.blueAccent,
                              shape: BoxShape.circle,
                            ),
                            todayDecoration: BoxDecoration(
                              color: Colors.orangeAccent,
                              shape: BoxShape.circle,
                            ),
                            markerDecoration: BoxDecoration(
                              color: Colors.redAccent,
                              shape: BoxShape.circle,
                            ),
                          ),
                          headerStyle: const HeaderStyle(
                            formatButtonVisible: false,
                            titleCentered: true,
                            titleTextStyle: TextStyle(fontSize: 18),
                          ),
                          onPageChanged: (focusedDay) {
                            setState(() {
                              _focusedDay = focusedDay;
                            });
                          },
                        ),
                      ),
                    ),
                    SizedBox(width: 16),
                    // Contenedor de "Clases para el día" + TodoList al lado
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Text(
                              AppLocalizations.of(context)
                                      ?.translate('classes_for_day') ??
                                  'Clases para ${_selectedDay != null ? _selectedDay.toString().split(' ')[0] : 'ningún día'}:',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          ListView(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            children: (_events[_selectedDay] ?? [])
                                .map((event) => ListTile(
                                      title: Text(event),
                                      trailing: IconButton(
                                        icon: const Icon(Icons.delete,
                                            color: Colors.red),
                                        onPressed: () {
                                          setState(() {
                                            _events[_selectedDay]?.remove(event);
                                            if (_events[_selectedDay]
                                                    ?.isEmpty ??
                                                true) {
                                              _events.remove(_selectedDay);
                                            }
                                          });
                                          _saveEvents();
                                        },
                                      ),
                                    ))
                                .toList(),
                          ),
                        ],
                      ),
                    ),
                    // TodoList al lado derecho
                    Container(
                      width: MediaQuery.of(context).size.width * 0.25, // ancho reducido
                      child: TodoListWidget(date: _selectedDay),
                    ),
                  ],
                ),
                SizedBox(height: 16),
              ],
            ),
          ),

          // Lista de usuarios conectados
          Container(
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(16.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 8.0,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            padding: const EdgeInsets.all(16.0),
            margin: const EdgeInsets.only(bottom: 16.0),
            child: Obx(() {
              if (connectedUsersController.connectedUsers.isEmpty) {
                return Center(
                  child: Text(
                    'No hay usuarios conectados.',
                    style: TextStyle(
                      fontSize: 16,
                      color: theme.textTheme.bodyLarge?.color,
                    ),
                  ),
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: connectedUsersController.connectedUsers.length,
                itemBuilder: (context, index) {
                  final userId =
                      connectedUsersController.connectedUsers[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: theme.colorScheme.secondary,
                        child: Icon(
                          Icons.person,
                          color: theme.colorScheme.onSecondary,
                        ),
                      ),
                      title: Text(
                        'ID: $userId',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.textTheme.bodyLarge?.color,
                        ),
                      ),
                      subtitle: Text(
                        'Estado: Conectado',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),

      // Aquí está el contenedor de "Progreso de asignaturas" con Positioned
      Positioned(
        top: 500,  // Ajusta este valor para moverlo hacia abajo o hacia arriba
        left: 16,  // Ajusta este valor para moverlo hacia la izquierda o derecha
        child: Container(
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(16.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 8.0,
                offset: Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLocalizations.of(context)?.translate('subjects_progress') ??
                    'Progreso de las asignaturas:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Column(
                children: _buildProgressCharts(), // Aquí es donde está tu lista
              ),
            ],
          ),
        ),
      ),
    ],
  ),
),

// Botones flotantes
floatingActionButton: Column(
  mainAxisSize: MainAxisSize.min,
  mainAxisAlignment: MainAxisAlignment.end,
  children: [
    Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: FloatingActionButton(
        onPressed: () => Get.toNamed('/programar_clase'),
        backgroundColor: Theme.of(context).primaryColor,
        child: const Icon(Icons.add),
        tooltip: 'Programar Clase',
      ),
    ),
    
    // Botón para ver el mapa
    FloatingActionButton(
      onPressed: () => Get.toNamed('/map'),
      backgroundColor: Theme.of(context).primaryColor,
      child: const Icon(Icons.map),
      tooltip: 'Ver Mapa',
    ),
    
    // Botón para el chat general
    Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: FloatingActionButton(
        heroTag: 'chat-general', // Hero tag único para el chat general
        onPressed: () => Get.toNamed('/chat-general'),
        backgroundColor: Theme.of(context).primaryColor,
        child: const Icon(Icons.chat),
        tooltip: 'Chat General',
      ),
    ),
  ],
),



    );
    
  }}