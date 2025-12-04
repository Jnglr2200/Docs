import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_styles.dart';

// Widget reusable para un botón grande, de alto contraste, ideal para la audiencia Senior.
class BigButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final Color backgroundColor;
  final Color iconColor;
  final Color textColor;

  const BigButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onTap,
    this.backgroundColor = AppColors.primaryBlue,
    this.iconColor = AppColors.backgroundWhite,
    this.textColor = AppColors.backgroundWhite,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        // Tamaño mínimo de 56px de alto, ideal para accesibilidad táctil
        minimumSize: const Size(double.infinity, 60),
        backgroundColor: backgroundColor,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          // Borde sutil para darle más presencia
          side: BorderSide(color: backgroundColor == Colors.white ? AppColors.primaryBlue : backgroundColor, width: 2),
        ),
        elevation: 4, // Sombra para que sea más tangible
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 30, color: iconColor),
          const SizedBox(width: 10),
          Text(
            label.toUpperCase(),
            style: AppStyles.buttonLabel.copyWith(
              color: textColor,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }
}