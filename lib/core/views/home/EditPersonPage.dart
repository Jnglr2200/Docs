import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import '../../../models/persona_model.dart';

class EditPersonPage extends StatefulWidget {
  final PersonaModel persona;

  const EditPersonPage({super.key, required this.persona});

  @override
  State<EditPersonPage> createState() => _EditPersonPageState();
}

class _EditPersonPageState extends State<EditPersonPage> {
  // Controladores
  late TextEditingController _nombreController;
  late TextEditingController _edadController;
  final ImagePicker _picker = ImagePicker();

  XFile? _selectedImage;
  String? _currentImagePath;
  bool _isSaving = false;

  // Estilos
  final Color kPrimaryColor = const Color(0xFF2196F3);
  final Color kBackgroundColor = const Color(0xFFF5F5F5);

  @override
  void initState() {
    super.initState();
    // Inicializamos con los datos existentes
    _nombreController = TextEditingController(text: widget.persona.nombre);
    _edadController = TextEditingController(text: widget.persona.edad);
    _currentImagePath = widget.persona.fotoPath;
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _edadController.dispose();
    super.dispose();
  }

  // --- LÓGICA DE FOTO ---
  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? photo = await _picker.pickImage(source: source);
      if (photo != null) {
        setState(() {
          _selectedImage = photo;
          // Al seleccionar nueva imagen, dejamos de mostrar la antigua temporalmente
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  void _mostrarOpcionesFoto() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
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

  // --- LÓGICA DE GUARDADO ---
  Future<void> _guardarCambios() async {
    if (_nombreController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Por favor escribe un nombre")),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      String? finalImagePath = _currentImagePath;

      // Si el usuario seleccionó una NUEVA foto, la guardamos
      if (_selectedImage != null) {
        final directory = await getApplicationDocumentsDirectory();
        final String fileName = 'profile_${DateTime.now().millisecondsSinceEpoch}_${path.basename(_selectedImage!.path)}';
        finalImagePath = path.join(directory.path, fileName);
        await File(_selectedImage!.path).copy(finalImagePath);
      }

      // Creamos el objeto PersonaModel ACTUALIZADO (mismo ID)
      final personaActualizada = PersonaModel(
        id: widget.persona.id, // MANTENEMOS EL ID ORIGINAL
        nombre: _nombreController.text,
        edad: (int.tryParse(_edadController.text) ?? 0).toString(),
        fotoPath: finalImagePath,
        relacion: widget.persona.relacion,
        documentos: widget.persona.documentos, // Mantenemos sus documentos
      );

      if (mounted) {
        Navigator.pop(context, personaActualizada);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error al guardar: $e")));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    ImageProvider? imageProvider;
    if (_selectedImage != null) {
      imageProvider = FileImage(File(_selectedImage!.path));
    } else if (_currentImagePath != null && File(_currentImagePath!).existsSync()) {
      imageProvider = FileImage(File(_currentImagePath!));
    }

    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        toolbarHeight: 70,
        title: const Text("Editar Perfil", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        backgroundColor: kPrimaryColor,
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- 1. FOTO DE PERFIL ---
            Center(
              child: GestureDetector(
                onTap: _mostrarOpcionesFoto,
                child: Stack(
                  children: [
                    Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: kPrimaryColor, width: 3),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))
                        ],
                        image: imageProvider != null
                            ? DecorationImage(image: imageProvider, fit: BoxFit.cover)
                            : null,
                      ),
                      child: imageProvider == null
                          ? Icon(Icons.person, size: 80, color: Colors.grey.shade300)
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: kPrimaryColor,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                      ),
                    )
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              "Toca para cambiar foto",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey, fontWeight: FontWeight.w500),
            ),

            const SizedBox(height: 30),

            // --- 2. DATOS PERSONALES ---
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
                  TextField(
                    controller: _nombreController,
                    style: const TextStyle(fontSize: 18),
                    textCapitalization: TextCapitalization.words,
                    decoration: InputDecoration(
                      labelText: "Nombre Completo",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      prefixIcon: Icon(Icons.person, color: kPrimaryColor),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _edadController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(fontSize: 18),
                    decoration: InputDecoration(
                      labelText: "Edad",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      prefixIcon: Icon(Icons.cake, color: kPrimaryColor),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // --- BOTÓN GUARDAR ---
            SizedBox(
              height: 60,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimaryColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  elevation: 5,
                ),
                onPressed: _isSaving ? null : _guardarCambios,
                icon: _isSaving
                    ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
                    : const Icon(Icons.save, size: 28, color: Colors.white),
                label: Text(
                  _isSaving ? " GUARDANDO..." : "GUARDAR CAMBIOS",
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}