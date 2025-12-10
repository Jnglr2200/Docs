import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import '../../models/persona_model.dart';

class AddPersonPage extends StatefulWidget {
  const AddPersonPage({super.key});

  @override
  State<AddPersonPage> createState() => _AddPersonPageState();
}

class _AddPersonPageState extends State<AddPersonPage> {
  // Controladores
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _edadController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  // FocusNodes para efectos de selección automática
  final FocusNode _nombreFocus = FocusNode();
  final FocusNode _edadFocus = FocusNode();

  XFile? _selectedImage;
  bool _isSaving = false;

  // Estilos (Consistentes con el resto de la App)
  final Color kPrimaryColor = const Color(0xFF2196F3);
  final Color kBackgroundColor = const Color(0xFFF5F5F5);

  @override
  void initState() {
    super.initState();
    // Configurar autoselección para los campos
    _nombreFocus.addListener(() => _handleFocusSelection(_nombreController, _nombreFocus));
    _edadFocus.addListener(() => _handleFocusSelection(_edadController, _edadFocus));
  }

  void _handleFocusSelection(TextEditingController controller, FocusNode node) {
    if (node.hasFocus) {
      Timer(const Duration(milliseconds: 50), () {
        if (!mounted) return;
        controller.selection = TextSelection(
          baseOffset: 0,
          extentOffset: controller.text.length,
        );
      });
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _edadController.dispose();
    _nombreFocus.dispose();
    _edadFocus.dispose();
    super.dispose();
  }

  // --- LÓGICA DE FOTO ---
  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? photo = await _picker.pickImage(source: source);
      if (photo != null) {
        setState(() => _selectedImage = photo);
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
  Future<void> _guardarFamiliar() async {
    if (_nombreController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Por favor escribe un nombre")),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      String? localImagePath;

      // Si hay foto, la guardamos permanentemente en la app
      if (_selectedImage != null) {
        final directory = await getApplicationDocumentsDirectory();
        final String fileName = 'profile_${DateTime.now().millisecondsSinceEpoch}_${path.basename(_selectedImage!.path)}';
        localImagePath = path.join(directory.path, fileName);
        await File(_selectedImage!.path).copy(localImagePath);
      }

      // Creamos el objeto PersonaModel para devolverlo
      final nuevaPersona = PersonaModel(
        nombre: _nombreController.text,
        edad: int.tryParse(_edadController.text) ?? 0,
        fotoPath: localImagePath,
      );

      if (mounted) {
        // Retornamos el objeto creado a la pantalla anterior
        Navigator.pop(context, nuevaPersona);
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
        title: const Text("Nuevo Familiar", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
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
                        image: _selectedImage != null
                            ? DecorationImage(
                          image: FileImage(File(_selectedImage!.path)),
                          fit: BoxFit.cover,
                        )
                            : null,
                      ),
                      child: _selectedImage == null
                          ? Icon(Icons.person_add_alt_1, size: 60, color: Colors.grey.shade400)
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
              "Toca para agregar foto",
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
                  // CAMPO NOMBRE
                  TextField(
                    controller: _nombreController,
                    focusNode: _nombreFocus,
                    style: const TextStyle(fontSize: 18),
                    textCapitalization: TextCapitalization.words,
                    decoration: InputDecoration(
                      labelText: "Nombre Completo",
                      labelStyle: TextStyle(fontSize: 18, color: Colors.grey[600]),
                      hintText: "Ej. María Pérez",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                      prefixIcon: Icon(Icons.person, color: kPrimaryColor),
                      suffixIcon: _nombreFocus.hasFocus
                          ? IconButton(icon: const Icon(Icons.clear), onPressed: () => _nombreController.clear())
                          : null,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // CAMPO EDAD
                  TextField(
                    controller: _edadController,
                    focusNode: _edadFocus,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(fontSize: 18),
                    decoration: InputDecoration(
                      labelText: "Edad",
                      labelStyle: TextStyle(fontSize: 18, color: Colors.grey[600]),
                      hintText: "Ej. 65",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
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
                onPressed: _isSaving ? null : _guardarFamiliar,
                icon: _isSaving
                    ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
                    : const Icon(Icons.person_add, size: 28, color: Colors.white),
                label: Text(
                  _isSaving ? " GUARDANDO..." : "GUARDAR FAMILIAR",
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