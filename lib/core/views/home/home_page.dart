import 'dart:io';

import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_styles.dart';
import '../.././controllers/home_controller.dart';
import '../../../models/persona_model.dart';
import '../detail/detail_page.dart'; // Para navegar a la pantalla de detalle

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Inicializamos el controlador de la Home
  late HomeController _controller;

  @override
  void initState() {
    super.initState();
    _controller = HomeController();
    // No necesitamos llamar a cargarPersonas() aquí porque ya se hace en el constructor del controller
  }

  @override
  void dispose() {
    _controller.dispose(); // Liberar recursos del ChangeNotifier
    super.dispose();
  }

  // Función para manejar la navegación a la vista de detalle
  void _navigateToDetail(PersonaModel persona) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailPage(persona: persona),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Usamos ListenableBuilder para escuchar el estado del HomeController
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, child) {
        return Scaffold(
          backgroundColor: AppColors.backgroundLight,
          appBar: AppBar(
            backgroundColor: AppColors.primaryBlue,
            toolbarHeight: 100, // Alto grande para visibilidad
            title: Text(
              'Mis Papeles',
              style: AppStyles.headline1,
            ),
            elevation: 0,
            centerTitle: false,
          ),

          body: _buildBodyContent(),

          // Botón flotante grande y visible para agregar nuevas personas
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () {
              // TODO: Abrir formulario para agregar nueva persona
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Próximamente: Formulario de Nueva Persona")),
              );
            },
            icon: const Icon(Icons.person_add_alt_1, size: 30),
            label: Text('AGREGAR PERSONA', style: AppStyles.buttonLabel.copyWith(fontSize: 18)),
            backgroundColor: AppColors.successGreen,
            foregroundColor: AppColors.backgroundWhite,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            extendedPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          ),
        );
      },
    );
  }

  // Lógica de visualización de contenido (Loading, Empty o Data)
  Widget _buildBodyContent() {
    if (_controller.isLoading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primaryBlue));
    }

    if (_controller.personas.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _controller.personas.length,
      itemBuilder: (context, index) {
        final persona = _controller.personas[index];
        return _buildProfileCard(persona);
      },
    );
  }

  // Widget para la tarjeta de cada persona
  Widget _buildProfileCard(PersonaModel persona) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: InkWell(
          onTap: () => _navigateToDetail(persona),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                // Icono/Foto de la persona
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.lightBlue,
                    border: Border.all(color: AppColors.primaryBlue, width: 2),
                    image: persona.fotoPath != null
                        ? DecorationImage(image: FileImage(File(persona.fotoPath!)), fit: BoxFit.cover)
                        : null,
                  ),
                  child: persona.fotoPath == null
                      ? const Icon(Icons.person, size: 40, color: AppColors.primaryBlue)
                      : null,
                ),

                const SizedBox(width: 20),

                // Nombre y edad
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        persona.nombre,
                        style: AppStyles.headline2.copyWith(fontSize: 22),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        persona.edad,
                        style: AppStyles.bodyTextSecondary.copyWith(fontSize: 18),
                      ),
                      const SizedBox(height: 8),
                      // Indicador de documentos
                      Row(
                        children: [
                          Icon(Icons.description, size: 18, color: AppColors.secondaryText),
                          const SizedBox(width: 5),
                          Text(
                            '${persona.documentos.length} Documentos',
                            style: AppStyles.bodyTextSecondary.copyWith(fontSize: 16),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Icono de navegación
                const Icon(Icons.arrow_forward_ios, color: AppColors.primaryBlue, size: 28),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Mensaje para cuando la lista de personas está vacía
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.family_restroom, size: 100, color: Colors.grey.shade300),
            const SizedBox(height: 20),
            Text(
              "¡Bienvenido a Mis Papeles!",
              style: AppStyles.headline2.copyWith(color: AppColors.secondaryText),
            ),
            const SizedBox(height: 10),
            Text(
              "Añade tu primer familiar o ser querido para comenzar a organizar sus documentos.",
              textAlign: TextAlign.center,
              style: AppStyles.bodyTextSecondary.copyWith(fontSize: 18),
            ),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }
}