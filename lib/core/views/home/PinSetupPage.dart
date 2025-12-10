import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';

class PinSetupPage extends StatefulWidget {
  final bool isSetupMode; // true si es la primera vez, false si es para cambiarlo

  const PinSetupPage({super.key, this.isSetupMode = true});

  @override
  State<PinSetupPage> createState() => _PinSetupPageState();
}

class _PinSetupPageState extends State<PinSetupPage> {
  final TextEditingController _pinController = TextEditingController();
  final TextEditingController _confirmPinController = TextEditingController();
  String? _pinActual;
  String _message = '';
  String _setupStep = 'new'; // 'new', 'confirm'

  @override
  void initState() {
    super.initState();
    _loadPin();
  }

  Future<void> _loadPin() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _pinActual = prefs.getString('app_pin');
      // Si estamos en modo no-setup y ya hay un PIN, el primer paso es verificar el viejo PIN
      if (!widget.isSetupMode && _pinActual != null && _pinActual!.isNotEmpty) {
        _setupStep = 'verify_old';
      }
      _updateMessage();
    });
  }

  void _updateMessage() {
    if (_setupStep == 'verify_old') {
      _message = 'Introduce tu PIN actual para continuar:';
    } else if (_setupStep == 'new') {
      _message = 'Introduce tu nuevo PIN (4 dígitos):';
    } else if (_setupStep == 'confirm') {
      _message = 'Confirma tu nuevo PIN:';
    }
  }

  void _clearControllers() {
    _pinController.clear();
    _confirmPinController.clear();
  }

  void _onPinSubmitted(String pin) async {
    final prefs = await SharedPreferences.getInstance();

    if (_setupStep == 'verify_old') {
      // 1. Verificar PIN antiguo (solo si estamos en modo de cambio)
      if (pin == _pinActual) {
        setState(() {
          _setupStep = 'new';
          _clearControllers();
          _updateMessage();
        });
      } else {
        setState(() {
          _message = 'PIN incorrecto. Intenta de nuevo:';
          _clearControllers();
        });
      }
    } else if (_setupStep == 'new') {
      // 2. Ingresar nuevo PIN
      if (pin.length != 4) {
        setState(() {
          _message = 'El PIN debe ser de 4 dígitos:';
          _clearControllers();
        });
        return;
      }
      _confirmPinController.text = pin; // Almacenamos el nuevo PIN temporalmente
      setState(() {
        _setupStep = 'confirm';
        _clearControllers();
        _updateMessage();
      });
    } else if (_setupStep == 'confirm') {
      // 3. Confirmar nuevo PIN
      if (pin == _confirmPinController.text) {
        await prefs.setString('app_pin', pin);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('PIN configurado correctamente.'), backgroundColor: Colors.green),
        );
        Navigator.pop(context, true); // Cerramos la página y retornamos éxito
      } else {
        setState(() {
          _message = 'Los PINs no coinciden. Intenta de nuevo:';
          _setupStep = 'new'; // Volver al primer paso de ingreso de PIN
          _clearControllers();
        });
      }
    }
  }

  Future<void> _removePin() async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Eliminar PIN'),
          content: const Text('¿Estás seguro de que quieres eliminar el bloqueo por PIN? La aplicación quedará sin protección.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Eliminar', style: TextStyle(color: Colors.white)),
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.remove('app_pin');
                if (mounted) {
                  Navigator.of(context).pop(); // Cerrar el diálogo
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('PIN de bloqueo eliminado.'), backgroundColor: Colors.orange),
                  );
                  Navigator.pop(context, true); // Cerrar la página de configuración
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isSetupMode ? 'Establecer PIN' : 'Cambiar PIN'),
        backgroundColor: Colors.blue.shade700,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Icon(Icons.lock_outline, size: 80, color: Colors.blue.shade600),
              const SizedBox(height: 30),
              Text(
                _message,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, color: Colors.grey.shade700),
              ),
              const SizedBox(height: 30),
              // Campo para ingresar el PIN (siempre oculto)
              TextField(
                controller: _pinController,
                obscureText: true,
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                maxLength: 4,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  counterText: '',
                  hintText: '----',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(color: Colors.blue.shade200, width: 1.5),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(color: Colors.blue.shade700, width: 2.0),
                  ),
                ),
                onSubmitted: _onPinSubmitted,
              ),
              const SizedBox(height: 30),

              // Botón para confirmar
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade600,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 5,
                  ),
                  onPressed: () {
                    // Usamos el texto actual del controlador
                    if (_pinController.text.isNotEmpty) {
                      _onPinSubmitted(_pinController.text);
                    }
                  },
                  child: Text(
                    _setupStep == 'confirm' ? 'CONFIRMAR PIN' : 'CONTINUAR',
                    style: const TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ),

              if (_pinActual != null && _pinActual!.isNotEmpty && !widget.isSetupMode) ...[
                const SizedBox(height: 20),
                TextButton(
                  onPressed: _removePin,
                  child: const Text(
                    'Eliminar bloqueo por PIN',
                    style: TextStyle(color: Colors.red, fontSize: 16),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}