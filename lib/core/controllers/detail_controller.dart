import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Necesario para el Portapapeles (Clipboard)
import '../../models/documento_model.dart';
import '../../models/persona_model.dart';

class DetailController extends ChangeNotifier {
  PersonaModel? _personaActual;
  bool _isSaving = false; // Para mostrar loading al guardar

  PersonaModel? get persona => _personaActual;
  bool get isSaving => _isSaving;

  void setPersona(PersonaModel persona) {
    _personaActual = persona;
    // La notificación se hará al modificar documentos
  }

  // --- CRUD DOCUMENTOS ---

  // 1. Crear / Agregar
  Future<void> agregarDocumento(DocumentoModel nuevoDoc) async {
    if (_personaActual == null) return;

    _isSaving = true;
    notifyListeners();

    // Simular retardo de guardado en base de datos
    await Future.delayed(const Duration(milliseconds: 800));

    _personaActual!.documentos.add(nuevoDoc);

    // AQUÍ: Llamarías a UserRepository().updatePersona(_personaActual!)

    _isSaving = false;
    notifyListeners();
  }

  // 2. Editar / Actualizar
  Future<void> editarDocumento(DocumentoModel docEditado) async {
    if (_personaActual == null) return;

    _isSaving = true;
    notifyListeners();

    final index = _personaActual!.documentos.indexWhere((d) => d.id == docEditado.id);
    if (index != -1) {
      _personaActual!.documentos[index] = docEditado;
      // AQUÍ: Guardar en persistencia
    }

    await Future.delayed(const Duration(milliseconds: 500));
    _isSaving = false;
    notifyListeners();
  }

  // 3. Eliminar
  Future<void> eliminarDocumento(String idDoc) async {
    if (_personaActual == null) return;

    _personaActual!.documentos.removeWhere((d) => d.id == idDoc);
    // AQUÍ: Guardar en persistencia

    notifyListeners();
  }


  // Lógica para COPIAR texto al portapapeles
  Future<void> copiarAlPortapapeles(BuildContext context, String? texto) async {
    if (texto == null || texto.isEmpty) return;

    await Clipboard.setData(ClipboardData(text: texto));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("¡Copiado al portapapeles!", style: TextStyle(fontSize: 16)),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  // Lógica para COMPARTIR/DESCARGAR archivo o texto
  // Esta función simula el uso de share_plus
  Future<void> compartirArchivo(String? ruta) async {
    if (ruta == null) return;
    // Si tiene datoTexto, compartimos ambos o solo el texto.
    // Para simplificar, asumimos que aquí se compartirá la imagen/archivo.
    print("Compartiendo archivo de ruta: $ruta");
    // Implementar share_plus aquí si es necesario
  }
}