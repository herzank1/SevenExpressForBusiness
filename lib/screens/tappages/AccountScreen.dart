import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:seven_express_api/dto/ApiResponse.dart';
import 'package:seven_express_api/dto/RequestBodies.dart';
import 'package:seven_express_api/entities/Business.dart';

import 'package:flutter/material.dart';
import 'package:seven_express_api/entities/Transaction.dart';
import 'package:seven_express_api/methods/Businesess.dart';
import 'package:seven_express_business/services/OrdersControl.dart';
import 'package:seven_express_business/widgets/PaymentDialog.dart';

import '../../services/AccountServices.dart';
import '../../widgets/TransactionViewer.dart';
import '../LoginPage.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({Key? key}) : super(key: key);

  @override
  _AccountScreenState createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  late StreamSubscription<Business?> _businessSubscription;
  Business? business;

  @override
  void initState() {
    super.initState();
    AccountService.getAccount().then((_) => setState(() {
      business = AccountService.business;
    }));
    _businessSubscription = AccountService.businessStream.listen((updatedBusiness) {
      setState(() {
        business = updatedBusiness;
      });
    });
    AccountService.startAutoUpdate(); // Iniciar actualización automática
  }

  @override
  void dispose() {
    _businessSubscription.cancel(); // Cancelar el stream cuando se destruya el widget
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final business = AccountService.business;
    if (business == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Información de la Cuenta",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          _infoTile("Nombre del negocio", business.businessName),
          _infoTile("Dirección", business.address),
          _infoTile("Saldo", "\$${business.balanceAccount?.balance.toStringAsFixed(2)}"),
          const SizedBox(height: 20),
          Center(
            child: ElevatedButton(
              onPressed: () => _payDebt(),

              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text("Pagar deuda", style: TextStyle(color: Colors.white)),
            ),
          ),
          const SizedBox(height: 20),
          Center(
            child: ElevatedButton(
              onPressed: _logout,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text("Cerrar sesión", style: TextStyle(color: Colors.white)),
            ),
          ),
          // Aquí se inserta el TransactionViewer
          FutureBuilder<List<Transaction>>(
            future: _fetchTransactions(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('No transactions found.'));
              } else {
                return TransactionViewer(transactions: snapshot.data!);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _infoTile(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Text("$label: ", style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value, overflow: TextOverflow.ellipsis)),
        ],
      ),
    );
  }

  Future<void> _logout() async {
   bool? success = await AccountService.logout(); // Asegúrate de implementar esta función en AccountService
   if(success!=null && success==true){
     AccountService.clearToken();
     OrdersControl().dispose();
     Navigator.pushReplacement(
       context,
       MaterialPageRoute(builder: (context) => LoginPage()),
     );

   }

  }
// Función async para cargar las transacciones
  Future<List<Transaction>> _fetchTransactions() async {
    try {
      // Llamada a la API real para obtener las transacciones.
      // Asegúrate de que 'Businesess.getTransactions()' retorne una lista de transacciones
      // Si 'getTransactions()' es un método estático que devuelve una lista de transacciones, asegúrate de que devuelva una lista válida.

      // Si Businesess.getTransactions() devuelve un Future<List<Transaction>>, no necesitas un 'await Future.delayed'.
      ApiResponse<List<Transaction>>? response = await Businesess.getTransactions();

      return response?.data??[];
    } catch (error) {
      // Si ocurre un error durante la llamada a la API, muestra el error
      print("Error fetching transactions: $error");
      return []; // Devuelve una lista vacía si hay un error
    }
  }

  void _payDebt() {
    
   PaymentDialog.payDebt(context);
  }

}
