import 'package:flutter/material.dart';

class SnackbarHelper {
  static void showSnackbar(BuildContext context, String message, bool isSuccess) {
    final color = isSuccess ? Colors.green : Colors.red;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: Duration(seconds: 2),
      ),
    );
  }
}
