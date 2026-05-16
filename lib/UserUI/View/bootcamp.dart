import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:education_path/UserUI/View/ViewComponent/BootcampDetailViewComponent.dart';
import 'package:flutter/material.dart';

class BootcampPage extends StatefulWidget {
  const BootcampPage({Key? key}) : super(key: key);

  @override
  State<BootcampPage> createState() => _BootcampPageState();
}

class _BootcampPageState extends State<BootcampPage>
    with TickerProviderStateMixin {
  late AnimationController _fabController;
  late Animation<double> _fabAnimation;

  @override
  void initState() {
    super.initState();

    _fabController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fabAnimation = CurvedAnimation(
      parent: _fabController,
      curve: Curves.easeOutBack,
    );

    _fabController.forward();
  }

  @override
  void dispose() {
    _fabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final Stream<QuerySnapshot<Map<String, dynamic>>> bootcampStream =
        FirebaseFirestore.instance.collection('bootcamps').snapshots();

    return Scaffold(
      backgroundColor: cs.surface,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: Text(
          'Bootcamp',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: -.5,
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
        child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: bootcampStream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return _buildLoading(theme, cs);
            }

            if (snapshot.hasError) {
              return _buildError(theme, cs);
            }

            final docs = snapshot.data?.docs ?? [];

            if (docs.isEmpty) {
              return _buildEmpty(theme, cs);
            }

            return CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 110, 20, 24),
                  sliver: SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Keşfet',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w900,
                            letterSpacing: -.8,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${docs.length} bootcamp seni bekliyor 🚀',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final doc = docs[index];
                        final data = doc.data();

                        return _buildBootcampCard(
                          context,
                          doc.id,
                          data,
                          index,
                        );
                      },
                      childCount: docs.length,
                    ),
                  ),
                ),
                const SliverPadding(
                  padding: EdgeInsets.only(bottom: 40),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildLoading(ThemeData theme, ColorScheme cs) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: cs.primary,
            strokeWidth: 3,
          ),
          const SizedBox(height: 18),
          Text(
            'Bootcamp\'ler yükleniyor...',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: cs.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError(ThemeData theme, ColorScheme cs) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline_rounded,
            size: 70,
            color: cs.error,
          ),
          const SizedBox(height: 16),
          Text(
            'Bir hata oluştu',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Lütfen daha sonra tekrar deneyin',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: cs.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty(ThemeData theme, ColorScheme cs) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 110,
            height: 110,
            decoration: BoxDecoration(
              color: cs.primary.withOpacity(.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.school_rounded,
              size: 50,
              color: cs.primary,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Henüz Bootcamp Yok',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Yeni içerikler çok yakında eklenecek',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: cs.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBootcampCard(
    BuildContext context,
    String id,
    Map<String, dynamic> data,
    int index,
  ) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    String getValue(String key, {String defaultValue = ''}) {
      final value = data[key];

      if (value == null) return defaultValue;

      if (value is Timestamp) {
        final dt = value.toDate();

        return '${dt.day.toString().padLeft(2, '0')}.${dt.month.toString().padLeft(2, '0')}.${dt.year}';
      }

      return value.toString();
    }

    final title = getValue('title');
    final startDate = getValue('startDate');
    final location = getValue('location');
    final level = getValue('level', defaultValue: 'Başlangıç');
    final duration = getValue('duration', defaultValue: '4 Hafta');

    final spots = data['spots'];
    final registered = data['registered'] ?? 0;

    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 1),
      duration: Duration(milliseconds: 400 + (index * 100)),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 40 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 24),
        child: InkWell(
          borderRadius: BorderRadius.circular(30),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => BootcampDetailPage(
                  bootcampId: id,
                ),
              ),
            );
          },
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              color: isDark ? cs.surfaceContainer : cs.surface,
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                      ),
                      const SizedBox(height: 14),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          _buildInfoChip(
                            context,
                            Icons.calendar_month_rounded,
                            startDate,
                            cs.primary,
                          ),
                          _buildInfoChip(
                            context,
                            Icons.timer_outlined,
                            duration,
                            cs.tertiary,
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      if (location.isNotEmpty)
                        Row(
                          children: [
                            Icon(
                              Icons.location_on_rounded,
                              size: 16,
                              color: cs.primary,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                location,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: cs.onSurfaceVariant,
                                ),
                              ),
                            ),
                          ],
                        ),
                      const SizedBox(height: 16),
                      Text(
                        title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                          height: 1.3,
                          letterSpacing: -.5,
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildDetailButton(theme, cs),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(
    BuildContext context,
    IconData icon,
    String label,
    Color color,
  ) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(.1),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: color,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailButton(
    ThemeData theme,
    ColorScheme cs,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 14,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: LinearGradient(
          colors: [
            cs.primary.withOpacity(.12),
            cs.secondary.withOpacity(.06),
          ],
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Detayları Gör',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: cs.primary,
            ),
          ),
          CircleAvatar(
            radius: 16,
            backgroundColor: cs.primary.withOpacity(.15),
            child: Icon(
              Icons.arrow_forward_rounded,
              size: 18,
              color: cs.primary,
            ),
          ),
        ],
      ),
    );
  }
}
