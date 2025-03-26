import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:seven_express_api/dto/ApiResponse.dart';
import 'package:seven_express_api/dto/RequestBodies.dart';
import 'package:seven_express_api/entities/Business.dart';
import 'package:seven_express_api/entities/Transaction.dart';
import 'package:seven_express_api/methods/Businesess.dart';

class RegisterPage extends StatelessWidget {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =  TextEditingController();
  final TextEditingController _businessNameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();

  // Método para registrar
  Future<void> _register(BuildContext context) async {
    String userName = _usernameController.text;
    String password = _passwordController.text;
    String confirmPassword = _confirmPasswordController.text;
    String address = _addressController.text;
    String phoneNumber = _phoneNumberController.text;
    String businessName =_businessNameController.text;

    // Validar si las contraseñas coinciden
    if (password != confirmPassword) {
      _showErrorDialog(context, "Las contraseñas no coinciden");
      return;
    }

    // Crear el cuerpo de la solicitud para el registro
    Map<String, dynamic> registerData = BodiesForBusiness.registerRequest(
      userName,
      password,
      businessName,
      phoneNumber,
      address,
    );

     ApiResponse<Business>? response= await Businesess.register(registerData);
    // Aquí podrías hacer algo con el objeto 'business' si es necesario
    // Por ejemplo, redirigir a otra pantalla

    if (response?.data != null) {
      _showSuccessDialog(context);
    } else {
      _showErrorDialog(
        context,
        "Error al registrar el usuario. Intenta de nuevo.",
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Registro')),
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
            TextField(
              controller: _confirmPasswordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Confirmar Contraseña',
                border: OutlineInputBorder(),
              ),
            ),

            TextField(
              controller: _businessNameController,

              decoration: InputDecoration(
                labelText: 'Nombre del Negocio',
                border: OutlineInputBorder(),
              ),
            ),
            // Barra de búsqueda con autocompletado
            TypeAheadField<String>(
              textFieldConfiguration: TextFieldConfiguration(
                controller: _addressController,
                decoration: InputDecoration(
                  labelText: 'Buscar dirección',
                  suffixIcon: Icon(Icons.search),
                ),
              ),
              suggestionsCallback: _getSuggestions,
              itemBuilder: (context, suggestion) {
                return ListTile(
                  title: Text(suggestion),
                );
              },
              onSuggestionSelected: _onSuggestionSelected,
            ),
            SizedBox(height: 20),
            TextField(
              controller: _phoneNumberController,
              decoration: InputDecoration(
                labelText: 'Telefono',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await _register(context); // Espera la ejecución del registro
              },
              child: Text('Registrarse'),
            ),
          ],
        ),
      ),
    );
  }

  // Mostrar un diálogo de error
  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Error"),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // Mostrar un diálogo de éxito
  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Registro Exitoso"),
          content: Text("Tu cuenta ha sido registrada con éxito."),
          actions: <Widget>[
            TextButton(
              child: Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
                // Redirigir a otra página, por ejemplo, a la pantalla de login
                Navigator.pushReplacementNamed(context, '/login');
              },
            ),
          ],
        );
      },
    );
  }


  // Función para obtener las direcciones desde la geocodificación
  Future<List<String>> _getSuggestions(String query) async {

    ApiResponse<List<String>> list = await Businesess.getSuggestions(query);
    // Retornar la lista si tiene datos, de lo contrario, retornar una lista vacía
    return list.data ?? [];


  }

  // Función para manejar la selección de una dirección
  Future<void> _onSuggestionSelected(String suggestion) async {

    // Establecer la dirección en el controlador de la dirección
    _addressController.text = suggestion;

  }

}
