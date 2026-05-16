import 'package:flutter/material.dart';

class PaymentResultPage extends StatelessWidget {
  final bool success;

  const PaymentResultPage({super.key, required this.success});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            Icon(
              success ? Icons.check_circle : Icons.cancel,
              color: success ? Colors.green : Colors.red,
              size: 80,
            ),

            const SizedBox(height: 20),

            Text(
              success ? "Ödeme Başarılı 🎉" : "Ödeme Başarısız ❌",
              style: const TextStyle(fontSize: 20),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Geri Dön"),
            )
          ],
        ),
      ),
    );
  }
}