import 'package:education_path/UserUI/View/ViewComponent/paymentresultpageviewcomponent.dart';
import 'package:flutter/material.dart';


class PaymentFormPage extends StatefulWidget {
  final String productName;
  final String price;

  const PaymentFormPage({
    super.key,
    required this.productName,
    required this.price,
  });

  @override
  State<PaymentFormPage> createState() => _PaymentFormPageState();
}

class _PaymentFormPageState extends State<PaymentFormPage> {
  final cardNumber = TextEditingController();
  final name = TextEditingController();
  final cvv = TextEditingController();

  void pay() async {
    await Future.delayed(const Duration(seconds: 2)); 

    bool success = cardNumber.text.length > 10;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => PaymentResultPage(success: success),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Ödeme 💳")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [

            Text(widget.productName,
                style: const TextStyle(fontSize: 18)),

            const SizedBox(height: 20),

            TextField(
              controller: cardNumber,
              decoration: const InputDecoration(
                  labelText: "Kart Numarası"),
            ),

            TextField(
              controller: name,
              decoration: const InputDecoration(labelText: "İsim"),
            ),

            TextField(
              controller: cvv,
              decoration: const InputDecoration(labelText: "CVV"),
            ),

            const SizedBox(height: 30),

            ElevatedButton(
              onPressed: pay,
              child: const Text("Ödeme Yap"),
            )
          ],
        ),
      ),
    );
  }
}