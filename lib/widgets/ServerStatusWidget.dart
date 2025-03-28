import 'dart:async';

import 'package:flutter/material.dart';
import 'package:seven_express_api/dto/ApiResponse.dart';
import 'package:seven_express_api/entities/SystemStatus.dart';
import 'package:seven_express_api/methods/Businesess.dart';

class ServerStatusWidget extends StatefulWidget {
  const ServerStatusWidget({Key? key}) : super(key: key);

  @override
  _ServerStatusWidgetState createState() => _ServerStatusWidgetState();
}

class _ServerStatusWidgetState extends State<ServerStatusWidget> {
  SystemStatus? systemStatus;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    startUpdatingServerStatus(); // Llamar a la función para iniciar el timer
  }

  // Función que llama a la API y actualiza el estado cada minuto
  void startUpdatingServerStatus() {
    // Inicia el timer para que se ejecute cada minuto
    _timer = Timer.periodic(Duration(seconds: 5), (timer) async {
      print("Timer ticked"); // Verificación de si el timer está funcionando

      ApiResponse<SystemStatus>? status = await Businesess.getSystemStatus();

      // Imprime la respuesta para depuración
      print('System Status Response: ${status?.data}');

      if (status != null && status.isSuccess()) {
        setState(() {
          systemStatus = status.data; // Actualiza el estado con los nuevos datos
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10,
              spreadRadius: 2,
              offset: Offset(2, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (systemStatus != null) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(Icons.person, color: Colors.blue),
                  Text("Connected Deliveries: ${systemStatus!.connectedDeliveries}"),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(Icons.shopping_cart, color: Colors.orange),
                  Text("In Process Orders: ${systemStatus!.inProcessOrders}"),
                ],
              ),
              SizedBox(height: 8),
              // Mostrar la saturación como texto
              Text(
                "Saturation Score: ${systemStatus!.saturationScore.toStringAsFixed(1)}",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: systemStatus!.saturationScore <= 1
                      ? Colors.green
                      : systemStatus!.saturationScore <= 2
                      ? Colors.orange
                      : Colors.red,
                ),
              ),
              SizedBox(height: 8),
              Container(
                width: 64,
                height: 8,
                decoration: BoxDecoration(
                  color: systemStatus!.saturationScore <= 1
                      ? Colors.green
                      : systemStatus!.saturationScore <= 2
                      ? Colors.orange
                      : Colors.red,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ] else ...[
              CircularProgressIndicator(),
            ],
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel(); // Cancela el timer cuando el widget se destruya
    super.dispose();
  }
}
