// Modelo que representa un documento individual (Cédula, Receta, Correo, etc.)
class DocumentoModel {
  final String id;           // Identificador único
  final String titulo;       // Ejemplo: "Cédula", "Correo Electrónico"
  final String descripcion;  // Ejemplo: "Cédula de ciudadanía", "Correo principal"
  final String valor;        // El dato en sí (el número de cédula) o la ruta del archivo (path de imagen)
  final String tipo;         // 'texto' (para copiar) o 'archivo' (para imagen/pdf)

  DocumentoModel({
    required this.id,
    required this.titulo,
    required this.descripcion,
    required this.valor,
    required this.tipo,
  });

  // Método para crear una copia del documento (útil para editar)
  DocumentoModel copyWith({
    String? id,
    String? titulo,
    String? descripcion,
    String? valor,
    String? tipo,
  }) {
    return DocumentoModel(
      id: id ?? this.id,
      titulo: titulo ?? this.titulo,
      descripcion: descripcion ?? this.descripcion,
      valor: valor ?? this.valor,
      tipo: tipo ?? this.tipo,
    );
  }

  // Convertir a Mapa (para guardar en base de datos local o JSON)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'titulo': titulo,
      'descripcion': descripcion,
      'valor': valor,
      'tipo': tipo,
    };
  }

  // Crear Documento desde un Mapa (al leer de base de datos)
  factory DocumentoModel.fromMap(Map<String, dynamic> map) {
    return DocumentoModel(
      id: map['id'] ?? '',
      titulo: map['titulo'] ?? '',
      descripcion: map['descripcion'] ?? '',
      valor: map['valor'] ?? '',
      tipo: map['tipo'] ?? 'texto',
    );
  }
}