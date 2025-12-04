import 'package:flutter/material.dart';
import 'package:docs2/models/persona_model.dart';
import 'package:docs2/models/documento_model.dart';

// Controlador para la Pantalla Principal (Home)
// Maneja la lista de familiares.
class HomeController extends ChangeNotifier {

  // Lista privada de personas
  List<PersonaModel> _personas = [];

  // Estado de carga para mostrar spinners en la UI
  bool _isLoading = false;

  // Getters para acceder a los datos desde la Vista
  List<PersonaModel> get personas => _personas;
  bool get isLoading => _isLoading;

  // Constructor: Carga datos iniciales al instanciar
  HomeController() {
    cargarPersonas();
  }

  // Simulación de carga de datos (Aquí conectarías con Base de Datos luego)
  Future<void> cargarPersonas() async {
    _isLoading = true;
    notifyListeners(); // Avisa a la vista que empiece a mostrar "Cargando..."

    // Simulación de espera de base de datos
    await Future.delayed(const Duration(seconds: 1));

    // Datos de prueba (Mock Data)
    if (_personas.isEmpty) {
      _personas = [
        PersonaModel(
          id: '1',
          nombre: 'Abuela María',
          edad: '82 años',
          documentos: [
            DocumentoModel(
              id: 'd1',
              titulo: 'Cédula de Identidad',
              descripcion: 'Documento oficial',
              valor: '1710020030',
              tipo: 'texto',
            ),
            DocumentoModel(
              id: 'd2',
              titulo: 'Receta Corazón',
              descripcion: 'Cardiólogo Dr. Perez',
              valor: 'assets/receta_demo.pdf', // Ruta simulada
              tipo: 'archivo',
            ),
          ],
        ),
        PersonaModel(
          id: '2',
          nombre: 'Tío Jorge',
          edad: '75 años',
          documentos: [],
        ),
      ];
    }

    _isLoading = false;
    notifyListeners(); // Avisa a la vista que ya hay datos para mostrar
  }

  // Método para agregar una nueva persona
  void agregarPersona(PersonaModel nuevaPersona) {
    _personas.add(nuevaPersona);
    notifyListeners(); // Actualiza la lista en pantalla
  }

  // Método para eliminar una persona
  void eliminarPersona(String id) {
    _personas.removeWhere((p) => p.id == id);
    notifyListeners();
  }
}