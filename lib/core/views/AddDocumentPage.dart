import 'dart:io';
import 'dart:async'; // Necesario para el Timer del foco
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class AddDocumentPage extends StatefulWidget {
  final XFile? imageFile;

  const AddDocumentPage({super.key, this.imageFile});

  @override
  State<AddDocumentPage> createState() => _AddDocumentPageState();
}

class _AddDocumentPageState extends State<AddDocumentPage> {
  final TextEditingController _tituloController = TextEditingController();
  final TextEditingController _contenidoController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  // --- FOCO PARA AUTESELECCIÓN ---
  final FocusNode _tituloFocusNode = FocusNode();

  XFile? _selectedImage;
  String? _tipoSeleccionado;
  final List<String> _tiposDocumento = ['Identificación', 'Factura', 'Receta', 'Contrato', 'Otro'];
  bool _isSaving = false;

  // Estilos unificados
  final Color kPrimaryColor = const Color(0xFF2196F3);
  final Color kBackgroundColor = const Color(0xFFF5F5F5);

  @override
  void initState() {
    super.initState();
    _tipoSeleccionado = _tiposDocumento.first;
    _tituloController.text = "Nuevo Documento";
    _selectedImage = widget.imageFile;

    // Listener para seleccionar todo el texto cuando el campo recibe el foco
    _tituloFocusNode.addListener(() {
      if (_tituloFocusNode.hasFocus) {
        // Usamos un pequeño delay para asegurar que el evento de tap no quite la selección
        Timer(const Duration(milliseconds: 50), () {
          if (!mounted) return;
          _tituloController.selection = TextSelection(
            baseOffset: 0,
            extentOffset: _tituloController.text.length,
          );
        });
      }
    });
  }

  @override
  void dispose() {
    _tituloFocusNode.dispose();
    _tituloController.dispose();
    _contenidoController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? photo = await _picker.pickImage(source: source);
      if (photo != null) {
        setState(() {
          _selectedImage = photo;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  void _mostrarOpcionesFoto() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library, size: 30),
              title: const Text('Galería', style: TextStyle(fontSize: 18)),
              onTap: () { Navigator.pop(ctx); _pickImage(ImageSource.gallery); },
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera, size: 30),
              title: const Text('Cámara', style: TextStyle(fontSize: 18)),
              onTap: () { Navigator.pop(ctx); _pickImage(ImageSource.camera); },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _guardarDocumento() async {
    if (_selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Por favor agrega una imagen del documento")),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final directory = await getApplicationDocumentsDirectory();
      final String fileName = '${DateTime.now().millisecondsSinceEpoch}_${path.basename(_selectedImage!.path)}';
      final String localPath = path.join(directory.path, fileName);

      await File(_selectedImage!.path).copy(localPath);

      final docData = {
        'path': localPath,
        'tipo': _tipoSeleccionado,
        'titulo': _tituloController.text,
        'contenido': _contenidoController.text,
      };

      if (mounted) {
        Navigator.pop(context, docData);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        toolbarHeight: 70,
        title: const Text(
            "Nuevo Documento",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)
        ),
        backgroundColor: kPrimaryColor,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- 1. ÁREA DE IMAGEN ---
            Text(
                "1. Imagen del documento",
                style: TextStyle(fontSize: 18, color: Colors.grey[700], fontWeight: FontWeight.bold)
            ),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: _mostrarOpcionesFoto,
              child: Container(
                height: 250,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey.shade300),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))
                  ],
                ),
                child: _selectedImage != null
                    ? ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.file(
                    File(_selectedImage!.path),
                    fit: BoxFit.cover,
                  ),
                )
                    : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_a_photo_outlined, size: 60, color: kPrimaryColor),
                    const SizedBox(height: 10),
                    Text(
                        "Toca para tomar foto",
                        style: TextStyle(color: kPrimaryColor, fontSize: 18, fontWeight: FontWeight.w500)
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),

            // --- 2. DETALLES ---
            Text(
                "2. Detalles",
                style: TextStyle(fontSize: 18, color: Colors.grey[700], fontWeight: FontWeight.bold)
            ),
            const SizedBox(height: 10),

            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))
                  ]
              ),
              child: Column(
                children: [
                  // SELECTOR TIPO
                  DropdownButtonFormField<String>(
                    value: _tipoSeleccionado,
                    style: const TextStyle(fontSize: 18, color: Colors.black87),
                    decoration: InputDecoration(
                      labelText: "Tipo de Documento",
                      labelStyle: TextStyle(fontSize: 18, color: Colors.grey[600]),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                      prefixIcon: Icon(Icons.category, color: kPrimaryColor),
                    ),
                    items: _tiposDocumento.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                    onChanged: (val) => setState(() => _tipoSeleccionado = val),
                  ),
                  const SizedBox(height: 20),

                  // CAMPO TÍTULO (Con auto-selección)
                  TextField(
                    controller: _tituloController,
                    focusNode: _tituloFocusNode, // <--- AQUÍ VINCULAMOS EL FOCUS
                    style: const TextStyle(fontSize: 18),
                    decoration: InputDecoration(
                      labelText: "Título",
                      labelStyle: TextStyle(fontSize: 18, color: Colors.grey[600]),
                      hintText: "Ej. Factura de Luz",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                      prefixIcon: Icon(Icons.title, color: kPrimaryColor),
                      // Icono para borrar rápido
                      suffixIcon: _tituloFocusNode.hasFocus
                          ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () => _tituloController.clear()
                      )
                          : null,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // CAMPO CONTENIDO
                  TextField(
                    controller: _contenidoController,
                    maxLines: 4,
                    style: const TextStyle(fontSize: 16),
                    decoration: InputDecoration(
                      labelText: "Texto a copiar (Opcional)",
                      labelStyle: TextStyle(fontSize: 18, color: Colors.grey[600]),
                      hintText: "Escribe aquí números de cuenta, códigos, etc...",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      alignLabelWithHint: true,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // --- BOTÓN GUARDAR GRANDE ---
            SizedBox(
              height: 60,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimaryColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  elevation: 5,
                ),
                onPressed: _isSaving ? null : _guardarDocumento,
                icon: _isSaving
                    ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
                    : const Icon(Icons.save, size: 28, color: Colors.white),
                label: Text(
                  _isSaving ? " GUARDANDO..." : "GUARDAR DOCUMENTO",
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1),
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}