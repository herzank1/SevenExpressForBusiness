import 'package:flutter/material.dart';
import 'package:seven_express_api/dto/ApiResponse.dart';
import 'package:seven_express_api/dto/RequestBodies.dart';
import 'package:seven_express_api/methods/Businesess.dart';
import 'package:seven_express_api/utils/TokenManager.dart';
import 'package:seven_express_business/widgets/SnackbarHelper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:seven_express_api/methods/Deliveries.dart';
import '../widgets/DialogHelper.dart';
import 'HomePage.dart';
import 'RegisterPage.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Login Page',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    _loadUserData();
  }

  // Método para cargar los datos del usuario guardados
  void _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedUsername = prefs.getString('username');
    String? savedPassword = prefs.getString('password');

    if (savedUsername != null) {
      _usernameController.text = savedUsername;
    }
    if (savedPassword != null) {
      _passwordController.text = savedPassword;
    }
  }

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
    });

    var loginRequest = BodiesForBusiness.loginRequest(
      _usernameController.text,
      _passwordController.text,
    );
    ApiResponse<String>? response = await Businesess.login(loginRequest);
    String? token = response?.data;

    if (token != null&& response!.isSuccess()) {
      TokenManager.setAuthToken(token);
      // Guardar el token, username y password en SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', token);
      await prefs.setString('username', _usernameController.text);
      await prefs.setString('password', _passwordController.text);

      DialogHelper.showDialogMessage(context, 'Login', 'Iniciando sesión...');


      _goToHome();
    } else {
      DialogHelper.showDialogMessage(context,'Login', 'Credenciales inválidas!');
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(
                labelText: 'Usuario',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Contraseña',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(onPressed: _login, child: Text('Iniciar Sesión')),
            SizedBox(height: 10),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RegisterPage()),
                );
              },
              child: Text('Registrarte'),
            ),
          ],
        ),
      ),
    );
  }



  void _goToHome() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => HomePage()),
    );
  }
}
