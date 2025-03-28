import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_dropzone/flutter_dropzone.dart';
import 'package:seven_express_api/dto/ApiResponse.dart';
import 'package:seven_express_api/dto/RequestBodies.dart';
import 'package:seven_express_api/entities/PaymentReceipt.dart';
import 'package:seven_express_api/methods/Businesess.dart';
import 'package:seven_express_business/widgets/DialogHelper.dart';
import 'package:seven_express_business/widgets/SnackbarHelper.dart';

class PaymentDialog {
  static void payDebt(BuildContext context) {
    TextEditingController amountController = TextEditingController();
    TextEditingController referenceController = TextEditingController();
    TextEditingController conceptController = TextEditingController();
    PaymentMethod? selectedMethod;

    Uint8List? uploadedImage;
    DropzoneViewController? dropzoneController;

    void _pickImage() async {
      final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        uploadedImage = await pickedFile.readAsBytes();
      }
    }

    Future<void> _sendPayment() async {
      double amount = double.parse(amountController.text);

      PaymentMethod? paymentMethod = selectedMethod;
      String reference = referenceController.text;
      String concept = conceptController.text;
      String base64Image = uploadedImage != null ? base64Encode(uploadedImage!) : "";

      // Llamar a la API con los datos ingresados
      var paymentReceiptParams = BodiesForBusiness.paymentReceipt(amount, paymentMethod!, reference, concept, base64Image);
      ApiResponse<PaymentReceipt>? response = await Businesess.sendPaymentReceipt(paymentReceiptParams);

      if (response?.data != null && response?.message != null) {
        // Mostrar el snackbar primero
        SnackbarHelper.showSnackbar(context, response?.message??'uknow', true);

        // Retrasar el cierre del diálogo para dar tiempo al Snackbar
        Future.delayed(Duration(seconds: 2), () {
          Navigator.of(context).pop();  // Cerrar el diálogo
        });
      } else {
        // Mostrar el snackbar para error
        SnackbarHelper.showSnackbar(context, response?.message ?? "Error desconocido", false);

        // Retrasar el cierre del diálogo para dar tiempo al Snackbar
        Future.delayed(Duration(seconds: 2), () {
          Navigator.of(context).pop();  // Cerrar el diálogo
        });
      }
    }





    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text("Ingresar Pago"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: "Monto"),
                ),
                DropdownButtonFormField<PaymentMethod>(
                  value: selectedMethod,
                  decoration: InputDecoration(labelText: "Método de Pago"),
                  items: PaymentMethod.values.map((method) {
                    return DropdownMenuItem(
                      value: method,
                      child: Text(method.value), // Mostrar el texto del enum
                    );
                  }).toList(),
                  onChanged: (PaymentMethod? newValue) {
                    if (newValue != null) {
                      selectedMethod = newValue;
                    }
                  },
                ),
                TextField(
                  controller: referenceController,
                  decoration: InputDecoration(labelText: "Referencia"),
                ),
                TextField(
                  controller: conceptController,
                  decoration: InputDecoration(labelText: "Concepto"),
                ),
                SizedBox(height: 10),
                // Área de arrastrar o seleccionar imagen
                Container(
                  height: 150,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Stack(
                    children: [
                      DropzoneView(
                        onCreated: (ctrl) => dropzoneController = ctrl,
                        onDrop: (dynamic file) async {
                          uploadedImage = await dropzoneController!.getFileData(file);
                        },
                      ),
                      Center(
                        child: uploadedImage == null
                            ? Text("Arrastra una imagen o selecciona una")
                            : Image.memory(uploadedImage!, height: 100),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _pickImage,
                  child: Text("Seleccionar Imagen"),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(), // Cierra el modal
              child: Text("Cancelar"),
            ),
            ElevatedButton(
              onPressed: _sendPayment,
              child: Text("Enviar"),
            ),
          ],
        );
      },
    );
  }
}
