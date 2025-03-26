import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:geocoding/geocoding.dart';
import 'package:seven_express_api/dto/ApiResponse.dart';
import 'package:seven_express_api/dto/RequestBodies.dart';
import 'package:seven_express_api/entities/Customer.dart';
import 'package:seven_express_api/methods/Businesess.dart';

import '../services/CustomersService.dart';


class SelectCustomerDialog extends StatefulWidget {
  final TextEditingController nameController;
  final TextEditingController phoneController;
  final TextEditingController addressController;
  final TextEditingController positionController;
  final Function(String) getCustomer; // Función para buscar cliente

  const SelectCustomerDialog({
    Key? key,
    required this.nameController,
    required this.phoneController,
    required this.addressController,
    required this.positionController,
    required this.getCustomer,
  }) : super(key: key);

  @override
  _SelectCustomerDialogState createState() => _SelectCustomerDialogState();
}

class _SelectCustomerDialogState extends State<SelectCustomerDialog> {

  Future<void>_updateCustomer()async{


    // Crear el Map con los parámetros necesarios

    String name = widget.nameController.text;
    String phoneNumber= widget.phoneController.text;
    String address=widget.addressController.text;
    String position=widget.positionController.text;

    Map<String, dynamic> customerParams =  BodiesForBusiness.createOrUpdateCustomer(name, address, phoneNumber, position);


    try {
      // Llamar a la función para crear o actualizar el cliente
    ApiResponse<Customer>?response= await Businesess.createOrUpdateCustomer(customerParams);
    Customer? updatedCustomer = response?.data;

      // Si la actualización fue exitosa, puedes hacer algo con updatedCustomer
      if (updatedCustomer != null) {
        setState(() {

          CustomersService.customer = updatedCustomer;


          widget.nameController.text = updatedCustomer.name;
          widget.phoneController.text = updatedCustomer.phoneNumber;
          widget.addressController.text = updatedCustomer.address;
          widget.positionController.text = updatedCustomer.position;
        });
      }
    } catch (e) {
      print("Error actualizando el cliente: $e");
    }

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
      widget.addressController.text = suggestion;

      ApiResponse<String>?response= await Businesess.addressToPosition(suggestion);
      String? addressToPosition = response?.data;

      // Establecer las coordenadas en el controlador de posición
      widget.positionController.text = addressToPosition!;
    
  }






  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Información del Cliente"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: widget.nameController,
            decoration: InputDecoration(labelText: "Nombre del Cliente"),
          ),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: widget.phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(labelText: "Teléfono"),
                ),
              ),
              SizedBox(width: 8), // Espaciado entre campo y botón
              ElevatedButton(
                onPressed: () {
                  widget.getCustomer(widget.phoneController.text);
                },
                child: Text("Buscar"),
              ),
            ],
          ),
          // Barra de búsqueda con autocompletado
          TypeAheadField<String>(
            textFieldConfiguration: TextFieldConfiguration(
              controller: widget.addressController,
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
          SizedBox(height: 16.0),
          TextField(
            controller: widget.positionController,
            decoration: InputDecoration(
              labelText: "Posición",
              enabled: false,  // Este campo es solo para mostrar las coordenadas
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text("OK"),
        ),
        ElevatedButton(
          onPressed: () {
            // Acción para guardar la información

            _updateCustomer();
            Navigator.of(context).pop();
          },
          child: Text("Guardar"),
        ),
      ],
    );
  }
}
