import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:education_path/UserUI/Controller/AuthController/AuthController.dart';

class CommentMessageViewComponent extends StatelessWidget {
  final String productId;

  const CommentMessageViewComponent({
    super.key,
    required this.productId,
  });

  @override
  Widget build(BuildContext context) {
    final auth = AuthController.instance;
    final db = FirebaseFirestore.instance;
    final uid = auth.currentUser?.uid;

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: db
          .collection('products')
          .doc(productId)
          .collection('comments')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data!.docs;

        if (docs.isEmpty) {
          return const Center(child: Text("Henüz yorum yok"));
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: docs.length,
          itemBuilder: (context, i) {
            final doc = docs[i];
            final c = doc.data();
            final commentId = doc.id;
            final isOwner = uid != null && c['userId'] == uid;

            return StreamBuilder<QuerySnapshot>(
              stream: db
                  .collection('products')
                  .doc(productId)
                  .collection('comments')
                  .doc(commentId)
                  .collection('likes')
                  .snapshots(),
              builder: (context, likeSnap) {
                final likes = likeSnap.data?.docs ?? [];
                final isLiked = uid != null && likes.any((d) => d.id == uid);

                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 6,
                        color: Colors.black.withOpacity(0.05),
                      )
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const CircleAvatar(
                            radius: 16,
                            child: Icon(Icons.person, size: 18),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              "${c['firstName'] ?? ''} ${c['lastName'] ?? ''}",
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),
                      Text(
                        c['text'] ?? '',
                        style: const TextStyle(fontSize: 14),
                      ),

                      const SizedBox(height: 8),
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(
                              isLiked
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: isLiked ? Colors.red : null,
                            ),
                            onPressed: () async {
                              final ref = db
                                  .collection('products')
                                  .doc(productId)
                                  .collection('comments')
                                  .doc(commentId)
                                  .collection('likes')
                                  .doc(uid);

                              final snap = await ref.get();

                              if (snap.exists) {
                                await ref.delete();
                              } else {
                                await ref.set({
                                  'userId': uid,
                                  'createdAt':
                                      FieldValue.serverTimestamp(),
                                });
                              }
                            },
                          ),
                          Text('${likes.length}'),

                          const Spacer(),

                          if (isOwner) ...[
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () async {
                                final controller =
                                    TextEditingController(text: c['text']);

                                final res = await showDialog<String>(
                                  context: context,
                                  builder: (_) => AlertDialog(
                                    title: const Text("Yorumu Düzenle"),
                                    content: TextField(
                                      controller: controller,
                                      maxLines: null,
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context),
                                        child: const Text("İptal"),
                                      ),
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(
                                                context, controller.text),
                                        child: const Text("Kaydet"),
                                      ),
                                    ],
                                  ),
                                );

                                if (res != null && res.trim().isNotEmpty) {
                                  await db
                                      .collection('products')
                                      .doc(productId)
                                      .collection('comments')
                                      .doc(commentId)
                                      .update({
                                    'text': res.trim(),
                                    'editedAt':
                                        FieldValue.serverTimestamp(),
                                  });
                                }
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () async {
                                await db
                                    .collection('products')
                                    .doc(productId)
                                    .collection('comments')
                                    .doc(commentId)
                                    .delete();
                              },
                            ),
                          ]
                        ],
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}