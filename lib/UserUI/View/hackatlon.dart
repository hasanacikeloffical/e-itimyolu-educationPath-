import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'ViewComponent/hackatlonapplicationviewcomponent.dart';

class HackatlonPage extends StatefulWidget {
  const HackatlonPage({Key? key}) : super(key: key);

  @override
  State<HackatlonPage> createState() => _HackatlonPageState();
}

class _HackatlonPageState extends State<HackatlonPage>
    with TickerProviderStateMixin {
  final FirebaseFirestore db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  late AnimationController _heroController;
  late AnimationController _listController;
  late Animation<double> _heroFade;
  late Animation<Offset> _heroSlide;

  @override
  void initState() {
    super.initState();
    _heroController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));
    _listController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));

    _heroFade = CurvedAnimation(parent: _heroController, curve: Curves.easeOut);
    _heroSlide = Tween<Offset>(begin: const Offset(0, 0.12), end: Offset.zero)
        .animate(
            CurvedAnimation(parent: _heroController, curve: Curves.easeOut));

    _heroController.forward().then((_) => _listController.forward());
  }

  @override
  void dispose() {
    _heroController.dispose();
    _listController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: cs.surface,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: Container(
          margin: const EdgeInsets.only(left: 12),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: BackButton(
              color: cs.onSurface,
              style: const ButtonStyle(
                backgroundColor: WidgetStatePropertyAll(Colors.transparent),
                overlayColor: WidgetStatePropertyAll(Colors.transparent),
              ),
            ),
          ),
        ),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: db.collection('hackathon_settings').doc('main').get(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    width: 40,
                    height: 40,
                    child: CircularProgressIndicator(strokeWidth: 3),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Yükleniyor...",
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            );
          }

          if (!snap.hasData || !snap.data!.exists) {
            return _buildError(theme);
          }

          final data = snap.data!.data() as Map<String, dynamic>;
          final title = data["title"] ?? "Hackathon";
          final desc = data["description"] ?? "";
          final List<Map<String, dynamic>> schedule =
              List<Map<String, dynamic>>.from(data["schedule"] ?? []);

          return CustomScrollView(
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            slivers: [
              SliverToBoxAdapter(
                child: FadeTransition(
                  opacity: _heroFade,
                  child: SlideTransition(
                    position: _heroSlide,
                    child: _HeroCard(
                      title: title,
                      desc: desc,
                      isDark: isDark,
                      cs: cs,
                      theme: theme,
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 32),
                      _SectionHeader(
                        label: "Etkinlik Akışı",
                        theme: theme,
                        cs: cs,
                        itemCount: schedule.length,
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final delay = index * 0.1;
                    final progress =
                        ((_listController.value - delay) / (1 - delay))
                            .clamp(0.0, 1.0);
                    return Opacity(
                      opacity: progress,
                      child: Transform.translate(
                        offset: Offset(0, 20 * (1 - progress)),
                        child: _ScheduleCard(
                          item: schedule[index],
                          isLast: index == schedule.length - 1,
                          index: index,
                          cs: cs,
                          theme: theme,
                        ),
                      ),
                    );
                  },
                  childCount: schedule.length,
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
                  child: _buildApplyButton(theme, cs, title, desc),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildApplyButton(
      ThemeData theme, ColorScheme cs, String title, String desc) {
    return StreamBuilder<User?>(
      stream: _auth.authStateChanges(),
      builder: (context, snapshot) {
        final user = snapshot.data;
        final isLoggedIn = user != null && !user.isAnonymous;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: double.infinity,
          height: 56,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: isLoggedIn
                ? LinearGradient(
                    colors: [cs.primary, cs.primaryContainer],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  )
                : null,
            color: isLoggedIn ? null : cs.surfaceContainerHighest,
            boxShadow: isLoggedIn
                ? [
                    BoxShadow(
                      color: cs.primary.withOpacity(0.3),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            child: InkWell(
              onTap: isLoggedIn
                  ? () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) {
                        return const HackatlonApplicationViewComponent();
                      }));
                    }
                  : null,
              splashColor: isLoggedIn ? cs.onPrimary.withOpacity(0.1) : null,
              highlightColor:
                  isLoggedIn ? cs.onPrimary.withOpacity(0.05) : null,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      isLoggedIn ? Icons.send_rounded : Icons.login_rounded,
                      color: isLoggedIn ? cs.onPrimary : cs.onSurfaceVariant,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      isLoggedIn
                          ? "Hackathon'a Katıl"
                          : "Katılmak İçin Giriş Yap",
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: isLoggedIn ? cs.onPrimary : cs.onSurfaceVariant,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
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
  }

  Widget _buildError(ThemeData theme) {
    final cs = theme.colorScheme;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: cs.error.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.warning_amber_rounded, size: 40, color: cs.error),
          ),
          const SizedBox(height: 20),
          Text(
            "İçerik Bulunamadı",
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Lütfen daha sonra tekrar deneyin",
            style: TextStyle(
              color: cs.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  final String title;
  final String desc;
  final bool isDark;
  final ColorScheme cs;
  final ThemeData theme;

  const _HeroCard({
    required this.title,
    required this.desc,
    required this.isDark,
    required this.cs,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 80, 20, 40),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            cs.primary.withOpacity(0.15),
            cs.surface,
          ],
        ),
      ),
      child: Column(
        children: [
          TweenAnimationBuilder(
            tween: Tween<double>(begin: 0, end: 1),
            duration: const Duration(milliseconds: 600),
            curve: Curves.elasticOut,
            builder: (context, value, child) {
              return Transform.scale(
                scale: value,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [cs.primary, cs.primaryContainer],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: cs.primary.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Icon(Icons.emoji_events_rounded,
                      size: 40, color: cs.onPrimary),
                ),
              );
            },
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: cs.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: cs.primary.withOpacity(0.2), width: 1),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  "Aktif Başvurular Devam Ediyor",
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: cs.primary,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text(
            title,
            style: theme.textTheme.displaySmall?.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: -1,
              height: 1.2,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            desc,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: cs.onSurfaceVariant,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String label;
  final ThemeData theme;
  final ColorScheme cs;
  final int itemCount;

  const _SectionHeader({
    required this.label,
    required this.theme,
    required this.cs,
    required this.itemCount,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.timeline_rounded, size: 24, color: cs.primary),
        const SizedBox(width: 8),
        Text(
          label,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
          ),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: cs.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            "$itemCount Aşama",
            style: theme.textTheme.labelSmall?.copyWith(
              color: cs.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _ScheduleCard extends StatelessWidget {
  final Map item;
  final bool isLast;
  final int index;
  final ColorScheme cs;
  final ThemeData theme;

  const _ScheduleCard({
    required this.item,
    required this.isLast,
    required this.index,
    required this.cs,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final isHighlighted = item["highlighted"] ?? false;

    // Her aşama için farklı ikonlar
    final Map<int, IconData> stageIcons = {
      0: Icons.today_rounded,
      1: Icons.school_rounded,
      2: Icons.group_work_rounded,
      3: Icons.code_rounded,
      4: Icons.assessment_rounded,
      5: Icons.celebration_rounded,
    };

    final icon = stageIcons[index] ?? Icons.star_rounded;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Aşama numarası ve çizgi
              Column(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: isHighlighted
                          ? LinearGradient(
                              colors: [cs.primary, cs.secondary],
                            )
                          : null,
                      color: isHighlighted ? null : cs.surfaceContainerHighest,
                      border: Border.all(
                        color: isHighlighted
                            ? Colors.transparent
                            : cs.outlineVariant,
                        width: 1.5,
                      ),
                    ),
                    child: Icon(
                      icon,
                      size: 18,
                      color: isHighlighted ? cs.onPrimary : cs.primary,
                    ),
                  ),
                  if (!isLast)
                    Container(
                      width: 2,
                      height: 100,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            cs.primary.withOpacity(0.4),
                            cs.outlineVariant.withOpacity(0.2),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 16),

              Expanded(
                child: Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: isHighlighted
                        ? LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              cs.primaryContainer.withOpacity(0.12),
                              cs.secondaryContainer.withOpacity(0.06),
                            ],
                          )
                        : null,
                    color: isHighlighted ? null : cs.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isHighlighted
                          ? cs.primary.withOpacity(0.2)
                          : cs.outlineVariant.withOpacity(0.08),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              item["title"] ?? "",
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                                fontSize: 16,
                                letterSpacing: -0.3,
                              ),
                            ),
                          ),
                          if (isHighlighted)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [cs.primary, cs.secondary],
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                "Şu Anda",
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: cs.onPrimary,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Icon(Icons.access_time_rounded,
                              size: 14, color: cs.primary),
                          const SizedBox(width: 6),
                          Text(
                            item["time"] ?? "",
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: cs.primary,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        item["description"] ?? "",
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: cs.onSurfaceVariant,
                          height: 1.5,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
