import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:seven_express_api/entities/Customer.dart';
import 'package:seven_express_api/entities/Order.dart';
import 'package:seven_express_api/methods/Businesess.dart';
import '../services/OrdersControl.dart';

class OrderListItem extends StatelessWidget {
  final Order order;

  const OrderListItem({Key? key, required this.order}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16.0),
        title: Row(
          children: [
            // Parte izquierda: Datos de la orden (con el mismo ancho)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${order.customer.getFirstName()} - ${order.lastFiveChars()}",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4),
                  Text('Estado: ${order.status.value}'),
                  SizedBox(height: 4),
                  Text('Costo de orden: ${order.orderCost}'),
                ],
              ),
            ),
            // Parte central: Información de entrega (con el mismo ancho)
            if (order.delivery != null) ...[
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.delivery_dining, color: Colors.blue, size: 28),
                    SizedBox(height: 4),
                    Text(
                      order.delivery!.name,
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
            // Parte derecha: Botón para cambiar estado (con el mismo ancho)
            if (order.status == OrderStatus.PREPARANDO) ...[
              Expanded(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: FloatingActionButton(
                    onPressed: () => setReady(),
                    child: Icon(Icons.check, color: Colors.white),
                    backgroundColor: Colors.green, // Puedes cambiar el color según tu preferencia
                    mini: true, // Hace el botón más pequeño
                  ),
                ),
              ),

            ],
          ],
        ),
        onTap: () {
          print('Orden seleccionada: ${order.id}');
        },
      ),
    );
  }




  void cancelPickup() {
    print('Marcado como llegado al negocio');
  //  Deliveries.changeOrderStatus(order.id,null,UserIndication.ARRIVED_TO_BUSINESS.name,null,null);
    OrdersControl().refresh();
  }

  void setReady() {
    print('Orden lista');

    // Crear el Map con los parámetros necesarios
    Map<String, dynamic> orderStatusParams = {
      'orderId': order.id,
      'newStatus': OrderStatus.LISTO.name,

    };

    // Llamar a changeOrderStatus con el Map
    Businesess.changeOrderStatus(orderStatusParams);

    // Actualizar la lista de órdenes
    OrdersControl().refresh();
  }

}

extension on Customer {
  String getFirstName() {
    return name.split(" ").first;
  }
}