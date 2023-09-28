import "package:flutter/material.dart";
import "package:qr_flutter/qr_flutter.dart";

class QRGenerator extends StatelessWidget {
  const QRGenerator({required this.jsonData});
  final String jsonData;

  @override
  Widget build(final BuildContext context) => SizedBox(
        height: 500,
        child: AlertDialog(
          title: const Text("Generated QR Code"),
          content: SizedBox(
            height: 300,
            width: 300,
            child: Container(
              color: Colors.white,
              child: QrImageView(
                data: jsonData,
              ),
            ),
          ),
        ),
      );
}
