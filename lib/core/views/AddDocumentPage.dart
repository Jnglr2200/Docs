import 'dart:io';
import 'dart:typed_data'; // Necesario para manejar los bytes de la imagen del asset
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle; // Para leer los assets
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class AddDocumentPage extends StatefulWidget {
  final File? imageFile; // Opcional, por si viene de un atajo rápido

  const AddDocumentPage({super.key, this.imageFile});

  @override
  State<AddDocumentPage> createState() => _AddDocumentPageState();
}

class _AddDocumentPageState extends State<AddDocumentPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _tituloController = TextEditingController();
  final TextEditingController _contenidoController = TextEditingController();

  // Listas de opciones
  final List<String> _tiposDocumento = [
    'Identificación',
    'Factura',
    'Receta',
    'Contrato',
    'Cuenta Bancaria',
    'Otro'
  ];

  final List<String> _listaBancos = [
    'Banco Pichincha',
    'Banco Guayaquil',
    'Produbanco',
    'Banco del Pacífico',
    'Banco Internacional',
    'Banco Bolivariano',
    'Cooperativa JEP',
    'Otro'
  ];

  String? _tipoSeleccionado;
  String? _bancoSeleccionado; // Solo para cuentas bancarias
  File? _imagenSeleccionada;
  final ImagePicker _picker = ImagePicker();
  bool _isSaving = false;

  // Estilos
  final Color kPrimaryColor = const Color(0xFF2196F3);

  @override
  void initState() {
    super.initState();
    if (widget.imageFile != null) {
      _imagenSeleccionada = widget.imageFile;
    }
  }

  Future<void> _tomarFoto(ImageSource source) async {
    try {
      final XFile? photo = await _picker.pickImage(source: source, imageQuality: 85);
      if (photo != null) {
        setState(() {
          _imagenSeleccionada = File(photo.path);
        });
      }
    } catch (e) {
      debugPrint("Error al tomar foto: $e");
    }
  }

  // --- LÓGICA: Cargar imagen desde Assets dinámicamente ---
  Future<void> _cargarImagenBanco(String? banco) async {
    if (banco == null || banco == 'Otro') return;

    try {
      // Mapa para asociar el nombre del banco con su imagen en assets.
      final Map<String, String> bancoAssets = {
        'Banco Pichincha': 'BancoPichincha.png',
        'Banco Guayaquil': 'BancoGuayaquil.png',
        'Produbanco': 'Produbanco.png',
        'Banco del Pacífico': 'BancoPacifico.png',
        'Banco Internacional': 'BancoInternacional.png',
        'Banco Bolivariano': 'BancoBolivariano.png',
        'Cooperativa JEP': 'CooperativaJEP.png',
      };

      if (!bancoAssets.containsKey(banco)) return;

      final String assetName = bancoAssets[banco]!;
      final String assetPath = 'assets/banco/$assetName';

      // 1. Leemos los bytes del asset
      final ByteData data = await rootBundle.load(assetPath);

      // 2. Creamos un archivo temporal
      final Directory tempDir = await getTemporaryDirectory();
      final File tempFile = File('${tempDir.path}/temp_${DateTime.now().millisecondsSinceEpoch}_$assetName');

      // 3. Escribimos los bytes en el archivo
      await tempFile.writeAsBytes(data.buffer.asUint8List(), flush: true);

      // 4. Actualizamos la imagen seleccionada
      setState(() {
        _imagenSeleccionada = tempFile;
      });

    } catch (e) {
      debugPrint("Error cargando asset del banco ($banco): $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("No se encontró el logo para $banco en assets"))
        );
      }
    }
  }

  void _mostrarOpcionesFoto() {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: const Text('Cámara'),
              onTap: () { Navigator.pop(ctx); _tomarFoto(ImageSource.camera); },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Galería'),
              onTap: () { Navigator.pop(ctx); _tomarFoto(ImageSource.gallery); },
            ),
            if (_imagenSeleccionada != null)
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Eliminar foto', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(ctx);
                  setState(() => _imagenSeleccionada = null);
                },
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _procesarGuardado() async {
    if (!_formKey.currentState!.validate()) return;
    if (_tipoSeleccionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Selecciona un tipo de documento"))
      );
      return;
    }

    // LÓGICA DE AVISO SIN FOTO
    if (_imagenSeleccionada == null) {
      bool? confirmar = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text("¿Guardar sin foto?"),
          content: const Text("No has adjuntado una imagen. ¿Deseas guardar solo la información de texto?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text("Cancelar"),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text("Sí, guardar"),
            ),
          ],
        ),
      );

      if (confirmar != true) return;
    }

    setState(() => _isSaving = true);

    try {
      String pathImagenGuardada = "";

      if (_imagenSeleccionada != null) {
        final directory = await getApplicationDocumentsDirectory();
        final String fileName = 'doc_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final String localPath = path.join(directory.path, fileName);
        await _imagenSeleccionada!.copy(localPath);
        pathImagenGuardada = localPath;
      }

      final Map<String, dynamic> nuevoDoc = {
        'titulo': _tituloController.text,
        'tipo': _tipoSeleccionado,
        'contenido': _contenidoController.text,
        'path': pathImagenGuardada,
        'fecha': DateTime.now().toIso8601String(),
        if (_tipoSeleccionado == 'Cuenta Bancaria') 'banco': _bancoSeleccionado,
      };

      if (mounted) {
        Navigator.pop(context, nuevoDoc);
      }
    } catch (e) {
      debugPrint("Error guardando: $e");
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Nuevo Documento"),
        backgroundColor: kPrimaryColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // --- 1. SELECCIÓN DE IMAGEN (AJUSTADA) ---
              GestureDetector(
                onTap: _mostrarOpcionesFoto,
                child: Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.grey.shade300),
                    image: _imagenSeleccionada != null
                        ? DecorationImage(
                      image: FileImage(_imagenSeleccionada!),
                      // contain para que se vea toda la imagen sin recortes
                      fit: BoxFit.contain,
                    )
                        : null,
                  ),
                  child: _imagenSeleccionada == null
                      ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.camera_alt, size: 50, color: Colors.grey[400]),
                      const SizedBox(height: 10),
                      Text(
                        "Toca para agregar foto",
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  )
                      : null,
                ),
              ),

              const SizedBox(height: 25),

              // --- 2. TIPO DE DOCUMENTO ---
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: "Tipo de Documento",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  prefixIcon: const Icon(Icons.category),
                ),
                value: _tipoSeleccionado,
                items: _tiposDocumento.map((tipo) {
                  IconData icon;
                  switch (tipo) {
                    case 'Cuenta Bancaria': icon = Icons.account_balance; break;
                    case 'Factura': icon = Icons.receipt; break;
                    case 'Identificación': icon = Icons.badge; break;
                    default: icon = Icons.description;
                  }
                  return DropdownMenuItem(
                    value: tipo,
                    child: Row(children: [Icon(icon, size: 18, color: Colors.grey), const SizedBox(width: 10), Text(tipo)]),
                  );
                }).toList(),
                onChanged: (val) {
                  setState(() {
                    // LOGICA NUEVA: Si venimos de 'Cuenta Bancaria' y cambiamos a otro, borramos la imagen
                    if (_tipoSeleccionado == 'Cuenta Bancaria' && val != 'Cuenta Bancaria') {
                      _imagenSeleccionada = null;
                    }

                    _tipoSeleccionado = val;
                    if (val != 'Cuenta Bancaria') _bancoSeleccionado = null;
                  });
                },
              ),

              const SizedBox(height: 20),

              // --- 3. BANCOS ---
              if (_tipoSeleccionado == 'Cuenta Bancaria') ...[
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: "Banco",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    prefixIcon: const Icon(Icons.account_balance_wallet),
                    filled: true,
                    fillColor: Colors.blue.withOpacity(0.05),
                  ),
                  value: _bancoSeleccionado,
                  items: _listaBancos.map((banco) => DropdownMenuItem(value: banco, child: Text(banco))).toList(),
                  onChanged: (val) {
                    setState(() => _bancoSeleccionado = val);
                    _cargarImagenBanco(val);
                  },
                  validator: (val) => val == null ? "Selecciona un banco" : null,
                ),
                const SizedBox(height: 20),
              ],

              // --- 4. CAMPOS DE TEXTO ---
              TextFormField(
                controller: _tituloController,
                decoration: InputDecoration(
                  labelText: "Título / Nombre",
                  hintText: _tipoSeleccionado == 'Cuenta Bancaria' ? "Ej. Cuenta Ahorros Principal" : "Ej. Cédula",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  prefixIcon: const Icon(Icons.title),
                ),
                validator: (val) => val!.isEmpty ? "Escribe un título" : null,
              ),

              const SizedBox(height: 20),

              TextFormField(
                controller: _contenidoController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: _tipoSeleccionado == 'Cuenta Bancaria' ? "Número de Cuenta" : "Descripción / Contenido",
                  hintText: _tipoSeleccionado == 'Cuenta Bancaria' ? "Ej. 2205..." : "Detalles extra...",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  prefixIcon: const Icon(Icons.notes),
                  alignLabelWithHint: true,
                ),
                keyboardType: _tipoSeleccionado == 'Cuenta Bancaria' ? TextInputType.number : TextInputType.multiline,
              ),

              const SizedBox(height: 40),

              // --- BOTÓN GUARDAR ---
              SizedBox(
                height: 55,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimaryColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: _isSaving ? null : _procesarGuardado,
                  icon: _isSaving
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Icon(Icons.save, color: Colors.white),
                  label: Text(_isSaving ? "GUARDANDO..." : "GUARDAR", style: const TextStyle(color: Colors.white, fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}