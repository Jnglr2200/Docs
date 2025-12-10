import 'dart:io';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_styles.dart';
import '../../controllers/home_controller.dart';
import '../../../models/persona_model.dart';
import '../detail/detail_page.dart';
import '../widgets/profile_card.dart'; // Importante: Usa el nuevo diseño de tarjeta

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Instanciamos el controlador
  final HomeController _controller = HomeController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Usamos ListenableBuilder para escuchar cambios en los datos
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, child) {
        return Scaffold(
          backgroundColor: AppColors.backgroundLight, // Fondo gris muy suave

          // AppBar azul sólido
          appBar: AppBar(
            backgroundColor: AppColors.primaryBlue,
            toolbarHeight: 70, // Un poco más alto para elegancia
            title: const Text(
              "Mis Papeles",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontFamily: 'Roboto', // Asegura fuente limpia
              ),
            ),
            elevation: 0,
            centerTitle: false, // Alineado a la izquierda según tu imagen
          ),

          body: _controller.isLoading
              ? const Center(child: CircularProgressIndicator(color: AppColors.primaryBlue))
              : _buildBody(),

          // Botón flotante blanco con icono azul (estilo minimalista)
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Próximamente: Crear nuevo familiar")),
              );
            },
            backgroundColor: Colors.white,
            foregroundColor: Colors.grey.shade600, // Icono gris oscuro
            elevation: 4,
            shape: const CircleBorder(),
            child: const Icon(Icons.add, size: 36),
          ),
        );
      },
    );
  }

  Widget _buildBody() {
    return Column(
      children: [
        // 1. Banner de Información Superior
        Container(
          width: double.infinity,
          margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          decoration: BoxDecoration(
            color: const Color(0xFFEFF6FF), // Azul muy pálido (bg-blue-50 de Tailwind)
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFFBFDBFE), // Borde azul suave
              width: 1,
            ),
          ),
          child: const Text(
            "Toque una tarjeta para ver los documentos.",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF1E40AF), // Azul oscuro (text-blue-800)
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),

        // 2. Lista de Tarjetas Verticales
        Expanded(
          child: _controller.personas.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 80), // Padding extra abajo para el botón flotante
            itemCount: _controller.personas.length,
            itemBuilder: (context, index) {
              final persona = _controller.personas[index];
              // Renderiza la tarjeta vertical importada
              return ProfileCard(persona: persona);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person_off, size: 80, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              "No hay familiares guardados.\nPulse '+' para comenzar.",
              style: AppStyles.bodyTextSecondary.copyWith(fontSize: 18),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}