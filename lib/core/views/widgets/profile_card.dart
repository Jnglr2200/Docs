import 'dart:io';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_styles.dart';
import '../../../models/persona_model.dart';
import '../detail/detail_page.dart';

class ProfileCard extends StatelessWidget {
  final PersonaModel persona;

  const ProfileCard({super.key, required this.persona});

  // Función para manejar la navegación a la vista de detalle
  void _navigateToDetail(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailPage(persona: persona),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: InkWell(
          onTap: () => _navigateToDetail(context),
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // 1. Foto Circular Grande
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.lightBlue,
                    border: Border.all(color: AppColors.primaryBlue.withOpacity(0.3), width: 2),
                    image: persona.fotoPath != null
                    // Usamos FileImage para cargar la imagen desde la ruta local
                        ? DecorationImage(image: FileImage(File(persona.fotoPath!)), fit: BoxFit.cover)
                        : null,
                  ),
                  child: persona.fotoPath == null
                      ? const Icon(Icons.person, size: 60, color: AppColors.primaryBlue)
                      : null,
                ),

                const SizedBox(height: 16),

                // 2. Información Texto
                Text(
                  persona.nombre,
                  style: AppStyles.headline2,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  persona.edad,
                  style: AppStyles.bodyTextSecondary,
                ),

                const SizedBox(height: 20),

                // 3. Indicador de Documentos y Botón Falso
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.folder_open, color: Colors.white, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          "VER ${persona.documentos.length} DOCUMENTOS",
                          style: AppStyles.buttonLabel.copyWith(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}