
import 'documento_model.dart'; // Asegúrate de que el import coincida con tu nombre de proyecto

// Modelo que representa a un familiar (Abuela, Tío, etc.)
class PersonaModel {
  final String id;
  final String nombre;       // "Abuela María"
  final String edad;         // "82 años"
  final String? fotoPath;    // Ruta de la imagen de perfil en el dispositivo (puede ser null)
  final List<DocumentoModel> documentos; // Lista de documentos asociados a esta persona

  PersonaModel({
    required this.id,
    required this.nombre,
    required this.edad,
    this.fotoPath,
    this.documentos = const [], // Inicializa lista vacía por defecto
  });

  // Método para convertir a Mapa (para guardar en base de datos)
  // Nota: Para simplificar, aquí no guardamos la lista completa de documentos anidada,
  // usualmente se guardan en tablas separadas, pero para JSON simple sirve.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'edad': edad,
      'fotoPath': fotoPath,
      'documentos': documentos.map((x) => x.toMap()).toList(),
    };
  }

  // Crear Persona desde Mapa
  factory PersonaModel.fromMap(Map<String, dynamic> map) {
    return PersonaModel(
      id: map['id'] ?? '',
      nombre: map['nombre'] ?? '',
      edad: map['edad'] ?? '',
      fotoPath: map['fotoPath'],
      documentos: List<DocumentoModel>.from(
        (map['documentos'] as List? ?? []).map<DocumentoModel>(
              (x) => DocumentoModel.fromMap(x),
        ),
      ),
    );
  }
}