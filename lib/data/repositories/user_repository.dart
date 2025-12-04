import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/persona_model.dart'; // docs2/models/persona_model.dart

// Constante para la clave de almacenamiento en SharedPreferences
const String _personasKey = 'personas_data';

// Repositorio encargado de la persistencia de los datos de PersonaModel
// Se recomienda usar SharedPreferences solo para demostración,
// ya que para apps robustas se prefiere SQLite, Hive o Firestore.
class UserRepository {

  // Guardar la lista completa de personas
  Future<void> savePersonas(List<PersonaModel> personas) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // 1. Convertir la lista de objetos PersonaModel a una lista de Map<String, dynamic>
      final List<Map<String, dynamic>> personasMapList =
      personas.map((p) => p.toMap()).toList();

      // 2. Convertir la lista de Mapas a una cadena JSON
      final String jsonString = json.encode(personasMapList);

      // 3. Guardar la cadena JSON en SharedPreferences
      await prefs.setString(_personasKey, jsonString);

    } catch (e) {
      print('Error al guardar personas: $e');
      // Manejo de errores de persistencia
    }
  }

  // Cargar la lista completa de personas
  Future<List<PersonaModel>> loadPersonas() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // 1. Leer la cadena JSON guardada
      final String? jsonString = prefs.getString(_personasKey);

      if (jsonString == null || jsonString.isEmpty) {
        return []; // Retorna lista vacía si no hay datos
      }

      // 2. Convertir la cadena JSON a una lista dinámica
      final List<dynamic> jsonList = json.decode(jsonString);

      // 3. Convertir la lista de Mapas a objetos PersonaModel
      final List<PersonaModel> personas =
      jsonList.map((map) => PersonaModel.fromMap(map as Map<String, dynamic>)).toList();

      return personas;

    } catch (e) {
      print('Error al cargar personas: $e');
      // Si hay un error (ej. JSON corrupto), retornar lista vacía para evitar crasheos
      return [];
    }
  }

  // Si decides usar un repositorio para operaciones individuales (CRUD)
  Future<void> updatePersona(PersonaModel persona) async {
    // En una aplicación con muchos datos, esta no es la forma más eficiente,
    // pero funciona con SharedPreferences.
    final List<PersonaModel> personas = await loadPersonas();

    // Buscar el índice y reemplazar
    final index = personas.indexWhere((p) => p.id == persona.id);
    if (index != -1) {
      personas[index] = persona;
      await savePersonas(personas);
    }
  }
}