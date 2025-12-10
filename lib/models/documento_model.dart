class DocumentoModel {
  final String id;
  final String titulo;
  final String descripcion;
  final String categoria; // E.g., 'Personal', 'Salud', 'Legal'
  final String? datoTexto; // Para documentos como cédulas o números
  final String? rutaImagen; // Para documentos escaneados o recetas

  DocumentoModel({
    required this.id,
    required this.titulo,
    required this.descripcion,
    required this.categoria,
    this.datoTexto,
    this.rutaImagen,
  });

  // Método para convertir a Mapa (Compatibilidad con PersonaModel)
  Map<String, dynamic> toMap() => {
    'id': id,
    'titulo': titulo,
    'descripcion': descripcion,
    'categoria': categoria,
    'datoTexto': datoTexto,
    'rutaImagen': rutaImagen,
  };

  // Crear Documento desde Mapa (Compatibilidad con PersonaModel)
  factory DocumentoModel.fromMap(Map<String, dynamic> map) => DocumentoModel(
    id: map['id'] as String,
    titulo: map['titulo'] as String,
    descripcion: map['descripcion'] as String,
    categoria: map['categoria'] as String,
    datoTexto: map['datoTexto'] as String?,
    rutaImagen: map['rutaImagen'] as String?,
  );

  // Alias toJson para mantener compatibilidad si algo más lo usa
  Map<String, dynamic> toJson() => toMap();

  // Alias fromJson para mantener compatibilidad
  factory DocumentoModel.fromJson(Map<String, dynamic> json) =>
      DocumentoModel.fromMap(json);
}