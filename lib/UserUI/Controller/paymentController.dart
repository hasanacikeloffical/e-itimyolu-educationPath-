import 'dart:async';

class PaymentController {

  Future<bool> makePayment({
    required String cardNumber,
    required String name,
    required String cvv,
    required double price,
  }) async {

    await Future.delayed(const Duration(seconds: 2));

    if (cardNumber.length >= 12 && cvv.length == 3) {
      return true;
    }

    return false;
  }
}