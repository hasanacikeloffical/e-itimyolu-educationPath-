import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:education_path/UserUI/Controller/AuthController/AuthController.dart';
import 'package:education_path/UserUI/View/ViewComponent/CommentMessageViewComponent.dart';

class BookDetailPage extends StatefulWidget {
  final Map<String, dynamic> book;
  final void Function(Map<String, dynamic>) onAddToCart;

  const BookDetailPage({
    super.key,
    required this.book,
    required this.onAddToCart,
  });

  @override
  State<BookDetailPage> createState() => _BookDetailPageState();
}

class _BookDetailPageState extends State<BookDetailPage> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final TextEditingController _commentController = TextEditingController();

  final _auth = AuthController.instance;

  bool _isLiked = false;

  String get productId => widget.book['id'].toString();

  @override
  void initState() {
    super.initState();
    _loadProductLike();
  }

  Future<void> _loadProductLike() async {
    final user = _auth.currentUser;

    if (user == null) return;

    final snap = await _db
        .collection('products')
        .doc(productId)
        .collection('likes')
        .doc(user.uid)
        .get();

    if (mounted) {
      setState(() {
        _isLiked = snap.exists;
      });
    }
  }

  Future<void> _toggleProductLike() async {
    final user = _auth.currentUser;

    if (user == null) return;

    final ref = _db
        .collection('products')
        .doc(productId)
        .collection('likes')
        .doc(user.uid);

    if (_isLiked) {
      await ref.delete();
    } else {
      await ref.set({
        'userId': user.uid,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }

    if (mounted) {
      setState(() {
        _isLiked = !_isLiked;
      });
    }
  }

  Future<void> _updateComment(
    String commentId,
    String newText,
  ) async {
    if (newText.trim().isEmpty) return;

    try {
      await _db
          .collection('products')
          .doc(productId)
          .collection('comments')
          .doc(commentId)
          .update({
        'text': newText.trim(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Yorum başarıyla güncellendi"),
          ),
        );
      }
    } catch (e) {
      debugPrint("Güncelleme hatası: $e");
    }
  }

  void _showEditSheet(
    String commentId,
    String currentText,
  ) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final editController = TextEditingController(text: currentText);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: cs.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(28),
        ),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Yorumu Düzenle",
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: editController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: "Yorumunuzu güncelleyin...",
                  filled: true,
                  fillColor: cs.surfaceContainerHighest,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text("İptal"),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: () {
                        _updateComment(
                          commentId,
                          editController.text,
                        );

                        Navigator.pop(context);
                      },
                      child: const Text("Güncelle"),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildImage(
    Map<String, dynamic> b,
  ) {
    final images = [
      b['image'],
      b['image2'] ?? b['image'],
    ];

    return SizedBox(
      width: 130,
      height: 190,
      child: _AutoImageSlider(images: images),
    );
  }

  Widget _buildInfo(
    Map<String, dynamic> b,
    ThemeData theme,
  ) {
    final cs = theme.colorScheme;

    return StreamBuilder<Map<String, dynamic>?>(
      stream: _auth.userProfileStream,
      builder: (context, snapshot) {
        final profile = snapshot.data;

        final isStudent = profile?['isStudent'] == true;

        final originalPrice = (b['price'] as num?)?.toDouble() ?? 0.0;

        final discountedPrice = originalPrice * 0.8;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              b['title'] ?? '',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 14),
            _buildInfoRow(
              theme,
              Icons.person_rounded,
              "Yazar",
              b['author'] ?? "...",
            ),
            _buildInfoRow(
              theme,
              Icons.calendar_today_rounded,
              "Yıl",
              b['publishYear'] ?? "...",
            ),
            _buildInfoRow(
              theme,
              Icons.menu_book_rounded,
              "Sayfa",
              b['pageCount'] ?? "...",
            ),
            const SizedBox(height: 18),
            _buildOriginalPrice(
              theme,
              originalPrice,
            ),
          ],
        );
      },
    );
  }

  Widget _buildInfoRow(
    ThemeData theme,
    IconData icon,
    String label,
    String value,
  ) {
    final cs = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(
            icon,
            size: 18,
            color: cs.primary,
          ),
          const SizedBox(width: 10),
          Text(
            "$label: ",
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: cs.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentInput(
    ThemeData theme,
  ) {
    final cs = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Yorum Yap",
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _commentController,
                decoration: InputDecoration(
                  hintText: "Yorumunuzu yazın...",
                  filled: true,
                  fillColor: cs.surfaceContainerHighest,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 16,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    cs.primary,
                    cs.primaryContainer,
                  ],
                ),
                borderRadius: BorderRadius.circular(18),
              ),
              child: IconButton(
                onPressed: () async {
                  final text = _commentController.text.trim();

                  if (text.isEmpty) return;

                  final user = _auth.currentUser;

                  if (user == null) return;

                  _commentController.clear();

                  await _db
                      .collection('products')
                      .doc(productId)
                      .collection('comments')
                      .add({
                    'userId': user.uid,
                    'text': text,
                    'createdAt': FieldValue.serverTimestamp(),
                  });
                },
                icon: Icon(
                  Icons.send_rounded,
                  color: cs.onPrimary,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildOriginalPrice(
    ThemeData theme,
    double price,
  ) {
    final cs = theme.colorScheme;

    return Text(
      '${price.toStringAsFixed(2)} TL',
      style: theme.textTheme.headlineSmall?.copyWith(
        fontWeight: FontWeight.w900,
        color: cs.primary,
      ),
    );
  }

  Widget _buildDiscountedPrice(
    ThemeData theme,
    double original,
    double discounted,
  ) {
    final cs = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${original.toStringAsFixed(2)} TL',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: cs.onSurfaceVariant,
            decoration: TextDecoration.lineThrough,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${discounted.toStringAsFixed(2)} TL',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w900,
            color: cs.primary,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final b = widget.book;

    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.transparent,
        foregroundColor: cs.onSurface,
        title: Text(
          b['title'] ?? 'Detay',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [
                    cs.surface,
                    cs.surfaceContainer,
                    cs.surface,
                  ]
                : [
                    cs.primary.withOpacity(.03),
                    cs.surface,
                    cs.surface,
                  ],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark ? cs.surfaceContainer : cs.surface,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: cs.outlineVariant.withOpacity(.2),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: isDark
                          ? Colors.black.withOpacity(.25)
                          : Colors.black.withOpacity(.05),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildImage(b),
                    const SizedBox(width: 20),
                    Expanded(
                      child: _buildInfo(
                        b,
                        theme,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: cs.primary,
                        foregroundColor: cs.onPrimary,
                        padding: const EdgeInsets.symmetric(
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      icon: const Icon(
                        Icons.shopping_cart_rounded,
                      ),
                      label: const Text(
                        "Sepete Ekle",
                      ),
                      onPressed: () {
                        if (_auth.currentUser != null &&
                            !_auth.currentUser!.isAnonymous) {
                          widget.onAddToCart(b);

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                "Ürün sepete eklendi",
                              ),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                "Sepete eklemek için giriş yapmalısınız.",
                              ),
                            ),
                          );
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 14),
                  Container(
                    decoration: BoxDecoration(
                      color: cs.surfaceContainerHighest,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: Icon(
                        _isLiked
                            ? Icons.favorite_rounded
                            : Icons.favorite_border_rounded,
                        color: _isLiked ? cs.error : cs.onSurfaceVariant,
                      ),
                      onPressed: _toggleProductLike,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: isDark ? cs.surfaceContainer : cs.surface,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: cs.outlineVariant.withOpacity(.15),
                  ),
                ),
                child: _buildCommentInput(theme),
              ),
              const SizedBox(height: 20),
              CommentMessageViewComponent(
                productId: productId,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AutoImageSlider extends StatefulWidget {
  final List<dynamic> images;

  const _AutoImageSlider({
    required this.images,
  });

  @override
  State<_AutoImageSlider> createState() => _AutoImageSliderState();
}

class _AutoImageSliderState extends State<_AutoImageSlider> {
  final PageController _controller = PageController();

  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _autoSlide();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _autoSlide() async {
    while (mounted) {
      await Future.delayed(
        const Duration(seconds: 3),
      );

      if (!mounted) return;

      _currentPage = (_currentPage + 1) % widget.images.length;

      _controller.animateToPage(
        _currentPage,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  Widget _buildImage(dynamic img) {
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

    return Builder(
      builder: (context) {
        final theme = Theme.of(context);
        final cs = theme.colorScheme;

        return Container(
          color: cs.surfaceContainerHighest,
          child: Icon(
            Icons.broken_image_rounded,
            size: 40,
            color: cs.onSurfaceVariant,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: PageView.builder(
        controller: _controller,
        itemCount: widget.images.length,
        itemBuilder: (context, index) {
          return _buildImage(
            widget.images[index],
          );
        },
      ),
    );
  }
}
