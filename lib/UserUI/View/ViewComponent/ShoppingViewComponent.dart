import 'package:education_path/UserUI/Controller/AuthController/AuthController.dart';
import 'package:education_path/UserUI/Controller/checkout_page.dart';
import 'package:flutter/material.dart';

class ShoppingPage extends StatelessWidget {
  const ShoppingPage({super.key});

  void _goToCheckout(BuildContext context, List<Map<String, dynamic>> cart,
      double total, double discount, double subtotal) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CheckoutPage(
          cartItems: cart,
          totalAmount: total,
          discountAmount: discount,
          subtotal: subtotal,
        ),
      ),
    );
  }

  String? _extractImageUrl(dynamic img) {
    if (img == null) return null;
    if (img is String) return img;
    if (img is Map) {
      if (img['url'] is String) return img['url'];
      if (img['downloadUrl'] is String) return img['downloadUrl'];
      if (img['path'] is String) return img['path'];
      if (img['image'] is String) return img['image'];
    }
    return null;
  }

  Widget _buildImageWidget(dynamic img, {BoxFit fit = BoxFit.cover}) {
    final url = _extractImageUrl(img);

    if (url != null && url.startsWith('http')) {
      return Image.network(url, fit: fit);
    }

    if (url != null && url.isNotEmpty) {
      return Image.asset(url, fit: fit);
    }

    return const Icon(Icons.broken_image);
  }

  @override
  Widget build(BuildContext context) {
    final auth = AuthController.instance;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return StreamBuilder<Map<String, dynamic>?>(
        stream: auth.userProfileStream,
        builder: (context, userSnapshot) {
          final isStudent = userSnapshot.data?['isStudent'] == true;

          return StreamBuilder<List<Map<String, dynamic>>>(
            stream: auth.cartStreamReactive(),
            builder: (context, cartSnapshot) {
              final cart = cartSnapshot.data ?? [];
 
              final subtotal = cart.fold<double>(
                0,
                (sum, item) =>
                    sum +
                    (item['price'] as num).toDouble() * (item['quantity'] ?? 1),
              );
 
              double total = subtotal;
              double discountAmount = 0;

              if (isStudent && cart.isNotEmpty) {
                final mostExpensiveItem = cart.reduce((a, b) =>
                    (a['price'] as num) > (b['price'] as num) ? a : b);
                final maxPrice = (mostExpensiveItem['price'] as num).toDouble();

                discountAmount = maxPrice * 0.20;
                total = subtotal - discountAmount;
              }

              return Scaffold(
                backgroundColor: cs.surface,

                appBar: AppBar(
                  backgroundColor: cs.surface,
                  elevation: 0,
                  foregroundColor: cs.onSurface,
                  title: const Text("Sepet"),
                ),

                body: cart.isEmpty
                    ? Center(
                        child: Text(
                          "Sepetiniz boş",
                          style: TextStyle(
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(10),
                        itemCount: cart.length,
                        itemBuilder: (context, i) {
                          final item = cart[i];

                          return Container(
                            margin: const EdgeInsets.symmetric(vertical: 6),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: cs.surfaceContainerLow,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: cs.outlineVariant.withOpacity(0.3),
                              ),
                            ),
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 55,
                                  height: 55,
                                  child: _buildImageWidget(item['image']),
                                ),

                                const SizedBox(width: 10),

                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item['title'],
                                        style: theme.textTheme.titleMedium
                                            ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        "${item['price']} TL x ${item['quantity'] ?? 1}",
                                        style: theme.textTheme.bodyMedium
                                            ?.copyWith(
                                          color: cs.onSurfaceVariant,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.remove),
                                      onPressed: () =>
                                          auth.decreaseCartQty(item['id']),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.add),
                                      onPressed: () =>
                                          auth.increaseCartQty(item['id']),
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.delete, color: cs.error),
                                      onPressed: () =>
                                          auth.removeFromCart(item['id']),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          );
                        },
                      ),

                bottomNavigationBar: Container(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                  decoration: BoxDecoration(
                    color: cs.surface,
                    border: Border(
                      top: BorderSide(
                        color: cs.outlineVariant.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isStudent && discountAmount > 0) ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Ara Toplam:",
                                style: theme.textTheme.bodyLarge),
                            Text("${subtotal.toStringAsFixed(2)} TL",
                                style: theme.textTheme.bodyLarge),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Öğrenci İndirimi:",
                                style: TextStyle(color: Colors.green.shade700)),
                            Text("-${discountAmount.toStringAsFixed(2)} TL",
                                style: TextStyle(color: Colors.green.shade700)),
                          ],
                        ),
                        const Divider(height: 16),
                      ],
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Toplam:",
                            style: theme.textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            "${total.toStringAsFixed(2)} TL",
                            style: theme.textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: cart.isEmpty
                              ? null
                              : () => _goToCheckout(context, cart, total,
                                  discountAmount, subtotal),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                          child: const Text("Satın Al",
                              style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        });
  }
}
