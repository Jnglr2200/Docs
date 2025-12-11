import 'dart:convert';
import 'dart:io';
import 'package:archive/archive_io.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path/path.dart' as path;

class BackupService {

  // --- EXPORTAR RESPALDO (CREAR ZIP) ---
  Future<bool> crearCopiaSeguridad(BuildContext context) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final appDir = await getApplicationDocumentsDirectory();

      // 1. Recopilar Datos de Personas
      final String? personasJson = prefs.getString('personas');
      if (personasJson == null) {
        throw "No hay datos para respaldar";
      }

      List<dynamic> personasList = jsonDecode(personasJson);
      Map<String, dynamic> backupData = {
        'personas': [], // Lista de personas con rutas saneadas
        'documentos': {}, // Map con listas de docs por persona
      };

      // Creamos el codificador ZIP
      var encoder = ZipFileEncoder();
      String zipPath = '${appDir.path}/respaldo_gestor_familiar.zip';
      encoder.create(zipPath);

      // 2. Procesar Personas e Imágenes de Perfil
      for (var p in personasList) {
        // Manejo de Foto de Perfil
        if (p['fotoPath'] != null && p['fotoPath'].toString().isNotEmpty) {
          File foto = File(p['fotoPath']);
          if (await foto.exists()) {
            String filename = path.basename(foto.path);
            encoder.addFile(foto, filename);
            // Guardamos solo el nombre del archivo, no la ruta completa (que cambia por cel)
            p['fotoPath'] = filename;
          }
        }

        // 3. Procesar Documentos de esta Persona
        // Replicamos la lógica de clave: docs_NombreSinEspacios
        String keyDocs = 'docs_${p['nombre'].toString().replaceAll(" ", "")}';
        String? docsJson = prefs.getString(keyDocs);

        if (docsJson != null) {
          List<dynamic> docsList = jsonDecode(docsJson);
          for (var doc in docsList) {
            if (doc['path'] != null && doc['path'].toString().isNotEmpty) {
              File docFile = File(doc['path']);
              if (await docFile.exists()) {
                String docFilename = path.basename(docFile.path);
                encoder.addFile(docFile, docFilename);
                doc['path'] = docFilename; // Saneamos ruta
              }
            }
          }
          // Guardamos la lista de docs procesada en el objeto maestro
          backupData['documentos'][keyDocs] = docsList;
        }
      }

      // Guardamos la lista de personas actualizada
      backupData['personas'] = personasList;

      // 4. Guardar el JSON maestro dentro del ZIP
      File jsonFile = File('${appDir.path}/data.json');
      await jsonFile.writeAsString(jsonEncode(backupData));
      encoder.addFile(jsonFile, 'data.json');

      encoder.close();

      // 5. Compartir el ZIP resultante
      final xFile = XFile(zipPath);
      await Share.shareXFiles([xFile], text: 'Copia de seguridad Gestor Familiar');

      return true;

    } catch (e) {
      debugPrint("Error creando backup: $e");
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
        );
      }
      return false;
    }
  }

  // --- IMPORTAR RESPALDO (LEER ZIP) ---
  Future<bool> restaurarCopiaSeguridad(BuildContext context) async {
    try {
      // 1. Seleccionar archivo
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['zip'],
      );

      if (result == null) return false; // Usuario canceló

      File zipFile = File(result.files.single.path!);
      final appDir = await getApplicationDocumentsDirectory();
      final prefs = await SharedPreferences.getInstance();

      // 2. Leer ZIP
      final bytes = await zipFile.readAsBytes();
      final archive = ZipDecoder().decodeBytes(bytes);

      // Buscar el archivo data.json primero
      ArchiveFile? jsonArchive = archive.findFile('data.json');
      if (jsonArchive == null) {
        throw "El archivo no es una copia válida (falta data.json)";
      }

      // Decodificar datos maestros
      final content = utf8.decode(jsonArchive.content);
      Map<String, dynamic> backupData = jsonDecode(content);

      // 3. Restaurar Imágenes
      for (final file in archive) {
        if (file.name == 'data.json') continue; // Saltar el json
        if (file.isFile) {
          final data = file.content as List<int>;
          File('${appDir.path}/${file.name}')
            ..createSync(recursive: true)
            ..writeAsBytesSync(data);
        }
      }

      // 4. Restaurar Preferencias (Reconstruyendo rutas)

      // A) Restaurar Personas
      List<dynamic> personasList = backupData['personas'];
      for (var p in personasList) {
        if (p['fotoPath'] != null && p['fotoPath'].toString().isNotEmpty) {
          // Reconstruimos la ruta completa con el directorio actual del cel
          p['fotoPath'] = path.join(appDir.path, p['fotoPath']);
        }
      }
      await prefs.setString('personas', jsonEncode(personasList));

      // B) Restaurar Documentos
      Map<String, dynamic> docsMap = backupData['documentos'];
      docsMap.forEach((key, value) async {
        List<dynamic> docsList = value;
        for (var doc in docsList) {
          if (doc['path'] != null && doc['path'].toString().isNotEmpty) {
            doc['path'] = path.join(appDir.path, doc['path']);
          }
        }
        await prefs.setString(key, jsonEncode(docsList));
      });

      return true;

    } catch (e) {
      debugPrint("Error restaurando backup: $e");
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error al restaurar: $e"), backgroundColor: Colors.red),
        );
      }
      return false;
    }
  }
}