import 'package:flutter/material.dart';
import 'package:seven_express_business/screens/tappages/AccountScreen.dart';
import 'package:seven_express_business/screens/tappages/CurrentOrdersScreen.dart';
import 'package:seven_express_business/screens/tappages/NewOrderScreen.dart';



class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);





  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3, // Número de pestañas
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Seven Express"),
          automaticallyImplyLeading: false, // Elimina la flecha de retroceso
          bottom: const TabBar(
            indicatorColor: Colors.lightBlueAccent,
            labelColor: Colors.blueAccent,
            unselectedLabelColor: Colors.black12,
            tabs: [
            //  Tab(icon: Icon(Icons.map), text: "Map"), // Pestaña del mapa
              Tab(icon: Icon(Icons.shopping_cart), text: "Nueva Orden"),
              Tab(icon: Icon(Icons.shopping_cart), text: "En proceso"),
              Tab(icon: Icon(Icons.person), text: "Mi Cuenta"),
              //  Tab(icon: Icon(Icons.history), text: "Historial"),
             // Tab(icon: Icon(Icons.settings), text: "Configuracion"),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            //MapScreen(), // Aquí puedes colocar el widget del mapa
            NewOrderScreen(),
            CurrentOrdersScreen(),
            AccountScreen(),
         //   HistoryScreen(),
         //   SettingsScreen(),
          ],
        ),
      ),
    );
  }
}




class HistoryScreen extends StatelessWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text("History"));
  }
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text("Settings"));
  }
}
