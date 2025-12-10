import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../models/persona_model.dart';
import 'AddPersonPage.dart';
import 'EditPersonPage.dart';
import '../detail/detail_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<PersonaModel> _personas = [];
  bool _isLoading = true;

  // --- CONFIGURACIÓN DE ESTILO ---
  final Color kPrimaryColor = const Color(0xFF2196F3);
  final Color kBackgroundColor = const Color(0xFFF5F5F5);

  @override
  void initState() {
    super.initState();
    _cargarPersonas();
  }

  Future<void> _cargarPersonas() async {
    final prefs = await SharedPreferences.getInstance();
    final String? personasJson = prefs.getString('personas');

    if (personasJson != null) {
      try {
        final List<dynamic> decoded = jsonDecode(personasJson);
        setState(() {
          // Usamos fromMap o fromJson según tu modelo
          _personas = decoded.map((e) => PersonaModel.fromMap(e as Map<String, dynamic>)).toList();
        });
      } catch (e) {
        debugPrint("Error al cargar personas: $e");
      }
    }
    setState(() => _isLoading = false);
  }

  Future<void> _guardarPersonas() async {
    final prefs = await SharedPreferences.getInstance();
    // Usamos toMap() o toJson() según tu modelo.
    final List<Map<String, dynamic>> personasMap = _personas.map((p) => p.toMap()).toList();
    final String personasJson = jsonEncode(personasMap);
    await prefs.setString('personas', personasJson);
  }

  Future<void> _eliminarPersona(PersonaModel persona) async {
    final prefs = await SharedPreferences.getInstance();
    final storageKey = 'docs_${persona.nombre.replaceAll(" ", "")}';
    await prefs.remove(storageKey);

    setState(() {
      _personas.removeWhere((p) => p.nombre == persona.nombre);
    });

    await _guardarPersonas();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("${persona.nombre} eliminado."), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _navegarAgregarPersona({PersonaModel? persona}) async {
    // Decidimos qué página abrir basándonos en si hay una persona o no
    Widget pageToOpen;
    if (persona != null) {
      pageToOpen = EditPersonPage(persona: persona); // Para editar
    } else {
      pageToOpen = const AddPersonPage(); // Para agregar (sin parámetros)
    }

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => pageToOpen,
      ),
    );

    if (result != null && result is PersonaModel) {
      if (persona == null) {
        // Modo Agregar
        setState(() {
          _personas.add(result);
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Agregado correctamente"), backgroundColor: Colors.green),
          );
        }
      } else {
        // Modo Editar
        final index = _personas.indexWhere((p) => p.nombre == persona.nombre);
        if (index != -1) {
          setState(() {
            _personas[index] = result;
          });
        }
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Actualizado correctamente"), backgroundColor: Colors.green),
          );
        }
      }
      await _guardarPersonas();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        toolbarHeight: 70,
        title: const Text("Gestor Familiar", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        backgroundColor: kPrimaryColor,
        elevation: 2,
        centerTitle: true,
        // Eliminamos las actions del AppBar porque ya no necesitamos el botón de seguridad
      ),
      floatingActionButton: SizedBox(
        height: 70,
        width: 70,
        child: FloatingActionButton(
          onPressed: () => _navegarAgregarPersona(),
          backgroundColor: kPrimaryColor,
          child: const Icon(Icons.person_add_alt_1, size: 35),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _personas.isEmpty
          ? _buildEmptyState()
          : ListView.separated(
        padding: const EdgeInsets.all(16.0),
        itemCount: _personas.length,
        separatorBuilder: (ctx, i) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final persona = _personas[index];
          return _buildFamilyCard(persona, index);
        },
      ),
    );
  }

  Widget _buildFamilyCard(PersonaModel persona, int index) {
    return Dismissible(
      key: Key(persona.nombre),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 30),
        decoration: BoxDecoration(
          color: Colors.redAccent,
          borderRadius: BorderRadius.circular(15),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white, size: 35),
      ),
      confirmDismiss: (direction) async {
        return await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("Confirmar Eliminación"),
              content: Text("¿Estás seguro de que quieres eliminar a ${persona.nombre}? Se perderán todos sus documentos."),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text("Cancelar", style: TextStyle(color: Colors.grey)),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: const Text("Eliminar", style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
      onDismissed: (_) => _eliminarPersona(persona),
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: ListTile(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DetailPage(persona: persona),
              ),
            );
          },
          leading: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: kPrimaryColor.withOpacity(0.1),
              image: persona.fotoPath != null
                  ? DecorationImage(
                image: FileImage(File(persona.fotoPath!)),
                fit: BoxFit.cover,
              )
                  : null,
            ),
            child: persona.fotoPath == null
                ? Icon(Icons.person, size: 30, color: kPrimaryColor)
                : null,
          ),
          title: Text(
            persona.nombre,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          subtitle: Text(
            // Asumiendo que tu modelo tiene estos getters o campos
            "${persona.edadDisplay} | ${persona.relacion}",
            style: TextStyle(color: Colors.grey.shade600),
          ),
          trailing: PopupMenuButton<String>(
            onSelected: (String result) {
              if (result == 'edit') {
                _navegarAgregarPersona(persona: persona);
              } else if (result == 'delete') {
                _eliminarPersona(persona);
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit, color: Colors.blue),
                    SizedBox(width: 8),
                    Text('Editar'),
                  ],
                ),
              ),
              const PopupMenuItem<String>(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Eliminar'),
                  ],
                ),
              ),
            ],
            icon: Icon(Icons.more_vert, color: Colors.grey.shade600),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.family_restroom, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 20),
          Text(
            "Aún no tienes familiares agregados.",
            style: TextStyle(fontSize: 18, color: Colors.grey.shade500),
          ),
          const SizedBox(height: 5),
          Text(
            "Toca '+' para empezar.",
            style: TextStyle(fontSize: 16, color: Colors.grey.shade400),
          ),
        ],
      ),
    );
  }
}