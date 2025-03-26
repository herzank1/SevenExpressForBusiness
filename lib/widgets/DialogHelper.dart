import 'package:flutter/material.dart';

class DialogHelper {
  static void showDialogMessage(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Cerrar el diálogo
              },
              child: Text("OK"),
            ),
          ],
        );
      },
    );
  }
}
