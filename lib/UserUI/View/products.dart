import 'package:flutter/material.dart';
import 'package:education_path/UserUI/View/ViewComponent/ShoppingViewComponent.dart';
import 'package:education_path/UserUI/View/ViewComponent/BookDetailViewComponent.dart';
import 'package:education_path/UserUI/Controller/AuthController/AuthController.dart';

class ProductsPage extends StatefulWidget {
  final Function(Map<String, dynamic>) onAddToCart;

  const ProductsPage({
    super.key,
    required this.onAddToCart,
  });

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  String cat = 'Kitaplar';

  final List<String> categories = [
    'Kitaplar',
    'Eğitim Kitapları',
  ];

  Stream<List<Map<String, dynamic>>> getProductsStream() {
    return AuthController.instance.db
        .collection('products')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();

        return {
          'id': doc.id,
          'title': data['title'] ?? '',
          'price': (data['price'] ?? 0).toDouble(),
          'category': data['category'] ?? '',
          'image': data['image'] ?? '',
        };
      }).toList();
    });
  }

  Widget buildImage(dynamic img) {
    if (img is String && img.startsWith('http')) {
      return Image.network(
        img,
        fit: BoxFit.cover,
      );
    }

    if (img is String && img.isNotEmpty) {
      return Image.asset(
        img,
        fit: BoxFit.cover,
      );
    }

    return const Icon(Icons.broken_image);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final isDark = theme.brightness == Brightness.dark;

    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: getProductsStream(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        final products = snapshot.data!;

        final filtered = products
            .where(
              (p) => cat == 'Kitaplar' ? true : p['category'] == cat,
            )
            .toList();

        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          appBar: AppBar(
            elevation: 0,
            centerTitle: true,
            backgroundColor: Colors.transparent,
            title: Text(
              "Ürünler",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 22,
                color: theme.colorScheme.onSurface,
              ),
            ),
            actions: [
              StreamBuilder<List<Map<String, dynamic>>>(
                stream: AuthController.instance.cartStreamReactive(),
                builder: (context, snapshot) {
                  final cart = snapshot.data ?? [];

                  final count = cart.fold<int>(
                    0,
                    (sum, item) => sum + ((item['quantity'] ?? 1) as int),
                  );

                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        IconButton(
                          icon: Icon(
                            Icons.shopping_bag_outlined,
                            color: theme.colorScheme.onSurface,
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const ShoppingPage(),
                              ),
                            );
                          },
                        ),
                        if (count > 0)
                          Positioned(
                            right: 4,
                            top: 4,
                            child: Container(
                              padding: const EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary,
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                "$count",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
          body: Column(
            children: [
              const SizedBox(height: 10),
              SizedBox(
                height: 50,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final c = categories[index];

                    final selected = cat == c;

                    return Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: ChoiceChip(
                        elevation: selected ? 3 : 0,
                        pressElevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        label: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                          ),
                          child: Text(
                            c,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: selected
                                  ? Colors.white
                                  : theme.colorScheme.onSurface,
                            ),
                          ),
                        ),
                        selected: selected,
                        selectedColor: theme.colorScheme.primary,
                        backgroundColor:
                            isDark ? Colors.white10 : Colors.grey.shade100,
                        onSelected: (_) {
                          setState(() {
                            cat = c;
                          });
                        },
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 18),
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                  ),
                  itemCount: filtered.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.62,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 18,
                  ),
                  itemBuilder: (context, index) {
                    final item = filtered[index];

                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => BookDetailPage(
                              book: item,
                              onAddToCart: widget.onAddToCart,
                            ),
                          ),
                        );
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        decoration: BoxDecoration(
                          color: theme.cardColor,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: isDark ? Colors.white10 : Colors.black12,
                          ),
                          boxShadow: [
                            BoxShadow(
                              blurRadius: 18,
                              offset: const Offset(0, 10),
                              color: isDark ? Colors.black45 : Colors.black12,
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 7,
                              child: Padding(
                                padding: const EdgeInsets.all(14),
                                child: Hero(
                                  tag: item['id'],
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(
                                      18,
                                    ),
                                    child: buildImage(
                                      item['image'],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 3,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 4,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Text(
                                      item['title'],
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 14,
                                        color: theme.colorScheme.onSurface,
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: theme.colorScheme.primary
                                            .withOpacity(
                                          0.12,
                                        ),
                                        borderRadius: BorderRadius.circular(
                                          12,
                                        ),
                                      ),
                                      child: Text(
                                        "${item['price']} TL",
                                        style: TextStyle(
                                          color: theme.colorScheme.primary,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
