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
  // Definimos las categorías posibles actualizadas según tu solicitud
  final List<String> _categorias = ['Todos', 'Identificación', 'Factura', 'Receta', 'Contrato', 'Otro'];

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
    // Buscamos el índice real en la lista completa, no en la filtrada
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
        // Opcional: Cambiar el filtro a 'Todos' o a la categoría del nuevo doc para verlo
        _filtroSeleccionado = 'Todos';
      });
      await _guardarDocumentos();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Guardado correctamente", style: TextStyle(fontSize: 16))),
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

  Future<void> _compartirArchivo(String path) async {
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

  // --- Lógica de Filtrado ---
  List<Map<String, dynamic>> get _documentosFiltrados {
    if (_filtroSeleccionado == 'Todos') {
      return _documentos;
    }
    // Filtramos comparando con el campo 'tipo' que guardas en el documento
    return _documentos.where((doc) => doc['tipo'] == _filtroSeleccionado).toList();
  }

  @override
  Widget build(BuildContext context) {
    // Obtenemos la lista filtrada para usarla en el build
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
          : Column( // Cambiamos SingleChildScrollView por Column para fijar cabecera y filtros
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // --- CABECERA DE PERFIL ---
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

          // --- LISTA DE DOCUMENTOS (SCROLLABLE) ---
          Expanded(
            child: listaVisible.isEmpty
                ? _buildEmptyState()
                : ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
              itemCount: listaVisible.length,
              separatorBuilder: (ctx, i) => const SizedBox(height: 15),
              itemBuilder: (context, index) {
                // Pasamos el objeto real para poder borrarlo correctamente
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
    bool imageExists = File(doc['path']).existsSync();
    String contenido = doc['contenido'] ?? '';

    return Dismissible(
      // Usamos el path como llave única
      key: Key(doc['path']),
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
            // Lógica de iconos simple basada en el tipo de documento
            child: Icon(
              doc['tipo'] == 'Identificación' ? Icons.badge
                  : doc['tipo'] == 'Factura' ? Icons.receipt
                  : doc['tipo'] == 'Receta' ? Icons.medical_services
                  : doc['tipo'] == 'Contrato' ? Icons.article
                  : Icons.description,
              color: kPrimaryColor,
              size: 30,
            ),
          ),
          title: Text(
            doc['titulo'] ?? "Sin título",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Colors.black87,
            ),
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
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    height: 200,
                    color: Colors.grey.shade100,
                    child: imageExists
                        ? Image.file(File(doc['path']), fit: BoxFit.cover)
                        : const Icon(Icons.broken_image, size: 50, color: Colors.grey),
                  ),
                ),
                const SizedBox(height: 20),
                if (contenido.isNotEmpty) ...[
                  const Text(
                    "Contenido:",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black54),
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
                      style: const TextStyle(fontSize: 16, color: Colors.black87, height: 1.5),
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
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          side: BorderSide(color: kPrimaryColor),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: () => _compartirArchivo(doc['path']),
                        icon: Icon(Icons.share, size: 20, color: kPrimaryColor),
                        label: Text("ENVIAR", style: TextStyle(color: kPrimaryColor)),
                      ),
                    ),
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
                : "No hay documentos de $_filtroSeleccionado",
            style: TextStyle(fontSize: 18, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }
}