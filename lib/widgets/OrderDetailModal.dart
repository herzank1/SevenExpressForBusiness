import 'dart:async';

import 'package:flutter/material.dart';
import 'package:seven_express_api/dto/ApiResponse.dart';
import 'package:seven_express_api/entities/Order.dart';
import 'package:seven_express_api/service/ChatApiClient.dart';
import 'package:seven_express_api/service/Message.dart';
import 'package:seven_express_business/widgets/SnackbarHelper.dart';

import '../services/AccountServices.dart';

class OrderDetailModal extends StatefulWidget {
  final Order order;

  const OrderDetailModal({Key? key, required this.order}) : super(key: key);

  @override
  _OrderDetailModalState createState() => _OrderDetailModalState();
}

class _OrderDetailModalState extends State<OrderDetailModal> {

  // Crear un Map estático para almacenar las listas de mensajes por 'roomId'
  static Map<String, List<Message>> messagesMap = {};


  final TextEditingController _chatController = TextEditingController();
  List<Message> _messages = [];
  Timer? _timer; // Para controlar el temporizador

  @override
  void initState() {
    super.initState();
    loadSavedMessages();
    _startFetchingMessages(); // Iniciar la consulta de mensajes cuando se cargue la página
  }

  void loadSavedMessages() {
    setState(() {
      // Verifica si el 'order.id' está en el hashmap
      if (messagesMap.containsKey(widget.order.id.toString())) {
        _messages = messagesMap[widget.order.id.toString()]!;
      } else {
        _messages = []; // Si no se encuentran mensajes, asigna una lista vacía
      }
    });
  }


  @override
  void dispose() {
    messagesMap[widget.order.id]=_messages;
    _stopFetchingMessages(); // Detener el temporizador cuando el widget se elimine
    super.dispose();
  }

  // Método para enviar un mensaje
  Future<void> _sendMessage() async {
    Order order = widget.order;

    Message sendMessage = new Message(
        roomId: order.id,
        id: null,
        from: AccountService.getId(),
        timestamp: DateTime.now(),
        type: MessageType.TEXT,
        content: _chatController.text
    );

    ApiResponse<Message> response = await ChatApiClient.sendMessage(sendMessage);
    if (response.isSuccess()) {
      if (_chatController.text.isNotEmpty) {
        setState(() {
          _messages.add(response.data!);  // Agregar el mensaje a la lista de mensajes
          _chatController.clear();
        });
      }
    } else {
      SnackbarHelper.showSnackbar(
        context,
        "No se pudo enviar el mensaje",
        false,
      );
    }
  }

  // Método para obtener los mensajes
  Future<void> _getMessages() async {
    Order order = widget.order;
    ApiResponse<List<Message>> response = await ChatApiClient.getChat(order.id, null);

    setState(() {
      _messages = response.data!;  // Actualizar la lista de mensajes
    });
  }

  // Inicia el temporizador para obtener mensajes cada 10 segundos
  void _startFetchingMessages() {
    _timer = Timer.periodic(Duration(seconds: 10), (timer) {
      _getMessages(); // Llamar a _getMessages cada 10 segundos
    });
  }

  // Detiene el temporizador
  void _stopFetchingMessages() {
    _timer?.cancel(); // Detener el temporizador si ya está activo
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        height: MediaQuery.of(context).size.height * 0.6,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              "Detalles de la Orden",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Divider(),
            Expanded(
              child: Row(
                children: [
                  // Sección de Información
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "ID: ${widget.order.id}",
                          style: TextStyle(fontSize: 16),
                        ),
                        SizedBox(height: 8),
                        Text(
                          "Cliente: ${widget.order.customer.name} ${widget.order.customer.phoneNumber}",
                          style: TextStyle(fontSize: 16),
                        ),
                        SizedBox(height: 8),
                        Text(
                          "Estado: ${widget.order.status.value}",
                          style: TextStyle(fontSize: 16),
                        ),
                        SizedBox(height: 8),
                        Text(
                          "Fecha de Creación: ${widget.order.creationDate}",
                          style: TextStyle(fontSize: 16),
                        ),
                        SizedBox(height: 8),
                        Text(
                          "Costo de Orden: \$${widget.order.orderCost}",
                          style: TextStyle(fontSize: 16),
                        ),
                        SizedBox(height: 8),
                        Text(
                          "Costo de Entrega: \$${widget.order.deliveryCost}",
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                  VerticalDivider(),
                  // Sección de Chat
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          "Chat",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Expanded(
                          child: ListView.builder(
                            itemCount: _messages.length,
                            itemBuilder: (context, index) {
                              // Verifica si 'from' es igual a getId() y agrega '@Negocio:' al contenido
                              String messageContent = _messages[index].content ?? 'null';
                              if (_messages[index].from == AccountService.getId()) {
                                messageContent = '@Negocio: $messageContent';
                              }

                              return Container(
                                padding: EdgeInsets.symmetric(
                                  vertical: 4,
                                  horizontal: 8,
                                ),
                                margin: EdgeInsets.symmetric(vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(messageContent),
                              );
                            },
                          ),
                        ),

                        TextField(
                          controller: _chatController,
                          decoration: InputDecoration(
                            hintText: "Escribe un mensaje...",
                            suffixIcon: IconButton(
                              icon: Icon(Icons.send, color: Colors.blue),
                              onPressed: _sendMessage,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cerrar"),
            ),
          ],
        ),
      ),
    );
  }
}
