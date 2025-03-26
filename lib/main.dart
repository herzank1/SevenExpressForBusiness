import 'dart:js_interop_unsafe';

import 'package:flutter/material.dart';
import 'package:seven_express_api/dto/ApiResponse.dart';
import 'package:seven_express_api/methods/Businesess.dart';
import 'package:seven_express_api/utils/Config.dart';
import 'screens/HomePage.dart'; // Página principal
import 'screens/LoginPage.dart'; // Página de inicio de sesión
import 'dart:js_interop';

@JS()
external bool get flutterEnvironment; // Esta es la variable de JavaScript.

void main() {
  // Recupera el valor del entorno desde JavaScript
  bool isProduction = flutterEnvironment ?? false;
    // Llamamos a la función de Config para cambiar el entorno
  Config.setEnvironment(isProduction);
  // Ejecutamos la app
  runApp(MaterialApp(debugShowCheckedModeBanner: false, home: SplashScreen()));
}


class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    // Usamos Future.delayed para ejecutar el código asincrónico de manera secuencial
    Future.delayed(Duration.zero, () async {
      bool? logWithToken = await _logWithToken();
      if (logWithToken == true) {
        _goToHome();
      } else {
        _goToLogin();
      }
    });
  }

  Future<bool?> _logWithToken() async {
    ApiResponse<bool>? apiResponse = await Businesess.validateToken();
    return apiResponse?.data;
  }

  void _goToHome() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => HomePage()),
    );
  }

  void _goToLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue, // Color de fondo
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.delivery_dining, size: 80, color: Colors.white),
            // Ícono del Splash
            SizedBox(height: 20),
            CircularProgressIndicator(color: Colors.white),
            // Indicador de carga
          ],
        ),
      ),
    );
  }
}
