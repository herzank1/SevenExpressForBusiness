
import 'dart:async';
import 'dart:developer';
import 'package:seven_express_api/dto/ApiResponse.dart';
import 'package:seven_express_api/entities/Order.dart';
import 'package:seven_express_api/methods/Businesess.dart';

class OrdersControl {
  // 🔹 Instancia única (Singleton)
  static final OrdersControl _instance = OrdersControl._internal();

  // 🔹 Lista de órdenes
  late List<Order> currentOrders;
  StreamController<List<Order>> _ordersStreamController = StreamController<List<Order>>.broadcast();
  Timer? _timer;

  // 🔹 Stream accesible globalmente
  Stream<List<Order>> get ordersStream => _ordersStreamController.stream;

  Order? newOrder;


  // 🔹 Constructor privado
  OrdersControl._internal() {
    currentOrders = []; // Inicializar lista vacía
    _startAutoRefresh();
  }

  // 🔹 Método factory para devolver la misma instancia
  factory OrdersControl() {
    return _instance;
  }

  void _startAutoRefresh() {
    _timer = Timer.periodic(Duration(seconds: 5), (timer) {
      refresh();
    });
  }

  // 🔹 Método accesible globalmente para actualizar el Stream
  Future<void> refresh() async {

    ApiResponse<List<Order>>?response=await Businesess.getMyOrders();

    List<Order>? newOrders =response?.data ?? [];

    if (newOrders != null && _shouldUpdateOrders(newOrders)) {
      currentOrders = newOrders;

      if (_ordersStreamController.isClosed) {
        _ordersStreamController = StreamController<List<Order>>.broadcast();
      }
      _ordersStreamController.add(currentOrders);
      log("Órdenes actualizadas: ${newOrders.length}");
    }
  }


// 🔹 Método privado para verificar si la lista ha cambiado
  bool _shouldUpdateOrders(List<Order> newOrders) {
    // Si las longitudes son diferentes, las listas son diferentes
    if (newOrders.length != currentOrders.length) return true;

    // Recorre cada orden de la lista currentOrders
    for (int i = 0; i < currentOrders.length; i++) {
      Order currentOrder = currentOrders[i];

      // Busca la orden con el mismo id en newOrders
      Order? matchedOrder = newOrders.firstWhere(
            (order) => order.id == currentOrder.id,
        orElse: () => Order.empty(),
      );

      // Si la orden no se encuentra en newOrders, es un cambio
      if (matchedOrder == null) {
        return true;
      }

      // Si se encuentra y los 'body hash' son diferentes, es un cambio
      if (currentOrder.getBodyHash() != matchedOrder.getBodyHash()) {
        return true;
      }
    }

    // Si no hay cambios, no actualizamos
    return false;
  }



  void dispose() {
    _timer?.cancel();
    _ordersStreamController.close();
  }
}
