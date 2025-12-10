import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_page.dart';

class PinLockPage extends StatefulWidget {
  const PinLockPage({super.key});

  @override
  State<PinLockPage> createState() => _PinLockPageState();
}

class _PinLockPageState extends State<PinLockPage> {
  final TextEditingController _pinController = TextEditingController();
  String _message = 'Introduce tu PIN para acceder:';
  String? _storedPin;
  bool _isPinIncorrect = false;

  @override
  void initState() {
    super.initState();
    _loadStoredPin();
  }

  Future<void> _loadStoredPin() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _storedPin = prefs.getString('app_pin');
      // Si por alguna razón el PIN es null aquí, navegamos al home (no debería pasar)
      if (_storedPin == null || _storedPin!.isEmpty) {
        _navigateToHome();
      }
    });
  }

  void _navigateToHome() {
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    }
  }

  void _verifyPin(String enteredPin) {
    setState(() {
      _isPinIncorrect = false;
    });

    if (enteredPin == _storedPin) {
      _navigateToHome();
    } else {
      setState(() {
        _isPinIncorrect = true;
        _pinController.clear();
        _message = 'PIN incorrecto. Intenta de nuevo:';
      });
      // Vibración de error (simulada o real si se usa un paquete)
      HapticFeedback.lightImpact();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade700,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Icon(Icons.security, size: 90, color: Colors.white),
              const SizedBox(height: 20),
              const Text(
                'Acceso Restringido',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 40),
              Text(
                _message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  color: _isPinIncorrect ? Colors.yellow.shade200 : Colors.white70,
                ),
              ),
              const SizedBox(height: 30),

              // Campo para ingresar el PIN
              TextField(
                controller: _pinController,
                obscureText: true,
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                maxLength: 4,
                autofocus: true,
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  counterText: '',
                  hintText: '----',
                  hintStyle: TextStyle(color: Colors.white38),
                  filled: true,
                  fillColor: Colors.blue.shade600,
                  errorText: _isPinIncorrect ? 'PIN inválido' : null,
                  errorStyle: TextStyle(fontSize: 14, color: Colors.yellow.shade200),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                ),
                onSubmitted: _verifyPin,
              ),
              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 5,
                  ),
                  onPressed: () {
                    if (_pinController.text.isNotEmpty) {
                      _verifyPin(_pinController.text);
                    }
                  },
                  child: Text(
                    'DESBLOQUEAR',
                    style: TextStyle(
                        fontSize: 18,
                        color: Colors.blue.shade700,
                        fontWeight: FontWeight.bold
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}