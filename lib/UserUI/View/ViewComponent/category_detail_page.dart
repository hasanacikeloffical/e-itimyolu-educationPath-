import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:education_path/UserUI/Controller/pdf_viewer_page.dart';

class CategoryDetailPage extends StatelessWidget {
  final String categoryName;

  const CategoryDetailPage({
    super.key,
    required this.categoryName,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        title: Text(categoryName),
        centerTitle: true,
        backgroundColor: cs.surface,
        foregroundColor: cs.onSurface,
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('blogs')
            .where('category', isEqualTo: categoryName)
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text('Hata oluştu: ${snapshot.error}'),
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                'Bu kategoride içerik bulunamadı.',
                style: TextStyle(color: cs.onSurfaceVariant),
              ),
            );
          }

          final docs = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final blog = docs[index].data() as Map<String, dynamic>;
              final String pdfUrl = blog['pdfUrl']?.toString() ?? '';
              final String title = blog['title'] ?? 'Başlık Yok';

              String formattedDate = "Tarih Yok";
              if (blog['createdAt'] != null) {
                final dt = (blog['createdAt'] as Timestamp).toDate();
                formattedDate = DateFormat('dd MMM yyyy', 'tr_TR').format(dt);
              }
              final bool hasPdf = pdfUrl.isNotEmpty;
              return Container(
                margin: const EdgeInsets.only(bottom: 18),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      blurRadius: isDark ? 10 : 18,
                      offset: const Offset(0, 8),
                      color: Colors.black.withOpacity(isDark ? .25 : .05),
                    ),
                  ],
                ),
                child: Material(
                  color: isDark ? cs.surfaceContainer : cs.surface,
                  borderRadius: BorderRadius.circular(28),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: () {
                      print("Tıklanan Kart: $title");
                      print("Gidilecek URL: $pdfUrl");

                      if (hasPdf) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PDFViewerPage(
                              url: pdfUrl,
                              title: title,
                            ),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content:
                                Text("Bu belgenin PDF bağlantısı bulunamadı."),
                            backgroundColor: Colors.redAccent,
                          ),
                        );
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(22),
                      child: Row(
                        children: [
                          Container(
                            width: 65,
                            height: 65,
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Icon(
                              Icons.picture_as_pdf_rounded,
                              color: Colors.red,
                              size: 30,
                            ),
                          ),
                          const SizedBox(width: 18),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  title,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    Icon(Icons.calendar_today_rounded,
                                        size: 14, color: cs.onSurfaceVariant),
                                    const SizedBox(width: 6),
                                    Text(
                                      formattedDate,
                                      style:
                                          theme.textTheme.bodySmall?.copyWith(
                                        color: cs.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Text(
                                      "İncele",
                                      style: TextStyle(
                                        color: hasPdf ? cs.primary : cs.outline,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Icon(
                                      Icons.arrow_forward_rounded,
                                      color: hasPdf ? cs.primary : cs.outline,
                                      size: 16,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
