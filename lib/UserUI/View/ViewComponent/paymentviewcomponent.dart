import 'package:education_path/UserUI/View/ViewComponent/paymentformviewComponent.dart';
import 'package:flutter/material.dart';

class PaymentViewComponent extends StatelessWidget {
  final String bookName;
  final double price;

  const PaymentViewComponent({
    super.key,
    required this.bookName,
    required this.price,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Ödeme")),
      body: Column(
        children: [

          ListTile(
            title: Text(bookName),
            subtitle: Text("$price ₺"),
          ),

          const Divider(),

          PaymentFormComponent(
            bookName: bookName,
            price: price,
          ),
        ],
      ),
    );
  }
}