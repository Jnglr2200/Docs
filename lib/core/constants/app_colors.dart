// Definición de colores de la aplicación para accesibilidad y alto contraste.
import 'package:flutter/material.dart';

class AppColors {
  // --- Colores Primarios ---

  // Azul Profundo: Ideal para fondos de encabezado y botones principales (fuerte contraste).
  static const Color primaryBlue = Color(0xFF0D47A1); // Deep Blue (700)

  // Azul Claro: Para estados de "hover" o fondos de Cards activos.
  static const Color lightBlue = Color(0xFFE3F2FD); // Light Blue (50)

  // --- Colores de Texto y Fondo ---

  // Negro Fuerte: El mejor color para texto principal (Máximo contraste).
  static const Color primaryText = Color(0xFF212121); // Dark Gray/Black

  // Gris Suave: Para texto secundario o descripciones.
  static const Color secondaryText = Color(0xFF757575); // Medium Gray

  // Blanco: Fondo principal de la aplicación.
  static const Color backgroundWhite = Color(0xFFFFFFFF);

  // Gris de Fondo: Fondo del cuerpo de la app (ligeramente separado del blanco).
  static const Color backgroundLight = Color(0xFFF5F5F5); // Light Gray (100)

  // --- Colores de Acción (Botones y Notificaciones) ---

  // Éxito / Copiar: Para indicar una acción completada (e.g., texto copiado).
  static const Color successGreen = Color(0xFF388E3C); // Green (700)

  // Alerta / Error: Para notificaciones de peligro o acción fallida.
  static const Color warningRed = Color(0xFFD32F2F); // Red (700)

  // Descarga / Compartir: Para los botones de gestión de archivos.
  static const Color actionOrange = Color(0xFFFF9800); // Orange (500)
}