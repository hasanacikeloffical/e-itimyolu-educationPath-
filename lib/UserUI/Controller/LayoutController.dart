import 'package:flutter/material.dart';
import 'package:education_path/UserUI/View/bootcamp.dart';
import 'package:education_path/UserUI/View/hackatlon.dart';
import 'package:education_path/UserUI/View/blog.dart';
import 'package:education_path/UserUI/View/products.dart';
import 'package:education_path/UserUI/View/settings.dart';
import 'package:education_path/UserUI/Controller/AuthController/AuthController.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int currentIndex = 0;
  final _auth = AuthController.instance;
  Future<void> addToCart(Map<String, dynamic> item) async {
    if (_auth.currentUser == null) {
      _showSnack("Sepet için giriş yapmalısınız");
      return;
    }

    try {
      await _auth.addToCart(item);
      _showSnack("${item['title']} sepete eklendi");
    } catch (e) {
      _showSnack("Hata: $e");
    }
  }

  Future<void> increaseQty(Map<String, dynamic> item) async {
    if (_auth.currentUser == null) return;
    await _auth.increaseCartQty(item['id'].toString());
  }

  Future<void> decreaseQty(Map<String, dynamic> item) async {
    if (_auth.currentUser == null) return;
    await _auth.decreaseCartQty(item['id'].toString());
  }

  Future<void> removeFromCart(Map<String, dynamic> item) async {
    if (_auth.currentUser == null) return;
    await _auth.removeFromCart(item['id'].toString());
  }
  void _showSnack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  List<Widget> get pages => [
  ProductsPage(
    onAddToCart: addToCart,
  ),
  BootcampPage(),
        HackatlonPage(),
        BlogPage(),
  SettingsPage(),
];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: pages,
      ),
      bottomNavigationBar: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _auth.cartStreamReactive(),
        builder: (context, snapshot) {
          final cart = snapshot.data ?? [];
          final count = cart.fold<int>(
            0,
            (sum, item) => sum + (item['quantity'] ?? 1) as int,
          );

          return BottomNavigationBar(
            currentIndex: currentIndex,
            type: BottomNavigationBarType.fixed,
            onTap: (i) => setState(() => currentIndex = i),
            selectedItemColor: Colors.blue,
            unselectedItemColor: Colors.grey,

            items: [
              BottomNavigationBarItem(
                icon: _buildCartIcon(count),
                label: "Ürünler",
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.school),
                label: "Bootcamp",
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.code),
                label: "Hackatlon",
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.article),
                label: "Blog",
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.settings),
                label: "Ayarlar",
              ),
            ],
          );
        },
      ),
    );
  }
  Widget _buildCartIcon(int count) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        const Icon(Icons.store),
        if (count > 0)
          Positioned(
            right: -6,
            top: -6,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 1.5),
              ),
              child: Text(
                "$count",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                ),
              ),
            ),
          ),
      ],
    );
  }
}