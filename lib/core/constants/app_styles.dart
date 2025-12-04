import 'package:flutter/material.dart';
import 'package:docs2/core/constants/app_colors.dart'; // Importamos los colores

class AppStyles {
  // =========================================================================
  // 1. ESTILOS DE ENCABEZADOS (Títulos principales y de sección)
  // =========================================================================

  // Título de la Aplicación/Pantalla Principal
  static const TextStyle headline1 = TextStyle(
    fontSize: 32, // Muy grande para máxima visibilidad
    fontWeight: FontWeight.bold,
    color: AppColors.backgroundWhite, // Contraste blanco sobre azul primario
    height: 1.2, // Espaciado cómodo
  );

  // Títulos de Secciones o Nombres de Persona en la Tarjeta
  static const TextStyle headline2 = TextStyle(
    fontSize: 24, // Tamaño fácil de leer en cards
    fontWeight: FontWeight.w600, // Semi-negrita
    color: AppColors.primaryText,
  );

  // =========================================================================
  // 2. ESTILOS DE TEXTO EN EL CUERPO Y DESCRIPCIONES
  // =========================================================================

  // Texto Principal (e.g., Edad de la persona, Título del documento)
  static const TextStyle bodyTextPrimary = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w500,
    color: AppColors.primaryText,
  );

  // Texto Secundario (e.g., Descripciones, mensajes de ayuda)
  static const TextStyle bodyTextSecondary = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppColors.secondaryText,
  );

  // =========================================================================
  // 3. ESTILOS ESPECÍFICOS DE WIDGETS
  // =========================================================================

  // Estilo para el texto dentro de los Botones de Acción (COPIAR/DESCARGAR)
  static const TextStyle buttonLabel = TextStyle(
    fontSize: 20, // Botones grandes requieren texto grande
    fontWeight: FontWeight.bold,
    color: AppColors.backgroundWhite,
    letterSpacing: 1.0, // Espaciado para mejorar legibilidad
  );

  // Estilo para el valor del documento (el número de cédula, correo)
  static const TextStyle documentValue = TextStyle(
    fontSize: 22, // Debe ser el más prominente para copiar
    fontWeight: FontWeight.w800,
    color: AppColors.primaryBlue,
    fontFamily: 'RobotoMono', // Opcional: fuente monoespacio para claridad de números
  );

  // Estilo para mensajes de notificación/alerta
  static const TextStyle notificationText = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: AppColors.backgroundWhite,
  );
}