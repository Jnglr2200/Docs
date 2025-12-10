import 'dart:io';
import 'package:flutter/material.dart';
import '../../core/../constants/app_colors.dart';
import '../../../core/constants/app_styles.dart';
import '../../../models/persona_model.dart';
import '../detail/detail_page.dart';

class ProfileCard extends StatelessWidget {
  final PersonaModel persona;

  const ProfileCard({super.key, required this.persona});

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
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _navigateToDetail(context),
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min, // Se ajusta al contenido
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // 1. Foto Circular Grande Centrada
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.lightBlue,
                    border: Border.all(
                      color: AppColors.primaryBlue.withOpacity(0.1),
                      width: 4,
                    ),
                    image: persona.fotoPath != null
                        ? DecorationImage(
                      image: FileImage(File(persona.fotoPath!)),
                      fit: BoxFit.cover,
                    )
                        : null,
                  ),
                  child: persona.fotoPath == null
                      ? const Icon(Icons.person, size: 50, color: AppColors.primaryBlue)
                      : null,
                ),

                const SizedBox(height: 16),

                // 2. Información Centrada
                Text(
                  persona.nombre,
                  style: AppStyles.headline2.copyWith(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  persona.edad,
                  style: AppStyles.bodyTextSecondary.copyWith(
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 20),

                // 3. Botón "VER DATOS" (Ancho completo)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _navigateToDetail(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30), // Bordes muy redondeados
                      ),
                      elevation: 2,
                    ),
                    child: Text(
                      "VER DATOS",
                      style: AppStyles.buttonLabel.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}