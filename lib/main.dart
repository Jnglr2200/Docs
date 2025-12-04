import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/views/home/home_page.dart'; // <--- RUTA CORREGIDA

import 'core/constants/app_colors.dart';

void main() {
  // Aseguramos que los widgets de Flutter estén inicializados
  WidgetsFlutterBinding.ensureInitialized();

  // Opcional: Bloquear la orientación a solo Vertical (ideal para apps de documentos)
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Se ha cambiado a MyApp para coincidir con el nombre esperado en los tests
  runApp(const MyApp());
}

// Clase renombrada de Docs2App a MyApp para resolver el error del test.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Docs2 - Gestor Familiar',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // Tema principal para toda la aplicación
        primaryColor: AppColors.primaryBlue,
        scaffoldBackgroundColor: AppColors.backgroundLight,
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.blue,
        ).copyWith(
          secondary: AppColors.actionOrange, // Color de acento
          primary: AppColors.primaryBlue,
        ),

        // Configuración de Tipografía general (se usó en AppStyles, pero es bueno tener un fallback aquí)
        fontFamily: 'Roboto', // Usar la fuente por defecto de Flutter, clara y legible.

        // Estilo de botones elevado por defecto (para accesibilidad)
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(vertical: 14),
            textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),

        // Tema de AppBar
        appBarTheme: const AppBarTheme(
          elevation: 4,
          iconTheme: IconThemeData(color: Colors.white),
        ),
      ),

      // La pantalla inicial de la aplicación es HomePage
      home: const HomePage(),
    );
  }
}