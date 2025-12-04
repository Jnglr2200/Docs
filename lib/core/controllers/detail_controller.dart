import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Necesario para el Portapapeles (Clipboard)
// import 'package:share_plus/share_plus.dart'; // Descomentar cuando instales share_plus
import "package:docs2/models/documento_model.dart";
import 'package:docs2/models/persona_model.dart';

// Controlador para la Pantalla de Detalle
// Maneja la lógica de copiar texto, abrir archivos y agregar documentos a una persona específica.
class DetailController extends ChangeNotifier {

  // La persona que se está visualizando actualmente
  PersonaModel? _personaActual;

  PersonaModel? get persona => _personaActual;

  // Inicializar con una persona específica al entrar a la pantalla
  void setPersona(PersonaModel persona) {
    _personaActual = persona;
    // No necesitamos notifyListeners aquí si se llama antes de construir la vista,
    // pero si cambia dinámicamente, sí.
  }

  // Lógica para COPIAR texto al portapapeles
  Future<void> copiarAlPortapapeles(BuildContext context, String texto) async {
    try {
      await Clipboard.setData(ClipboardData(text: texto));

      // Feedback visual para el usuario mayor (SnackBar grande)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("¡Copiado! Ya puedes pegarlo.", style: TextStyle(fontSize: 18)),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      debugPrint("Error al copiar: $e");
    }
  }

  // Lógica para COMPARTIR/DESCARGAR archivo o texto
  // Esta función simula el uso de share_plus
  Future<void> compartirDocumento(DocumentoModel doc) async {
    if (doc.tipo == 'texto') {
      // Compartir texto puro
      // await Share.share('${doc.titulo}: ${doc.valor}');
      print("Simulando compartir texto: ${doc.valor}");
    } else {
      // Compartir archivo (Imagen o PDF)
      // await Share.shareXFiles([XFile(doc.valor)], text: doc.titulo);
      print("Simulando compartir archivo de ruta: ${doc.valor}");
    }
  }

  // Método para agregar un documento a la persona actual
  void agregarDocumento(DocumentoModel nuevoDoc) {
    if (_personaActual != null) {
      _personaActual!.documentos.add(nuevoDoc);
      notifyListeners(); // Actualiza la UI para mostrar el nuevo desplegable

      // Aquí llamarías al repositorio para guardar en base de datos permanentemente
      print("Guardando documento en base de datos...");
    }
  }
}