import 'dart:async';

import 'package:flutter/material.dart';
import 'package:seven_express_api/entities/Order.dart';
import 'package:seven_express_api/methods/Deliveries.dart';
import '../../widgets/SlideButton.dart';  // Asegúrate de importar el SlideButton desde widgets
import '../../widgets/OrderListItem.dart';
import '../../services/OrdersControl.dart';

class CurrentOrdersScreen extends StatefulWidget {
  const CurrentOrdersScreen({Key? key}) : super(key: key);

  @override
  _CurrentOrdersScreenState createState() => _CurrentOrdersScreenState();
}


class _CurrentOrdersScreenState extends State<CurrentOrdersScreen>  with AutomaticKeepAliveClientMixin<CurrentOrdersScreen>{

  @override
  bool get wantKeepAlive => true; // Mantener el estado del widget al cambiar de tab



  //Declaramos el slideButtone para conectar o desconectar al repartidor
  final GlobalKey<SlideButtonState> slideButtonKey = GlobalKey(); // 🔥 GlobalKey

  final OrdersControl ordersControl = OrdersControl(); // Se mantiene la misma instancia


  bool isConnected = false;


  @override
  Widget build(BuildContext context) {

    super.build(context); // Llamar a super.build() es necesario cuando usas el mixin

    return Scaffold(
      appBar: AppBar(
        title: Text('Ordenes de Entrega'),
      ),
      body: Column(
        children: [
          // Aquí se usa StreamBuilder para manejar la carga de datos asincrónicos
          Expanded(
            child: StreamBuilder<List<Order>>(
              stream: ordersControl.ordersStream, // Escucha el stream
              builder: (context, snapshot) {

                print("📡 Stream actualizado. Estado: ${snapshot.connectionState} - ¿Datos? ${snapshot.hasData}");

                // Verificamos si la solicitud está en progreso
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator()); // Mostrar el loader mientras esperamos la respuesta
                }

                // Verificamos si hubo un error
                if (snapshot.hasError) {
                  return Center(child: Text('Error al cargar las órdenes'));
                }

                // Si la respuesta es exitosa
                if (snapshot.hasData && snapshot.data != null) {
                  final orders = snapshot.data!; // Accedemos a los datos de la respuesta

                  final filteredOrders = orders.where((order) =>
                  order.status != OrderStatus.CANCELADO &&
                      order.status != OrderStatus.ENTREGADO // Asegúrate de que `isConfirmed` devuelva un valor booleano
                  ).toList();

                  // Si no hay órdenes que cumplan el filtro, mostramos un mensaje
                  if (filteredOrders.isEmpty) {
                    return Center(child: Text('No hay órdenes disponibles.'));
                  }
                  return ListView.separated(
                    itemCount: filteredOrders.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32.0), // Margen a los lados
                        child: OrderListItem(
                          key: ValueKey(filteredOrders[index].id),
                          order: filteredOrders[index],
                        ),
                      );
                    },
                    separatorBuilder: (context, index) => Divider(),
                  );

                } else {
                  return Center(child: Text('No hay órdenes disponibles.'));
                }
              },
            ),
          ),

        ],
      ),
    );
  }

}

