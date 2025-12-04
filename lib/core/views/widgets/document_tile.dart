import 'dart:io';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_styles.dart';
import '../../../models/documento_model.dart';
import '../../controllers/detail_controller.dart';
// Importamos el widget BigButton que acabamos de crear
import 'big_button.dart';

class DocumentTile extends StatelessWidget {
  final DocumentoModel documento;
  // Pasamos el controlador para poder ejecutar las acciones (copiar/compartir)
  final DetailController controller;

  const DocumentTile({
    super.key,
    required this.documento,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final isFile = documento.tipo == 'archivo';

    // Icono y color de identificación según el tipo
    final iconData = isFile ? Icons.description : Icons.text_fields;
    final colorAccent = isFile ? AppColors.actionOrange : AppColors.primaryBlue;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Theme(
          // Quitamos las líneas divisorias por defecto
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            backgroundColor: Colors.white,
            collapsedBackgroundColor: Colors.white,

            // Icono del documento (Leading)
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: colorAccent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                iconData,
                color: colorAccent,
                size: 30,
              ),
            ),

            // Título del documento (Título)
            title: Text(
              documento.titulo,
              style: AppStyles.bodyTextPrimary.copyWith(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(documento.descripcion, style: AppStyles.bodyTextSecondary),

            // CONTENIDO DESPLEGABLE (Children)
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
                    // Muestra el valor o la previsualización
                    _buildValueDisplay(isFile),
                    const SizedBox(height: 20),

                    // Botones de Acción
                    _buildActionButtons(context, isFile),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget para mostrar el valor del documento (Texto o Imagen)
  Widget _buildValueDisplay(bool isFile) {
    return Container(
      padding: const EdgeInsets.all(16),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: isFile
          ? _buildFilePreview()
          : Text(
        documento.valor,
        style: AppStyles.documentValue,
        textAlign: TextAlign.center,
        maxLines: 5,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  // Muestra una previsualización de la imagen si es un archivo
  Widget _buildFilePreview() {
    // Nota: La lógica real de previsualización (e.g., FileImage, PDF viewer)
    // depende de si el 'valor' es una ruta de archivo real.
    // Aquí simulamos o mostramos el nombre del archivo.
    try {
      if (documento.valor.isNotEmpty && File(documento.valor).existsSync()) {
        if (documento.valor.toLowerCase().endsWith('.pdf')) {
          return Column(
            children: [
              const Icon(Icons.picture_as_pdf, size: 60, color: AppColors.warningRed),
              const SizedBox(height: 8),
              Text("Archivo PDF: ${documento.valor.split('/').last}", style: AppStyles.bodyTextPrimary),
            ],
          );
        }
        // Si es una imagen
        return Image.file(
          File(documento.valor),
          height: 150,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _buildPlaceholder("Error al cargar imagen"),
        );
      } else {
        return _buildPlaceholder("Archivo no encontrado: ${documento.valor.split('/').last}");
      }
    } catch (e) {
      return _buildPlaceholder("Ruta inválida o permiso denegado");
    }
  }

  // Placeholder para archivos que no se pueden mostrar
  Widget _buildPlaceholder(String message) {
    return Column(
      children: [
        const Icon(Icons.insert_drive_file, size: 60, color: AppColors.secondaryText),
        const SizedBox(height: 8),
        Text(message, style: AppStyles.bodyTextSecondary, textAlign: TextAlign.center),
      ],
    );
  }


  // Widget para los botones de acción
  Widget _buildActionButtons(BuildContext context, bool isFile) {
    return Row(
      children: [
        // Botón de COPIAR (solo para texto)
        if (!isFile)
          Expanded(
            child: BigButton(
              label: "COPIAR",
              icon: Icons.copy,
              backgroundColor: AppColors.successGreen,
              onTap: () => controller.copiarAlPortapapeles(context, documento.valor),
            ),
          ),

        SizedBox(width: isFile ? 0 : 12), // Espacio si hay dos botones

        // Botón de ABRIR/ENVIAR
        Expanded(
          child: BigButton(
            label: isFile ? "ABRIR" : "ENVIAR",
            icon: isFile ? Icons.download : Icons.share,
            backgroundColor: AppColors.actionOrange,
            onTap: () => controller.compartirDocumento(documento),
          ),
        ),
      ],
    );
  }
}