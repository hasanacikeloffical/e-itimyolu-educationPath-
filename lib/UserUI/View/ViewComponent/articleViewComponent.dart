import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:education_path/UserUI/Controller/pdf_viewer_page.dart';

class ArticlePage extends StatelessWidget {
  const ArticlePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        foregroundColor: cs.onSurface,
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.transparent,
        title: Text(
          "Makaleler",
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('blogs')
            .where('category', isEqualTo: 'Makale')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  "Hata: ${snapshot.error}",
                  textAlign: TextAlign.center,
                  style:
                      TextStyle(color: cs.error, fontWeight: FontWeight.bold),
                ),
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                "Henüz makale eklenmemiş.",
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
              final pdfUrl = blog['pdfUrl'] as String?;
              final title = blog['title'] as String? ?? 'Başlık Yok';

              String formattedDate = "Tarih Yok";
              if (blog['createdAt'] != null) {
                final dt = (blog['createdAt'] as Timestamp).toDate();
                formattedDate = DateFormat('dd MMM yyyy', 'tr_TR').format(dt);
              }

              return Container(
                margin: const EdgeInsets.only(bottom: 18),
                decoration: BoxDecoration(
                  color: isDark ? cs.surfaceContainer : cs.surface,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: cs.outlineVariant.withOpacity(.15)),
                  boxShadow: [
                    BoxShadow(
                      blurRadius: isDark ? 10 : 18,
                      offset: const Offset(0, 8),
                      color: isDark
                          ? Colors.black.withOpacity(.25)
                          : Colors.black.withOpacity(.05),
                    ),
                  ],
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(28),
                  onTap: () {
                    if (pdfUrl != null && pdfUrl.isNotEmpty) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PDFViewerPage(
                            url: pdfUrl,
                            title: title,
                          ),
                        ),
                      );
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(22),
                    child: Row(
                      children: [
                        Container(
                          width: 70,
                          height: 70,
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(.1),
                            borderRadius: BorderRadius.circular(22),
                          ),
                          child: const Icon(Icons.picture_as_pdf_rounded,
                              color: Colors.red, size: 34),
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
                                  fontWeight: FontWeight.w800,
                                  height: 1.4,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  Icon(Icons.calendar_today_rounded,
                                      size: 16, color: cs.onSurfaceVariant),
                                  const SizedBox(width: 8),
                                  Text(formattedDate,
                                      style: theme.textTheme.bodySmall
                                          ?.copyWith(
                                              color: cs.onSurfaceVariant)),
                                ],
                              ),
                              const SizedBox(height: 14),
                              Row(
                                children: [
                                  Text(
                                    "İncele",
                                    style: TextStyle(
                                      color:
                                          (pdfUrl != null && pdfUrl.isNotEmpty)
                                              ? cs.primary
                                              : cs.onSurface.withOpacity(0.4),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Icon(Icons.arrow_forward_rounded,
                                      color:
                                          (pdfUrl != null && pdfUrl.isNotEmpty)
                                              ? cs.primary
                                              : cs.onSurface.withOpacity(0.4),
                                      size: 18),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
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
