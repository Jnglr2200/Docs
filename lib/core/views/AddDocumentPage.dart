import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class AddDocumentPage extends StatefulWidget {
  // Ahora la imagen es opcional al entrar
  final XFile? imageFile;

  const AddDocumentPage({super.key, this.imageFile});

  @override
  State<AddDocumentPage> createState() => _AddDocumentPageState();
}

class _AddDocumentPageState extends State<AddDocumentPage> {
  final TextEditingController _tituloController = TextEditingController();
  final TextEditingController _contenidoController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  XFile? _selectedImage;
  String? _tipoSeleccionado;
  final List<String> _tiposDocumento = ['Identificación', 'Factura', 'Receta', 'Contrato', 'Otro'];
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _tipoSeleccionado = _tiposDocumento.first;
    _tituloController.text = "Nuevo Documento";
    // Si recibimos una imagen desde fuera, la usamos
    _selectedImage = widget.imageFile;
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
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Galería'),
              onTap: () { Navigator.pop(ctx); _pickImage(ImageSource.gallery); },
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: const Text('Cámara'),
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
      appBar: AppBar(
        title: const Text("Nuevo Documento"),
        backgroundColor: Colors.blueAccent,
        actions: [
          IconButton(
            onPressed: _isSaving ? null : _guardarDocumento,
            icon: _isSaving
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white))
                : const Icon(Icons.check),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Área de selección de imagen
            GestureDetector(
              onTap: _mostrarOpcionesFoto,
              child: Container(
                height: 250,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade400),
                ),
                child: _selectedImage != null
                    ? ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(
                    File(_selectedImage!.path),
                    fit: BoxFit.cover,
                  ),
                )
                    : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.add_a_photo, size: 50, color: Colors.grey),
                    SizedBox(height: 10),
                    Text("Toca para agregar foto", style: TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Campos del formulario
            DropdownButtonFormField<String>(
              value: _tipoSeleccionado,
              decoration: const InputDecoration(
                labelText: "Tipo de Documento",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.category),
              ),
              items: _tiposDocumento.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
              onChanged: (val) => setState(() => _tipoSeleccionado = val),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: _tituloController,
              decoration: const InputDecoration(
                labelText: "Título",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.title),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: _contenidoController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: "Notas / Texto extraído",
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
            ),
          ],
        ),
      ),
    );
  }
}