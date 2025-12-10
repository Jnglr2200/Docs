import 'dart:io';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../models/documento_model.dart';
import '../widgets/big_button.dart';

class DocumentFormPage extends StatefulWidget {
  final DocumentoModel? documentoExistente;
  final Function(DocumentoModel) onSave;

  const DocumentFormPage({

    super.key,
    this.documentoExistente,
    required this.onSave,
  });

  @override
  State<DocumentFormPage> createState() => _DocumentFormPageState();
}

class _DocumentFormPageState extends State<DocumentFormPage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _tituloCtrl;
  late TextEditingController _descCtrl;
  late TextEditingController _textoDatoCtrl;

  String? _rutaImagen;
  String _categoriaSeleccionada = 'General'; // Valor por defecto

  // Lista de categorías disponibles
  final List<String> _categorias = ['General', 'Salud', 'Legal', 'Financiero', 'Personal'];

  @override
  void initState() {
    super.initState();
    _tituloCtrl = TextEditingController(text: widget.documentoExistente?.titulo ?? '');
    _descCtrl = TextEditingController(text: widget.documentoExistente?.descripcion ?? '');
    _textoDatoCtrl = TextEditingController(text: widget.documentoExistente?.datoTexto ?? '');
    _rutaImagen = widget.documentoExistente?.rutaImagen;

    if (widget.documentoExistente != null) {
      _categoriaSeleccionada = widget.documentoExistente!.categoria;
    }
  }

  @override
  void dispose() {
    _tituloCtrl.dispose();
    _descCtrl.dispose();
    _textoDatoCtrl.dispose();
    super.dispose();
  }

  void _guardar() {
    if (_formKey.currentState!.validate()) {
      final nuevoDoc = DocumentoModel(
        id: widget.documentoExistente?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        titulo: _tituloCtrl.text,
        descripcion: _descCtrl.text,
        categoria: _categoriaSeleccionada, // Guardamos la categoría seleccionada
        datoTexto: _textoDatoCtrl.text.isEmpty ? null : _textoDatoCtrl.text,
        rutaImagen: _rutaImagen,
      );

      widget.onSave(nuevoDoc);
      Navigator.pop(context);
    }
  }

  void _tomarFoto() {
    setState(() {
      _rutaImagen = 'assets/simulacion_foto.jpg';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Simulación: Foto seleccionada")),
    );
  }

  @override
  Widget build(BuildContext context) {
    final esEdicion = widget.documentoExistente != null;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Text(esEdicion ? "Editar Documento" : "Nuevo Documento"),
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle("Información Básica"),

              // Título
              _buildTextField(
                controller: _tituloCtrl,
                label: "Título",
                hint: "Ej: Cédula, Receta...",
                icon: Icons.title,
                validator: (v) => v!.isEmpty ? "Obligatorio" : null,
              ),
              const SizedBox(height: 16),

              // Descripción
              _buildTextField(
                controller: _descCtrl,
                label: "Descripción",
                hint: "Ej: De la abuela...",
                icon: Icons.description,
              ),
              const SizedBox(height: 16),

              // Selector de Categoría (Dropdown)
              DropdownButtonFormField<String>(
                value: _categoriaSeleccionada,
                decoration: InputDecoration(
                  labelText: "Tipo de Documento",
                  prefixIcon: const Icon(Icons.category, color: AppColors.primaryBlue),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Colors.white,
                ),
                items: _categorias.map((cat) {
                  return DropdownMenuItem(value: cat, child: Text(cat));
                }).toList(),
                onChanged: (val) => setState(() => _categoriaSeleccionada = val!),
              ),

              const SizedBox(height: 30),

              // Sección Imagen
              _buildSectionTitle("Imagen (Opcional)"),
              Container(
                width: double.infinity,
                height: 180,
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.grey.shade400),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: _rutaImagen != null
                    ? Stack(
                  fit: StackFit.expand,
                  children: [
                    _rutaImagen!.contains('assets')
                        ? const Center(child: Icon(Icons.image, size: 60, color: Colors.blue))
                        : Image.file(File(_rutaImagen!), fit: BoxFit.cover),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: CircleAvatar(
                        backgroundColor: Colors.red,
                        child: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.white),
                          onPressed: () => setState(() => _rutaImagen = null),
                        ),
                      ),
                    )
                  ],
                )
                    : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.camera_alt, size: 40, color: Colors.grey),
                    TextButton(onPressed: _tomarFoto, child: const Text("AGREGAR FOTO"))
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // Sección Texto
              _buildSectionTitle("Dato para Copiar (Opcional)"),
              _buildTextField(
                controller: _textoDatoCtrl,
                label: "Texto / Número",
                hint: "Ej: 17555...",
                icon: Icons.copy,
              ),

              const SizedBox(height: 40),

              BigButton(
                label: "GUARDAR",
                icon: Icons.save,
                backgroundColor: AppColors.successGreen,
                onTap: _guardar,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryBlue)),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      style: const TextStyle(fontSize: 18),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: AppColors.primaryBlue),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }
}