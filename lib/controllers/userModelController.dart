import 'package:get/get.dart';
import '../models/userModel.dart';
import '../models/asignaturaModel.dart';
import '../models/clase.dart';
import '../models/review.dart';
import 'authController.dart';
import 'package:dio/dio.dart' as dio;
import '../services/notificacionService.dart';

class UserModelController extends GetxController {
  final user = UserModel(
    id: '0',
    name: 'Usuario desconocido',
    username: 'Sin username',
    mail: 'No especificado',
    password: 'Sin contraseña',
    fechaNacimiento: 'Sin especificar',
    isProfesor: false,
    isAlumno: false,
    isAdmin: false,
  ).obs;

  final AuthController authController = Get.find<AuthController>();
  final NotificacionService notificacionService = NotificacionService();

  var isLoading = false.obs;

  void setUser({
    required String id,
    required String name,
    required String username,
    required String mail,
    required String password,
    required String fechaNacimiento,
    required bool isProfesor,
    required bool isAlumno,
    required bool isAdmin,
    required bool conectado,
    String? foto,
    String? descripcion,
    List<Map<String, String>>? disponibilidad,
    List<dynamic>? asignaturasImparte,
    Map<String, dynamic>? location,
    double? mediaValoraciones,
    List<dynamic>? historialClases,
    List<dynamic>? reviews,
  }) {
    user.update((val) {
      if (val != null) {
        val.id = id;
        val.name = name;
        val.username = username;
        val.mail = mail;
        val.password = password;
        val.fechaNacimiento = fechaNacimiento;
        val.isProfesor = isProfesor;
        val.isAlumno = isAlumno;
        val.isAdmin = isAdmin;
        val.conectado = conectado;

        if (foto != null) val.foto = foto;
        if (descripcion != null) val.descripcion = descripcion;
        if (disponibilidad != null) val.disponibilidad = disponibilidad;

        if (asignaturasImparte != null) {
          val.asignaturasImparte = asignaturasImparte.map((item) {
            if (item is AsignaturaModel) {
              return item;
            } else if (item is Map<String, dynamic>) {
              return AsignaturaModel.fromJson(item);
            } else {
              throw Exception('Tipo inesperado en asignaturasImparte: $item');
            }
          }).toList();
        }

        if (location != null) val.location = location;
        if (mediaValoraciones != null) val.mediaValoraciones = mediaValoraciones;

        if (historialClases != null) {
          val.historialClases = historialClases.map((item) {
            if (item is ClaseModel) {
              return item;
            } else if (item is Map<String, dynamic>) {
              return ClaseModel.fromJson(item);
            } else {
              throw Exception('Tipo inesperado en historialClases: $item');
            }
          }).toList();
        }

        if (reviews != null) {
          val.reviews = reviews.map((item) {
            if (item is ReviewModel) {
              return item;
            } else if (item is Map<String, dynamic>) {
              return ReviewModel.fromJson(item);
            } else {
              throw Exception('Tipo inesperado en reviews: $item');
            }
          }).toList();
        }
      }
    });
    printUserData();
  }

  Future<void> fetchHistorialClases(String userId) async {
    isLoading(true);
    try {
      final dio.Dio dioClient = dio.Dio();
      dioClient.options.headers['auth-token'] = authController.getToken;

      final response = await dioClient.get('http://localhost:3000/api/clases/$userId/alumno');
      final clasesData = (response.data as List).map((clase) => ClaseModel.fromJson(clase)).toList();

      user.update((val) {
        if (val != null) {
          val.historialClases = clasesData;
        }
      });
    } catch (e) {
      print('Error al obtener el historial de clases: $e');
    } finally {
      isLoading(false);
    }
  }

  Future<bool> crearReview(Map<String, dynamic> reviewData) async {
    isLoading(true);
    try {
      final dio.Dio dioClient = dio.Dio();
      dioClient.options.headers['auth-token'] = authController.getToken;

      final response = await dioClient.post(
        'http://localhost:3000/api/reviews/',
        data: reviewData,
      );

      if (response.statusCode == 201) {
        print('Review creada con éxito: ${response.data}');

        final profesorId = reviewData['profesorId'] ?? '';
        if (profesorId.isNotEmpty) {
          await notificacionService.crearNotificacion(
            profesorId,
            'Has recibido una nueva review.',
          ).then((_) {
            print('Notificación enviada al profesor.');
          }).catchError((e) {
            print('Error al enviar notificación al profesor: $e');
          });
        }
        return true;
      } else {
        print('Error al crear la review: ${response.data}');
        return false;
      }
    } catch (e) {
      print('Error al crear la review: $e');
      return false;
    } finally {
      isLoading(false);
    }
  }

Future<bool> programarClase(Map<String, dynamic> claseData) async {
  isLoading(true);
  try {
    final dio.Dio dioClient = dio.Dio();
    dioClient.options.headers['auth-token'] = authController.getToken;

    print('Intentando programar clase con datos: $claseData');

    final response = await dioClient.post(
      'http://localhost:3000/api/clases/',
      data: claseData,
    );

    if (response.statusCode == 201) {
      print('Clase programada con éxito: ${response.data}');

      // Crear notificaciones sin tanta lógica condicional
      final List<Map<String, String>> notificaciones = [
        {
          'userId': claseData['profesorId']!,
          'descripcion': 'Tienes una nueva clase programada.',
        },
        {
          'userId': claseData['alumnoId']!,
          'descripcion': 'Has programado una nueva clase.',
        },
      ];

      for (var notificacion in notificaciones) {
        await notificacionService.crearNotificacion(
          notificacion['userId']!,
          notificacion['descripcion']!,
        ).then((_) {
          print('Notificación enviada a ${notificacion['userId']}');
        }).catchError((e) {
          print('Error al enviar notificación a ${notificacion['userId']}: $e');
        });
      }

      return true;
    } else {
      print('Error al programar la clase: ${response.data}');
      return false;
    }
  } catch (e) {
    print('Error al programar la clase: $e');
    return false;
  } finally {
    isLoading(false);
  }
}


  Future<void> fetchReviews(String profesorId) async {
    isLoading(true);
    try {
      final dio.Dio dioClient = dio.Dio();
      dioClient.options.headers['auth-token'] = authController.getToken;

      final response = await dioClient.get('http://localhost:3000/api/reviews/profesor/$profesorId');
      final reviewsData = (response.data as List).map((review) => ReviewModel.fromJson(review)).toList();

      final mediaValoraciones = reviewsData.isNotEmpty
          ? reviewsData.map((r) => r.puntuacion).reduce((a, b) => a + b) / reviewsData.length
          : null;

      user.update((val) {
        if (val != null) {
          val.reviews = reviewsData;
          val.mediaValoraciones = mediaValoraciones;
        }
      });
    } catch (e) {
      print('Error al obtener las reviews: $e');
    } finally {
      isLoading(false);
    }
  }

  void printUserData() {
    print('User Data -> ${user.value.toJson()}');
  }
}
