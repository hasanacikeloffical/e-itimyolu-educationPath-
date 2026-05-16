import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BootcampDetailPage extends StatefulWidget {
  final String bootcampId;
  const BootcampDetailPage({super.key, required this.bootcampId});

  @override
  State<BootcampDetailPage> createState() => _BootcampDetailPageState();
}

class _BootcampDetailPageState extends State<BootcampDetailPage> {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  final _storage = FirebaseStorage.instance;

  Future<Map<String, dynamic>?> _load() async {
    final snap = await _db.collection('bootcamps').doc(widget.bootcampId).get();
    if (!snap.exists) return null;
    final data = Map<String, dynamic>.from(snap.data() ?? {});
    data['applicationDeadline'] = data['applicationDeadline'] ??
        data['sonBasvuruTarihi'] ??
        data['deadline'] ??
        data['lastApplicationDate'] ??
        data['endDate'];
    final rawImage = (data['image'] ?? data['imageUrl'] ?? '') as dynamic;
    data['resolvedImageUrl'] = await _resolveImageUrl(rawImage);
    return data;
  }

  Future<String> _resolveImageUrl(dynamic raw) async {
    if (raw is! String || raw.isEmpty) return '';
    if (raw.startsWith('assets/') || raw.startsWith('http')) return raw;
    try {
      if (raw.startsWith('gs://'))
        return await _storage.refFromURL(raw).getDownloadURL();
      return await _storage.ref(raw).getDownloadURL();
    } catch (_) {
      return '';
    }
  }

  String _fmt(dynamic v) {
    if (v == null) return '';
    if (v is String) return v;
    if (v is Timestamp) {
      final dt = v.toDate();
      return '${dt.day.toString().padLeft(2, '0')}.${dt.month.toString().padLeft(2, '0')}.${dt.year}';
    }
    return v.toString();
  }

  String _pickFrom(Map<String, dynamic> data, List<String> keys) {
    for (final k in keys) {
      final v = _fmt(data[k]).trim();
      if (v.isNotEmpty) return v;
    }
    return '';
  }

  Widget _infoTile(
      IconData icon, String label, String value, Color color, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.55),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return FutureBuilder<Map<String, dynamic>?>(
      future: _load(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
              body: Center(
                  child: CircularProgressIndicator(
                      color: theme.colorScheme.primary)));
        }
        final data = snapshot.data;
        if (data == null)
          return const Scaffold(body: Center(child: Text("Veri bulunamadı")));

        final title = _pickFrom(data, ["title", "name", "bootcampTitle"]);
        final instructor = _pickFrom(data, ["teacher", "instructor", "owner"]);
        final duration = _pickFrom(data, ["duration", "length"]);
        final startDate =
            _pickFrom(data, ["startDate", "beginDate", "start_date"]);
        final deadline = _pickFrom(
            data, ["applicationDeadline", "sonBasvuruTarihi", "deadline"]);
        final detail = _pickFrom(data, ["detail", "description", "content"]);
        final image = (data['resolvedImageUrl'] ?? '') as String;

        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          body: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverAppBar(
                expandedHeight: 320,
                pinned: true,
                elevation: 0,
                stretch: true,
                backgroundColor: theme.colorScheme.surface,
                leading: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CircleAvatar(
                    backgroundColor: theme.colorScheme.surface.withOpacity(0.8),
                    child: BackButton(color: theme.colorScheme.onSurface),
                  ),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  stretchModes: const [StretchMode.zoomBackground],
                  background: Hero(
                    tag: 'bootcamp_${widget.bootcampId}',
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        image.isNotEmpty
                            ? image.startsWith('assets/')
                                ? Image.asset(image, fit: BoxFit.cover)
                                : Image.network(image, fit: BoxFit.cover)
                            : Container(
                                color: theme.colorScheme.primaryContainer),
                        
                        const DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.black26,
                                Colors.transparent,
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Container(
                  transform: Matrix4.translationValues(0, -35, 0),
                  decoration: BoxDecoration(
                    color: theme.scaffoldBackgroundColor,
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(35)),
                  ),
                  padding: const EdgeInsets.fromLTRB(24, 65, 24,
                      100),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                    
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              title.isNotEmpty ? title : "Başlık Yok",
                              style: theme.textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.w900,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          _buildStatusBadge(theme),
                        ],
                      ),
                      const SizedBox(height: 30),

                     
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: theme.cardColor,
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: isDark
                                  ? Colors.black38
                                  : Colors.grey.withOpacity(0.1),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            )
                          ],
                        ),
                        child: Column(
                          children: [
                            _infoTile(
                                Icons.school_rounded,
                                "Eğitmen",
                                instructor.isNotEmpty
                                    ? instructor
                                    : "Belirtilmemiş",
                                theme.colorScheme.primary,
                                theme),
                            _infoTile(
                                Icons.access_time_filled_rounded,
                                "Program Süresi",
                                duration.isNotEmpty
                                    ? duration
                                    : "Belirtilmemiş",
                                Colors.orangeAccent,
                                theme),
                            _infoTile(
                                Icons.calendar_month_rounded,
                                "Başlangıç",
                                startDate.isNotEmpty
                                    ? startDate
                                    : "Belirtilmemiş",
                                Colors.teal,
                                theme),
                            _infoTile(
                                Icons.notification_important_rounded,
                                "Son Başvuru",
                                deadline.isNotEmpty
                                    ? deadline
                                    : "Belirtilmemiş",
                                theme.colorScheme.error,
                                theme),
                          ],
                        ),
                      ),

                      const SizedBox(height: 35),
                      Text("Program Hakkında",
                          style: theme.textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 15),
                      Text(
                        detail.isNotEmpty
                            ? detail
                            : "Bu bootcamp için henüz detaylı açıklama girilmemiş.",
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                          height: 1.7,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          bottomSheet: _buildBottomAction(theme, isDark, data),
        );
      },
    );
  }

  Widget _buildStatusBadge(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withOpacity(0.4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.primary.withOpacity(0.2)),
      ),
      child: Text(
        "AKTİF",
        style: TextStyle(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.bold,
          fontSize: 12,
          letterSpacing: 1.2,
        ),
      ),
    );
    
  }

  Widget _buildBottomAction(
      ThemeData theme, bool isDark, Map<String, dynamic> data) {
    return StreamBuilder<DocumentSnapshot>(
      stream: _auth.currentUser != null
          ? _db.collection('users').doc(_auth.currentUser!.uid).snapshots()
          : null,
      builder: (context, snapshot) {
        final isStudent = snapshot.hasData &&
            (snapshot.data?.data() as Map?)?['isStudent'] == true;
        final canApply = isStudent;

        return Container(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            boxShadow: [
              BoxShadow(
                color: isDark ? Colors.black45 : Colors.white,
                blurRadius: 40,
                offset: const Offset(0, -10),
              )
            ],
          ),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  canApply ? theme.colorScheme.primary : Colors.grey,
              foregroundColor: canApply
                  ? theme.colorScheme.onPrimary
                  : theme.colorScheme
                      .onSurfaceVariant,
              minimumSize: const Size(double.infinity, 65),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(22)),
              elevation: 8,
              shadowColor: theme.colorScheme.primary.withOpacity(0.4),
            ),
            onPressed: canApply ? _applyToBootcamp : null,
            child: Text(
                canApply ? "Hemen Kaydol" : "Sadece Öğrenciler Başvurabilir",
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5)),
          ),
        );
      },
    );
  }

  Future<void> _applyToBootcamp() async {
    final user = _auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Lütfen önce giriş yapın.")));
      return;
    }

    final userDoc = await _db.collection('users').doc(user.uid).get();
    if (userDoc.data()?['isStudent'] != true) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Bu etkinliğe sadece öğrenciler başvurabilir.")));
      return;
    }

    try {
      await _withLoading(() async {
        await _db.collection("bootcamp_applications").add({
          "bootcampId": widget.bootcampId,
          "userId": user.uid,
          "appliedAt": FieldValue.serverTimestamp(),
        });
      });
      if (!mounted) return;
      _showSuccessDialog(context, Theme.of(context));
    } catch (e) {}
  }

  void _showSuccessDialog(BuildContext context, ThemeData theme) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        title: const Icon(Icons.check_circle, color: Colors.green, size: 60),
        content: const Text(
            "Başvurunuz başarıyla alındı! Sizinle en kısa sürede iletişime geçeceğiz.",
            textAlign: TextAlign.center),
        actions: [
          Center(
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Harika!",
                  style: TextStyle(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold)),
            ),
          )
        ],
      ),
    );
  }

  Future<T?> _withLoading<T>(Future<T> Function() job) async {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator()));
    try {
      return await job();
    } finally {
      if (mounted) Navigator.of(context).pop();
    }
  }
}
