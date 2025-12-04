import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  // Creamos una instancia única (Singleton) para usarla en toda la app
  static final SecureStorageService _instance = SecureStorageService._internal();

  factory SecureStorageService() {
    return _instance;
  }

  SecureStorageService._internal();

  // Instancia de la librería externa
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // --- Métodos de Escritura ---

  // Guardar un valor simple (String)
  Future<void> write(String key, String value) async {
    await _storage.write(key: key, value: value);
  }

  // --- Métodos de Lectura ---

  // Leer un valor
  Future<String?> read(String key) async {
    return await _storage.read(key: key);
  }

  // Leer todos los valores (útil para debug o migraciones)
  Future<Map<String, String>> readAll() async {
    return await _storage.readAll();
  }

  // --- Métodos de Borrado ---

  // Borrar un valor específico
  Future<void> delete(String key) async {
    await _storage.delete(key: key);
  }

  // Borrar TODO (Cuidado: Solo usar al cerrar sesión o resetear app)
  Future<void> deleteAll() async {
    await _storage.deleteAll();
  }
}