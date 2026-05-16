import 'package:education_path/UserUI/View/bootcamp.dart';
import 'package:education_path/UserUI/View/hackatlon.dart';
import 'package:education_path/UserUI/View/products.dart';
import 'package:education_path/UserUI/View/settings.dart';
import 'package:flutter/material.dart';
import 'package:education_path/UserUI/Controller/AuthController/AuthController.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int currentIndex = 0;
  final _auth = AuthController.instance;

  void _showSnack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), duration: const Duration(seconds: 2)),
    );
  }
  Future<void> addToCart(Map<String, dynamic> item) async {
    if (_auth.currentUser == null) {
      _showSnack("Sepet için giriş yapmalısınız");
      return;
    }

    try {
      await _auth.addToCart(item);
      if (!item.containsKey('student_limit_error')) {
        _showSnack("${item['title']} sepete eklendi");
      }
    } catch (e) {
      _showSnack(e.toString().replaceFirst("Exception: ", ""));
    }
  }
  List<Widget> _buildPages() {
    return [
      ProductsPage(onAddToCart: addToCart),
      BootcampPage(),
      HackatlonPage(),
      SettingsPage(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: _buildPages(),
      ),
      bottomNavigationBar: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _auth.cartStreamReactive(),
        builder: (context, snapshot) {
          final cart = snapshot.data ?? [];
          final count = cart.fold<int>(
            0,
            (sum, item) => sum + (item['quantity'] as int? ?? 1),
          );

          return BottomNavigationBar(
            currentIndex: currentIndex,
            type: BottomNavigationBarType.fixed,
            onTap: (i) => setState(() => currentIndex = i),
            selectedItemColor: Colors.blueAccent,
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
                icon: Icon(Icons.videogame_asset),
                label: "Oyun",
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
        const Icon(Icons.shopping_basket),
        if (count > 0)
          Positioned(
            right: -8,
            top: -8,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              constraints: const BoxConstraints(
                minWidth: 18,
                minHeight: 18,
              ),
              child: Text(
                count > 9 ? "9+" : "$count",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }
}
