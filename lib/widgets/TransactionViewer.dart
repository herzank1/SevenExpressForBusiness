// Widget TransactionViewer
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:seven_express_api/entities/Transaction.dart';

class TransactionViewer extends StatelessWidget {
  final List<Transaction> transactions;

  // Constructor
  TransactionViewer({required this.transactions});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Transaction Viewer')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: DataTable(
          columns: const [
            DataColumn(label: Text('ID')),
            DataColumn(label: Text('Description')),
            DataColumn(label: Text('Amount')),
            DataColumn(label: Text('Type')),
            DataColumn(label: Text('Timestamp')),
          ],
          rows: transactions.map((transaction) {
            return DataRow(
              cells: [
                DataCell(Text(transaction.id?.toString() ?? 'N/A')),
                DataCell(Text(transaction.description)),
                DataCell(Text(transaction.amount.toString())),
                DataCell(Text(transaction.type.toString().split('.').last)),
                DataCell(Text(transaction.timeStamp)),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}