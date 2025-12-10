import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/persona_model.dart';

class HomeController extends ChangeNotifier {
  List<PersonaModel> _personas = [];
  bool _isLoading = true;

  // Clave para guardar en el almacenamiento del teléfono
  static const String _storageKey = 'lista_familiares_v1';

  List<PersonaModel> get personas => _personas;
  bool get isLoading => _isLoading;

  HomeController() {
    cargarPersonas();
  }

  // Cargar lista desde el disco al iniciar la app
  Future<void> cargarPersonas() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final String? personasJson = prefs.getString(_storageKey);

      if (personasJson != null) {
        final List<dynamic> decodedList = jsonDecode(personasJson);
        _personas = decodedList.map((item) => PersonaModel.fromMap(item)).toList();
      } else {
        // Opcional: Si está vacío, iniciar con una lista vacía o datos de prueba
        _personas = [];
      }
    } catch (e) {
      debugPrint("Error cargando personas: $e");
    }

    _isLoading = false;
    notifyListeners();
  }

  // Guardar un nuevo familiar y persistir en disco
  Future<void> agregarPersona(PersonaModel nuevaPersona) async {
    _personas.add(nuevaPersona);
    await _guardarEnDisco();
    notifyListeners();
  }

  // Eliminar familiar y actualizar disco
  Future<void> eliminarPersona(String id) async {
    _personas.removeWhere((p) => p.id == id);
    await _guardarEnDisco();
    notifyListeners();
  }

  // --- NUEVO: Método para editar un familiar existente ---
  Future<void> editarPersona(PersonaModel personaEditada) async {
    // Buscamos el índice de la persona en la lista usando su ID único
    final index = _personas.indexWhere((p) => p.id == personaEditada.id);

    if (index != -1) {
      // Reemplazamos el objeto antiguo con el nuevo
      _personas[index] = personaEditada;
      // Guardamos los cambios en el disco
      await _guardarEnDisco();
      // Notificamos a la UI para que se refresque
      notifyListeners();
    }
  }

  // Método privado para escribir en SharedPreferences
  Future<void> _guardarEnDisco() async {
    final prefs = await SharedPreferences.getInstance();
    // Convertimos la lista de objetos a una lista de Mapas y luego a Texto JSON
    final String encodedData = jsonEncode(_personas.map((p) => p.toMap()).toList());
    await prefs.setString(_storageKey, encodedData);
  }
}