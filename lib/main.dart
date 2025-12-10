import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/views/home/home_page.dart'; // <--- RUTA CORREGIDA
import 'core/views/home/PinLockPage.dart';
import 'core/views/home/PinSetupPage.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:local_auth/local_auth.dart';
import 'core/views/home/home_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Bloqueamos la orientación vertical
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) {
    runApp(const MyApp());
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gestor Familiar',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: false, // Mantenemos diseño clásico o true si prefieres M3
        fontFamily: 'Inter',
        appBarTheme: const AppBarTheme(
          elevation: 0,
          centerTitle: true,
        ),
      ),
      // En lugar de ir directo al Home, pasamos por el chequeo de seguridad
      home: const BiometricCheckPage(),
    );
  }
}

class BiometricCheckPage extends StatefulWidget {
  const BiometricCheckPage({super.key});

  @override
  State<BiometricCheckPage> createState() => _BiometricCheckPageState();
}

class _BiometricCheckPageState extends State<BiometricCheckPage> {
  final LocalAuthentication auth = LocalAuthentication();
  bool _isChecking = true;
  String _statusMessage = "Verificando seguridad...";

  @override
  void initState() {
    super.initState();
    _checkSecurity();
  }

  Future<void> _checkSecurity() async {
    final prefs = await SharedPreferences.getInstance();
    // 1. Verificamos si el usuario activó la seguridad en la app
    // final bool isSecurityEnabled = prefs.getBool('biometric_enabled') ?? false;
// if (!isSecurityEnabled) {
//   return;
// }

    // 2. Intentamos autenticar con el hardware del teléfono
    try {
      // Verificamos si el dispositivo puede chequear biometría
      final bool canAuthenticateWithBiometrics = await auth.canCheckBiometrics;
      final bool canAuthenticate = canAuthenticateWithBiometrics || await auth.isDeviceSupported();

      if (!canAuthenticate) {
        // Si el dispositivo no tiene seguridad, pasamos (o mostramos error)
        _navigateToHome();
        return;
      }

      final bool didAuthenticate = await auth.authenticate(
        localizedReason: 'Desbloquea para ver tus documentos',
        options: const AuthenticationOptions(
          biometricOnly: false, // false permite usar PIN/Patrón si falla la huella
          stickyAuth: true,
        ),
      );

      if (didAuthenticate) {
        _navigateToHome();
      } else {
        setState(() {
          _isChecking = false;
          _statusMessage = "Autenticación fallida. Toca para reintentar.";
        });
      }
    } catch (e) {
      debugPrint("Error de autenticación: $e");
      // En caso de error técnico, por seguridad solemos dejar pasar en dev,
      // pero en prod podrías bloquear. Aquí dejamos pasar para evitar bloqueos en emuladores.
      _navigateToHome();
    }
  }

  void _navigateToHome() {
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _isChecking
            ? const CircularProgressIndicator()
            : Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lock_outline, size: 60, color: Colors.red),
            const SizedBox(height: 20),
            Text(_statusMessage, textAlign: TextAlign.center),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _checkSecurity,
              child: const Text("Reintentar"),
            ),
          ],
        ),
      ),
    );
  }
}