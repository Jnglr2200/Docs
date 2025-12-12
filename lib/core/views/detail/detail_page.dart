import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:share_plus/share_plus.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../models/persona_model.dart';
import '../AddDocumentPage.dart';

class DetailPage extends StatefulWidget {
  final PersonaModel persona;

  const DetailPage({super.key, required this.persona});

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  final List<Map<String, dynamic>> _documentos = [];
  bool _isLoading = true;

  // --- Estado para el filtro ---
  String _filtroSeleccionado = 'Todos';
  final List<String> _categorias = ['Todos', 'Identificación', 'Factura', 'Cuenta Bancaria', 'Receta', 'Contrato', 'Otro'];

  // --- CONFIGURACIÓN DE ESTILO ---
  final Color kPrimaryColor = const Color(0xFF2196F3);
  final Color kBackgroundColor = const Color(0xFFF5F5F5);
  final double kTitleSize = 26.0;
  final double kSubtitleSize = 18.0;

  @override
  void initState() {
    super.initState();
    _cargarDocumentos();
  }

  String get _storageKey => 'docs_${widget.persona.nombre.replaceAll(" ", "")}';

  Future<void> _cargarDocumentos() async {
    final prefs = await SharedPreferences.getInstance();
    final String? docsJson = prefs.getString(_storageKey);

    if (docsJson != null) {
      try {
        final List<dynamic> decoded = jsonDecode(docsJson);
        setState(() {
          _documentos.addAll(decoded.cast<Map<String, dynamic>>());
        });
      } catch (e) {
        debugPrint("Error al cargar documentos: $e");
      }
    }
    setState(() => _isLoading = false);
  }

  Future<void> _guardarDocumentos() async {
    final prefs = await SharedPreferences.getInstance();
    final String docsJson = jsonEncode(_documentos);
    await prefs.setString(_storageKey, docsJson);
  }

  Future<void> _eliminarDocumento(Map<String, dynamic> docToDelete) async {
    final index = _documentos.indexOf(docToDelete);
    if (index != -1) {
      setState(() {
        _documentos.removeAt(index);
      });
      await _guardarDocumentos();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Documento eliminado", style: TextStyle(fontSize: 16))),
        );
      }
    }
  }

  Future<void> _navegarAgregarDocumento() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddDocumentPage(imageFile: null),
      ),
    );

    if (result != null && result is Map<String, dynamic>) {
      setState(() {
        _documentos.add(result);
        _filtroSeleccionado = 'Todos';
      });
      await _guardarDocumentos();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Guardado correctamente"), backgroundColor: Colors.green),
        );
      }
    }
  }

  void _copiarTexto(String? texto) {
    if (texto != null && texto.isNotEmpty) {
      Clipboard.setData(ClipboardData(text: texto));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Copiado al portapapeles"),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _compartirArchivo(String? path) async {
    if (path == null || path.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Este documento no tiene archivo para compartir")),
      );
      return;
    }
    try {
      final file = File(path);
      if (await file.exists()) {
        await Share.shareXFiles([XFile(path)], text: 'Compartiendo documento...');
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("El archivo no existe")),
          );
        }
      }
    } catch (e) {
      debugPrint("Error al compartir: $e");
    }
  }

  List<Map<String, dynamic>> get _documentosFiltrados {
    if (_filtroSeleccionado == 'Todos') {
      return _documentos;
    }
    return _documentos.where((doc) => doc['tipo'] == _filtroSeleccionado).toList();
  }

  @override
  Widget build(BuildContext context) {
    final listaVisible = _documentosFiltrados;

    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        toolbarHeight: 70,
        title: const Text("Documentos", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        backgroundColor: kPrimaryColor,
        elevation: 2,
        centerTitle: true,
      ),
      floatingActionButton: SizedBox(
        height: 70,
        width: 70,
        child: FloatingActionButton(
          onPressed: _navegarAgregarDocumento,
          backgroundColor: kPrimaryColor,
          child: const Icon(Icons.add, size: 35),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeader(),
          const Divider(height: 1, thickness: 1),
          // --- BARRA DE FILTROS ---
          Container(
            color: kBackgroundColor,
            padding: const EdgeInsets.symmetric(vertical: 15),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: _categorias.map((categoria) {
                  final isSelected = _filtroSeleccionado == categoria;
                  return Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: FilterChip(
                      label: Text(
                        categoria,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.black87,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      selected: isSelected,
                      onSelected: (bool selected) {
                        setState(() {
                          _filtroSeleccionado = categoria;
                        });
                      },
                      backgroundColor: Colors.white,
                      selectedColor: kPrimaryColor,
                      checkmarkColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(
                          color: isSelected ? kPrimaryColor : Colors.grey.shade300,
                        ),
                      ),
                      elevation: isSelected ? 2 : 0,
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          // --- LISTA DE DOCUMENTOS ---
          Expanded(
            child: listaVisible.isEmpty
                ? _buildEmptyState()
                : ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
              itemCount: listaVisible.length,
              separatorBuilder: (ctx, i) => const SizedBox(height: 15),
              itemBuilder: (context, index) {
                return _buildBigCard(listaVisible[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
      child: Row(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: kPrimaryColor.withOpacity(0.1),
              image: widget.persona.fotoPath != null
                  ? DecorationImage(
                image: FileImage(File(widget.persona.fotoPath!)),
                fit: BoxFit.cover,
              )
                  : null,
            ),
            child: widget.persona.fotoPath == null
                ? Icon(Icons.person, size: 40, color: kPrimaryColor)
                : null,
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.persona.nombre,
                  style: TextStyle(
                    fontSize: kTitleSize,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  "${widget.persona.edad} años",
                  style: TextStyle(
                    fontSize: kSubtitleSize,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBigCard(Map<String, dynamic> doc) {
    String path = doc['path'] ?? "";
    bool hasImage = path.isNotEmpty && File(path).existsSync();
    String contenido = doc['contenido'] ?? '';
    String? banco = doc['banco'];

    IconData icon;
    switch (doc['tipo']) {
      case 'Cuenta Bancaria': icon = Icons.account_balance; break;
      case 'Identificación': icon = Icons.badge; break;
      case 'Factura': icon = Icons.receipt_long; break;
      case 'Receta': icon = Icons.medical_services; break;
      case 'Contrato': icon = Icons.article; break;
      default: icon = Icons.description;
    }

    return Dismissible(
      key: Key(path + DateTime.now().toString()),
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
      onDismissed: (_) => _eliminarDocumento(doc),
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        color: Colors.white,
        child: ExpansionTile(
          tilePadding: const EdgeInsets.all(16),
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: kPrimaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: kPrimaryColor, size: 30),
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (banco != null)
                Text(
                    banco,
                    style: TextStyle(fontSize: 14, color: kPrimaryColor, fontWeight: FontWeight.bold)
                ),
              Text(
                doc['titulo'] ?? "Sin título",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          subtitle: Text(
            doc['tipo'] ?? "Documento",
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
          ),
          childrenPadding: const EdgeInsets.all(20),
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (hasImage) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      height: 200,
                      width: double.infinity,
                      color: Colors.white, // Fondo blanco para que los logos se vean bien
                      child: Image.file(File(path), fit: BoxFit.contain), // CAMBIO: contain para ver todo el logo
                    ),
                  ),
                  const SizedBox(height: 20),
                ] else ...[
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.grey.shade200)
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.hide_image_outlined, color: Colors.grey.shade400),
                        const SizedBox(width: 10),
                        Text("Sin imagen adjunta", style: TextStyle(color: Colors.grey.shade500)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],

                if (contenido.isNotEmpty) ...[
                  Text(
                    doc['tipo'] == 'Cuenta Bancaria' ? "Número de Cuenta:" : "Detalles:",
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black54),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE3F2FD),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.blue.shade100),
                    ),
                    child: SelectableText(
                      contenido,
                      style: const TextStyle(fontSize: 18, color: Colors.black87, height: 1.5, fontFamily: 'Monospace'),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],

                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kPrimaryColor,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: () => _copiarTexto(contenido),
                        icon: const Icon(Icons.copy, size: 20, color: Colors.white),
                        label: const Text("COPIAR", style: TextStyle(color: Colors.white)),
                      ),
                    ),
                    if (hasImage) ...[
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            side: BorderSide(color: kPrimaryColor),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          onPressed: () => _compartirArchivo(path),
                          icon: Icon(Icons.share, size: 20, color: kPrimaryColor),
                          label: Text("ENVIAR", style: TextStyle(color: kPrimaryColor)),
                        ),
                      ),
                    ]
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.only(top: 50),
      alignment: Alignment.center,
      child: Column(
        children: [
          Icon(Icons.filter_list_off, size: 70, color: Colors.grey.shade300),
          const SizedBox(height: 15),
          Text(
            _filtroSeleccionado == 'Todos'
                ? "No hay documentos"
                : "No hay de $_filtroSeleccionado",
            style: TextStyle(fontSize: 18, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }
}