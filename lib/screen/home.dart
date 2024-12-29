import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';
import '../controllers/theme_controller.dart';
import '../controllers/localeController.dart';
import '../controllers/authController.dart';
import '../controllers/socketController.dart';
import '../controllers/connectedUsersController.dart';
import '../l10n.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  final ThemeController themeController = Get.find<ThemeController>();
  final LocaleController localeController = Get.find<LocaleController>();
  final SocketController socketController = Get.find<SocketController>();
  final AuthController authController = Get.find<AuthController>();
  final ConnectedUsersController connectedUsersController = Get.find<ConnectedUsersController>();
  final AudioPlayer _audioPlayer = AudioPlayer();

  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay = DateTime.now();
  Map<DateTime, List<String>> _events = {};
  String currentTime = "";

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.8, end: 1.2).animate(_controller);

    if (authController.getUserId.isNotEmpty) {
      socketController.connectSocket(authController.getUserId);

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
            if (now.hour == eventTime.hour && now.minute == eventTime.minute && now.second == 0) {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('¡Notificación!'),
                  content: Text('Es hora del evento: $eventName'),
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

  void _showAddEventDialog(BuildContext context) {
    final TextEditingController eventController = TextEditingController();
    TimeOfDay selectedTime = TimeOfDay.now();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Agregar Clase'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: eventController,
              decoration: const InputDecoration(labelText: 'Nombre de la Clase'),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                const Text('Hora: '),
                TextButton(
                  onPressed: () async {
                    final TimeOfDay? pickedTime = await showTimePicker(
                      context: context,
                      initialTime: selectedTime,
                    );
                    if (pickedTime != null) {
                      setState(() {
                        selectedTime = pickedTime;
                      });
                    }
                  },
                  child: Text(selectedTime.format(context)),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              _addEvent(eventController.text, selectedTime);
              Navigator.pop(context);
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)?.translate('home') ?? 'Inicio'),
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              themeController.themeMode.value == ThemeMode.dark
                  ? Icons.light_mode
                  : Icons.dark_mode,
              color: theme.textTheme.bodyLarge?.color,
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
            icon: const Icon(Icons.account_circle),
            onPressed: () {
              Get.toNamed('/perfil');
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: MediaQuery.of(context).size.width * 0.5,
              child: GestureDetector(
                onDoubleTap: () {
                  if (_selectedDay != null) {
                    _showAddEventDialog(context);
                  }
                },
                child: TableCalendar(
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
                ),
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Text(
                      'Clases para ${_selectedDay != null ? _selectedDay.toString().split(' ')[0] : 'ningún día'}:',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  ListView(
                    shrinkWrap: true,
                    children: (_events[_selectedDay] ?? [])
                        .map((event) => ListTile(
                              title: Text(event),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () {
                                  setState(() {
                                    _events[_selectedDay]?.remove(event);
                                    if (_events[_selectedDay]?.isEmpty ?? true) {
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
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.toNamed('/map'),
        backgroundColor: theme.primaryColor,
        child: const Icon(Icons.map),
        tooltip: 'Ver Mapa',
      ),
    );
  }
}
