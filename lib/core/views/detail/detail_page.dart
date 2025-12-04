import 'dart:io';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_styles.dart';
import '../../../models/persona_model.dart';
import '../../../models/documento_model.dart';
import '../../controllers/detail_controller.dart';

class DetailPage extends StatefulWidget {
  final PersonaModel persona;

  const DetailPage({super.key, required this.persona});

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  late DetailController _controller;

  @override
  void initState() {
    super.initState();
    _controller = DetailController();
    _controller.setPersona(widget.persona);
  }

  @override
  Widget build(BuildContext context) {
    // Usamos ListenableBuilder para escuchar cambios en el controlador (ej. si se agrega un doc)
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, child) {
        final persona = _controller.persona!;

        return Scaffold(
          backgroundColor: AppColors.backgroundLight,
          appBar: AppBar(
            backgroundColor: AppColors.primaryBlue,
            toolbarHeight: 80, // AppBar más alta para facilitar alcance
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 30),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              persona.nombre.toUpperCase(),
              style: AppStyles.headline2.copyWith(color: Colors.white),
            ),
            centerTitle: true,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 40),
            child: Column(
              children: [
                // 1. Cabecera con Foto y Edad
                _buildHeader(persona),

                const SizedBox(height: 20),

                // Título de sección
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      const Icon(Icons.folder_shared, size: 32, color: AppColors.primaryBlue),
                      const SizedBox(width: 10),
                      Text("DOCUMENTOS", style: AppStyles.headline2.copyWith(color: AppColors.primaryBlue)),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                // 2. Lista de Documentos (Desplegables)
                if (persona.documentos.isEmpty)
                  _buildEmptyState()
                else
                  ListView.builder(
                    shrinkWrap: true, // Importante para usar dentro de SingleChildScrollView
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: persona.documentos.length,
                    itemBuilder: (context, index) {
                      return _buildDocumentTile(persona.documentos[index]);
                    },
                  ),

                const SizedBox(height: 30),

                // 3. Botón de Agregar (Flotante o fijo al final)
                _buildAddButton(),
              ],
            ),
          ),
        );
      },
    );
  }

  // --- WIDGETS AUXILIARES ---

  Widget _buildHeader(PersonaModel persona) {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.lightBlue,
              border: Border.all(color: AppColors.primaryBlue, width: 4),
              image: persona.fotoPath != null
                  ? DecorationImage(image: FileImage(File(persona.fotoPath!)), fit: BoxFit.cover)
                  : null,
            ),
            child: persona.fotoPath == null
                ? const Icon(Icons.person, size: 80, color: AppColors.primaryBlue)
                : null,
          ),
          const SizedBox(height: 16),
          Text(persona.nombre, style: AppStyles.headline2),
          const SizedBox(height: 4),
          Text(persona.edad, style: AppStyles.bodyTextSecondary.copyWith(fontSize: 20)),
        ],
      ),
    );
  }

  Widget _buildDocumentTile(DocumentoModel doc) {
    final isFile = doc.tipo == 'archivo';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Theme(
          // Quitamos las líneas divisorias por defecto del ExpansionTile para limpieza visual
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            backgroundColor: Colors.white,
            collapsedBackgroundColor: Colors.white,

            // Icono del documento
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isFile ? Colors.orange.shade50 : Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                isFile ? Icons.description : Icons.text_fields,
                color: isFile ? Colors.orange : AppColors.primaryBlue,
                size: 30,
              ),
            ),

            // Título del documento
            title: Text(
              doc.titulo,
              style: AppStyles.bodyTextPrimary.copyWith(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(doc.descripcion, style: AppStyles.bodyTextSecondary),

            // CONTENIDO DESPLEGABLE
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.backgroundLight,
                  border: Border(top: BorderSide(color: Colors.grey.shade200)),
                ),
                child: Column(
                  children: [
                    // Muestra el valor (texto o nombre archivo)
                    Container(
                      padding: const EdgeInsets.all(16),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Text(
                        isFile ? "Archivo adjunto: ${doc.valor.split('/').last}" : doc.valor,
                        style: AppStyles.documentValue,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Botones de Acción
                    Row(
                      children: [
                        if (!isFile) ...[
                          Expanded(
                            child: _buildActionButton(
                              icon: Icons.copy,
                              label: "COPIAR",
                              color: AppColors.successGreen,
                              onTap: () => _controller.copiarAlPortapapeles(context, doc.valor),
                            ),
                          ),
                          const SizedBox(width: 12),
                        ],
                        Expanded(
                          child: _buildActionButton(
                            icon: isFile ? Icons.download : Icons.share,
                            label: isFile ? "ABRIR" : "ENVIAR",
                            color: AppColors.actionOrange,
                            onTap: () => _controller.compartirDocumento(doc),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 3,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 30, color: Colors.white),
          const SizedBox(height: 4),
          Text(label, style: AppStyles.buttonLabel.copyWith(fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          Icon(Icons.folder_open, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 10),
          Text(
            "No hay documentos guardados aún.",
            textAlign: TextAlign.center,
            style: AppStyles.bodyTextSecondary,
          ),
        ],
      ),
    );
  }

  Widget _buildAddButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: ElevatedButton.icon(
        onPressed: () {
          // TODO: Navegar a pantalla de formulario para agregar documento
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Próximamente: Pantalla de Agregar Documento")),
          );
        },
        icon: const Icon(Icons.add_circle, size: 36, color: AppColors.primaryBlue),
        label: Text("AGREGAR NUEVO", style: AppStyles.buttonLabel.copyWith(color: AppColors.primaryBlue)),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          side: const BorderSide(color: AppColors.primaryBlue, width: 2),
          padding: const EdgeInsets.symmetric(vertical: 16),
          minimumSize: const Size(double.infinity, 60),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
    );
  }
}