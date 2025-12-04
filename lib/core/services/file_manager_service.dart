import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

// Servicio para manejar el guardado de imágenes y PDFs en el dispositivo
class FileManagerService {

  // Obtener la ruta del directorio de documentos de la app
  // (Esta carpeta es privada de la app y no se borra al limpiar caché)
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  // Mover un archivo temporal (ej. de la cámara) a almacenamiento permanente
  Future<String> saveFilePermanently(File file) async {
    try {
      // 1. Obtener ruta base
      final appDir = await _localPath;

      // 2. Generar nombre único usando la fecha actual
      final fileName = path.basename(file.path);
      final uniqueName = '${DateTime.now().millisecondsSinceEpoch}_$fileName';

      // 3. Crear la nueva ruta destino
      final savedImage = await file.copy('$appDir/$uniqueName');

      // 4. Retornar la ruta del nuevo archivo guardado
      return savedImage.path;
    } catch (e) {
      print('Error guardando archivo: $e');
      throw Exception('No se pudo guardar el archivo permanentemente');
    }
  }

  // Eliminar un archivo local (cuando borras un documento de la app)
  Future<void> deleteFile(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      print('Error borrando archivo: $e');
    }
  }

  // Obtener referencia a un archivo (para mostrarlo en la UI)
  File getFile(String path) {
    return File(path);
  }
}