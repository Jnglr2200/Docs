import 'dart:convert';
import 'documento_model.dart'; // Asegúrate de que este archivo exista, si no, puedes quitar la lista de documentos del map
import 'dart:convert';


class PersonaModel {
  final String id;
  final String nombre;
  final String edad;
  final String? fotoPath;
  final String relacion;
  final List<DocumentoModel> documentos;

  PersonaModel({
    required this.id,
    required this.nombre,
    required this.edad,
    this.fotoPath,
    this.relacion = 'Familiar',
    this.documentos = const [],
  });

  // Método principal para convertir a Mapa (JSON)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'edad': edad,
      'fotoPath': fotoPath,
      'relacion': relacion,
      'documentos': documentos.map((x) => x.toJson()).toList(),
    };
  }

  // --- CORRECCIÓN ---
  // Agregamos toMap() como un alias de toJson().
  // Esto soluciona el error en HomePage y HomeController que llaman a .toMap()
  Map<String, dynamic> toMap() => toJson();

  // Crear desde Mapa (para leer de SharedPreferences)
  factory PersonaModel.fromMap(Map<String, dynamic> map) {
    return PersonaModel(
      id: map['id'] ?? '',
      nombre: map['nombre'] ?? '',
      edad: map['edad'] ?? '',
      fotoPath: map['fotoPath'],
      relacion: map['relacion'] ?? 'Familiar',
      documentos: map['documentos'] != null
          ? List<DocumentoModel>.from(
          (map['documentos'] as List).map((x) => DocumentoModel.fromJson(x)))
          : [],
    );
  }

  // Factory fromJson para compatibilidad
  factory PersonaModel.fromJson(Map<String, dynamic> map) => PersonaModel.fromMap(map);

  // Getters útiles para UI
  String get nombreCompleto => nombre;
  String get edadDisplay => "$edad años";
}