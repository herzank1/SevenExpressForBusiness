import 'dart:async';

import 'package:flutter/material.dart';
import 'package:seven_express_api/dto/ApiResponse.dart';
import 'package:seven_express_api/dto/RequestBodies.dart';

import 'package:seven_express_api/entities/Customer.dart';
import 'package:seven_express_api/entities/Order.dart';
import 'package:seven_express_api/entities/SystemStatus.dart';
import 'package:seven_express_api/methods/Businesess.dart';
import 'package:seven_express_business/widgets/SnackbarHelper.dart';

import '../../services/CustomersService.dart';
import '../../widgets/SelectCustomerDialog.dart';
import '../../widgets/ServerStatusWidget.dart';

class NewOrderScreen extends StatefulWidget {
  const NewOrderScreen({Key? key}) : super(key: key);



  @override
  _NewOrderScreenState createState() => _NewOrderScreenState();
}

class _NewOrderScreenState extends State<NewOrderScreen> {



  bool isPackage = false; // Estado del switch
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController noteController =
      TextEditingController(); // Nuevo campo de nota

  final TextEditingController orderCostController = TextEditingController();
  final TextEditingController deliveryCostController = TextEditingController();
  int preparationTime = 10; // Tiempo inicial en minutos

  final TextEditingController nameController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController positionController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  void _increaseTime() {
    setState(() {
      preparationTime += 5;
    });
  }

  void _decreaseTime() {
    setState(() {
      if (preparationTime > 5) {
        preparationTime -= 5;
      }
    });
  }

  void _clearFields() {
    phoneController.clear();
    orderCostController.clear();
    deliveryCostController.clear();
    noteController.clear(); // Limpiar la nota
    setState(() {
      preparationTime = 10;
      CustomersService.customer = null;
    });
  }

  void _showSelectCustomerDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SelectCustomerDialog(
          nameController: nameController,
          phoneController: phoneController,
          addressController: addressController,
          positionController: positionController,
          getCustomer: _getCustomer, // Pasamos la función
        );
      },
    );
  }

  Future<void> _sendOrder() async {
    double orderCost = double.tryParse(orderCostController.text) ?? 0.0;
    double deliveryCost = double.tryParse(deliveryCostController.text) ?? 0.0;

    OrderType orderType = isPackage ? OrderType.PACKAGE : OrderType.FOOD;

    Map<String, dynamic> newOrderRequest = BodiesForBusiness.newOrderRequest(
      orderType,
      CustomersService.customer!.phoneNumber,
      noteController.text,
      orderCost,
      deliveryCost,
      preparationTime,
    );

    ApiResponse<Order>? response = await Businesess.sendNewOrder(
      newOrderRequest,
    );
    Order? sent = response?.data;

    if (sent != null) {

      SnackbarHelper.showSnackbar(context, "Orden enviada con éxito: ${sent.id}", true);
      _clearFields();
    } else {
      SnackbarHelper.showSnackbar(context, "Error al enviar la orden.", false);
    }
  }

  Future<void> _cotize() async {
    var quoteRequest = BodiesForBusiness.quoteRequest(
      addressController.text,
      positionController.text,
    );
    ApiResponse<double>? response = await Businesess.getQuote(quoteRequest);
    double deliveryCost = response?.data ?? 50;

    setState(() {
      deliveryCostController.text = deliveryCost.toString();
    });
  }

  Future<void> _getCustomer(String phone) async {
    try {
      ApiResponse<Customer>? response = await Businesess.getCustomer(
        phone,
      ); // Corrección: usamos 'phone' en lugar de 'nameController.text'
      Customer? customer = response?.data;
      print("Buscando cliente con teléfono: $phone");

      if (customer != null) {
        setState(() {
          CustomersService.customer = customer;
          nameController.text = customer.name ?? "";
          addressController.text = customer.address ?? "";
          positionController.text = customer.position ?? "";
        });
      } else {
        print("Cliente no encontrado.");
      }
    } catch (e) {
      print("Error al obtener cliente: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          width: 450, // Ajusta el ancho según tu necesidad
          padding: EdgeInsets.all(20),
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
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Agregar el widget de estado del servidor al principio
                ServerStatusWidget(),
                SizedBox(height: 25),

                // Switch Tipo de Orden
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Tipo de orden: ${isPackage ? 'Paquete' : 'Alimento'}",
                    ),
                    Switch(
                      value: isPackage,
                      onChanged: (value) {
                        setState(() {
                          isPackage = value;
                        });
                      },
                    ),
                  ],
                ),
                SizedBox(height: 16),

                // Teléfono del cliente con botón de búsqueda
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          labelText: 'Número de celular del cliente',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    IconButton(
                      icon: Icon(Icons.search),
                      onPressed: _showSelectCustomerDialog,
                    ),
                  ],
                ),
                SizedBox(height: 16),

                // Nota opcional
                TextField(
                  controller: noteController,
                  maxLines: 2,
                  decoration: InputDecoration(
                    labelText: 'Nota (opcional)',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16),

                // Costo de orden
                TextField(
                  controller: orderCostController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Costo de orden',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16),

                // Costo de envío con botón de cotizar
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: deliveryCostController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Costo de envío',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    TextButton(onPressed: _cotize, child: Text('Cotizar')),
                  ],
                ),
                SizedBox(height: 16),

                // Tiempo de preparación con botones de aumento y disminución
                Column(
                  children: [
                    Text(
                      'Tiempo de preparación:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: _decreaseTime,
                          style: ElevatedButton.styleFrom(
                            shape: CircleBorder(),
                            padding: EdgeInsets.all(16),
                            backgroundColor: Colors.redAccent,
                          ),
                          child: Icon(Icons.remove, color: Colors.white),
                        ),
                        SizedBox(width: 16),
                        Container(
                          width: 60,
                          height: 60,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.grey[300],
                          ),
                          child: Text(
                            '$preparationTime',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        SizedBox(width: 16),
                        ElevatedButton(
                          onPressed: _increaseTime,
                          style: ElevatedButton.styleFrom(
                            shape: CircleBorder(),
                            padding: EdgeInsets.all(16),
                            backgroundColor: Colors.green,
                          ),
                          child: Icon(Icons.add, color: Colors.white),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 16),

                // Botones de enviar y limpiar
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: _sendOrder,
                      child: Text('Enviar'),
                    ),
                    ElevatedButton(
                      onPressed: _clearFields,
                      child: Text('Limpiar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white60,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }



}
