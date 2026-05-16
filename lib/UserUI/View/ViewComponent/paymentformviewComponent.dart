import 'package:education_path/UserUI/View/ViewComponent/paymentresultpageviewcomponent.dart';
import 'package:flutter/material.dart';
import 'package:education_path/UserUI/Controller/paymentController.dart';

class PaymentFormComponent extends StatefulWidget {
  final String bookName;
  final double price;

  const PaymentFormComponent({
    super.key,
    required this.bookName,
    required this.price,
  });

  @override
  State<PaymentFormComponent> createState() =>
      _PaymentFormComponentState();
}

class _PaymentFormComponentState extends State<PaymentFormComponent> {

  final PaymentController controller = PaymentController();

  final cardCtrl = TextEditingController();
  final nameCtrl = TextEditingController();
  final cvvCtrl = TextEditingController();

  bool loading = false;

  Future<void> pay() async {
    setState(() => loading = true);

    bool result = await controller.makePayment(
      cardNumber: cardCtrl.text,
      name: nameCtrl.text,
      cvv: cvvCtrl.text,
      price: widget.price,
    );

    if (!mounted) return;

    setState(() => loading = false);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PaymentResultPage(success: result),
      ),
    );
  }

  @override
  void dispose() {
    cardCtrl.dispose();
    nameCtrl.dispose();
    cvvCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [

          TextField(
            controller: cardCtrl,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: "Kart Numarası",
              border: OutlineInputBorder(),
            ),
          ),

          const SizedBox(height: 10),

          TextField(
            controller: nameCtrl,
            decoration: const InputDecoration(
              labelText: "Kart Üzerindeki İsim",
              border: OutlineInputBorder(),
            ),
          ),

          const SizedBox(height: 10),

          TextField(
            controller: cvvCtrl,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: "CVV",
              border: OutlineInputBorder(),
            ),
          ),

          const SizedBox(height: 20),

          loading
              ? const CircularProgressIndicator()
              : ElevatedButton(
                  onPressed: pay,
                  child: Text("${widget.price} ₺ Öde"),
                )
        ],
      ),
    );
  }
}