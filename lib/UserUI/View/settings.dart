import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:education_path/UserUI/Controller/AuthController/AuthController.dart';
import 'package:education_path/UserUI/View/AuthView/auth_page.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:education_path/UserUI/Controller/themeController.dart';

String titleCase(String? input) {
  if (input == null) return '';
  final s = input.trim();
  if (s.isEmpty) return '';

  return s
      .split(RegExp(r'\s+'))
      .map(
        (w) => w.isEmpty
            ? ''
            : (w[0].toUpperCase() +
                (w.length > 1 ? w.substring(1).toLowerCase() : '')),
      )
      .join(' ');
}

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final auth = AuthController.instance;

  ThemeMode get mode => ThemeService.themeNotifier.value;

  bool get isRealUser =>
      auth.currentUser != null && !auth.currentUser!.isAnonymous;

  void setTheme(ThemeMode m) {
    ThemeService.setThemeMode(m);
    setState(() {});
  }

  Future<void> signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const AuthLoginPage()),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Çıkış yapılamadı: $e")),
      );
    }
  }

  void _handleAuthAction() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const AuthLoginPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 170,
            pinned: true,
            backgroundColor: colorScheme.surface,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: 24, bottom: 20),
              title: Text(
                "Ayarlar",
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          colorScheme.primary,
                          colorScheme.primaryContainer
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 24,
                          offset: const Offset(0, 10),
                          color: colorScheme.primary.withOpacity(.25),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 74,
                          height: 74,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(.18),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isRealUser
                                ? Icons.person_rounded
                                : Icons.lock_outline_rounded,
                            size: 34,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 18),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isRealUser ? "Hesabın Aktif" : "Misafir Modu",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 22,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                isRealUser
                                    ? "Profil ve ayarlarını yönetebilirsin."
                                    : "Giriş yaparak tüm özellikleri aç.",
                                style: TextStyle(
                                  color: Colors.white.withOpacity(.9),
                                  height: 1.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),
                  _sectionTitle(context, "Hesap"),
                  const SizedBox(height: 14),
                  _modernTile(
                    context,
                    title: isRealUser
                        ? "Profil Bilgileri"
                        : "Giriş Yap veya Kayıt Ol",
                    subtitle: isRealUser
                        ? "Kişisel bilgilerini düzenle"
                        : "Hesabına giriş yap",
                    icon: isRealUser
                        ? Icons.person_outline_rounded
                        : Icons.login_rounded,
                    onTap: () {
                      if (isRealUser) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const ProfilePage()),
                        );
                      } else {
                        _handleAuthAction();
                      }
                    },
                  ),
                  const SizedBox(height: 30),
                  _sectionTitle(context, "Tema"),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(
                          color: colorScheme.outlineVariant.withOpacity(.35)),
                      boxShadow: [
                        BoxShadow(
                          blurRadius: isDark ? 10 : 18,
                          spreadRadius: 1,
                          offset: const Offset(0, 8),
                          color: isDark
                              ? Colors.black.withOpacity(.25)
                              : Colors.black.withOpacity(.04),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: colorScheme.primary.withOpacity(.12),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Icon(Icons.palette_outlined,
                                  color: colorScheme.primary),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Tema Seçimi",
                                      style: theme.textTheme.titleMedium
                                          ?.copyWith(
                                              fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 2),
                                  Text("Uygulama görünümünü değiştir",
                                      style: TextStyle(
                                          color: colorScheme.onSurface
                                              .withOpacity(.6))),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 22),
                        SegmentedButton<ThemeMode>(
                          segments: const [
                            ButtonSegment(
                                value: ThemeMode.system,
                                icon: Icon(Icons.brightness_auto),
                                label: Text("Sistem")),
                            ButtonSegment(
                                value: ThemeMode.light,
                                icon: Icon(Icons.light_mode),
                                label: Text("Açık")),
                            ButtonSegment(
                                value: ThemeMode.dark,
                                icon: Icon(Icons.dark_mode),
                                label: Text("Koyu")),
                          ],
                          selected: {mode},
                          onSelectionChanged: (Set<ThemeMode> selection) =>
                              setTheme(selection.first),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                  GestureDetector(
                    onTap: () async {
                      if (isRealUser) {
                        await signOut();
                      } else {
                        _handleAuthAction();
                      }
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 22, vertical: 18),
                      decoration: BoxDecoration(
                        color: isRealUser
                            ? colorScheme.errorContainer.withOpacity(.6)
                            : colorScheme.primaryContainer.withOpacity(.5),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isRealUser
                                ? Icons.logout_rounded
                                : Icons.login_rounded,
                            color: isRealUser
                                ? colorScheme.error
                                : colorScheme.primary,
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Text(
                              isRealUser ? "Çıkış Yap" : "Giriş Yap",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: isRealUser
                                    ? colorScheme.error
                                    : colorScheme.primary,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          const Icon(Icons.chevron_right_rounded),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 50),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(BuildContext context, String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: Theme.of(context)
            .textTheme
            .titleMedium
            ?.copyWith(fontWeight: FontWeight.w900),
      ),
    );
  }

  Widget _modernTile(BuildContext context,
      {required String title,
      required String subtitle,
      required IconData icon,
      required VoidCallback onTap}) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(28),
        onTap: onTap,
        child: Ink(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(28),
            border:
                Border.all(color: colorScheme.outlineVariant.withOpacity(.35)),
            boxShadow: [
              BoxShadow(
                blurRadius: isDark ? 10 : 18,
                spreadRadius: 1,
                offset: const Offset(0, 8),
                color: isDark
                    ? Colors.black.withOpacity(.25)
                    : Colors.black.withOpacity(.04),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: colorScheme.primary.withOpacity(.12),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(icon, color: colorScheme.primary),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 4),
                    Text(subtitle,
                        style: TextStyle(
                            color: colorScheme.onSurface.withOpacity(.6))),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded),
            ],
          ),
        ),
      ),
    );
  }
}

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _authController = AuthController.instance;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Profilim"),
        actions: [
          StreamBuilder<Map<String, dynamic>?>(
            stream: _authController.userProfileStream,
            builder: (context, snapshot) {
              if (!snapshot.hasData || snapshot.data == null)
                return const SizedBox.shrink();
              return IconButton(
                icon: const Icon(Icons.edit_outlined),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          EditProfilePage(userProfile: snapshot.data!),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [
                    colorScheme.surface,
                    colorScheme.surfaceContainer,
                    colorScheme.surface
                  ]
                : [
                    colorScheme.primary.withOpacity(0.03),
                    colorScheme.surface,
                    colorScheme.surface
                  ],
          ),
        ),
        child: StreamBuilder<Map<String, dynamic>?>(
          stream: _authController.userProfileStream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data == null) {
              return const Center(child: Text("Profil bilgileri bulunamadı."));
            }

            final userProfile = snapshot.data!;
            final firstName = userProfile['firstName'] ?? '';
            final lastName = userProfile['lastName'] ?? '';
            final email = userProfile['email'] ?? 'E-posta belirtilmemiş';
            final phone = userProfile['phone'] ?? 'Telefon belirtilmemiş';
            final isStudent = userProfile['isStudent'] ?? false;

            final addressMap = userProfile['address'] as Map<String, dynamic>?;
            String fullAddress = "Adres belirtilmemiş";
            if (addressMap != null) {
              final line = addressMap['line'] ?? '';
              final city = addressMap['city'] ?? '';
              final postalCode = addressMap['postalCode'] ?? '';
              if (line.isNotEmpty || city.isNotEmpty) {
                fullAddress = '$line, $postalCode $city'.trim();
              }
            }

            final university = userProfile['university'] ?? 'Belirtilmemiş';
            final department = userProfile['department'] ?? 'Belirtilmemiş';
            final githubUrl = userProfile['githubUrl'] as String?;
            final linkedinUrl = userProfile['linkedinUrl'] as String?;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  Center(
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: colorScheme.primaryContainer,
                          child: Text(
                            '${firstName.isNotEmpty ? firstName[0] : ''}${lastName.isNotEmpty ? lastName[0] : ''}',
                            style: theme.textTheme.headlineLarge?.copyWith(
                                color: colorScheme.onPrimaryContainer),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text('$firstName $lastName',
                            style: theme.textTheme.headlineSmall
                                ?.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text(email,
                            style: theme.textTheme.bodyLarge?.copyWith(
                                color: colorScheme.onSurfaceVariant)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  _buildInfoCard(
                    theme,
                    title: 'Kişisel Bilgiler',
                    children: [
                      _buildInfoRow(
                          theme, Icons.phone_outlined, 'Telefon', phone),
                      _buildInfoRow(theme, Icons.location_on_outlined, 'Adres',
                          fullAddress),
                    ],
                  ),
                  if (isStudent) ...[
                    const SizedBox(height: 24),
                    _buildInfoCard(
                      theme,
                      title: 'Eğitim Bilgileri',
                      children: [
                        _buildInfoRow(theme, Icons.school_outlined,
                            'Üniversite', university),
                        _buildInfoRow(
                            theme, Icons.book_outlined, 'Bölüm', department),
                      ],
                    ),
                  ],
                  const SizedBox(height: 24),
                  _buildInfoCard(
                    theme,
                    title: 'Sosyal Medya',
                    children: [
                      _buildLinkRow(
                        theme,
                        Icons.code_rounded,
                        'GitHub',
                        githubUrl,
                      ),
                      _buildLinkRow(theme, Icons.work_outline_rounded,
                          'LinkedIn', linkedinUrl),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildInfoCard(ThemeData theme,
      {required String title, required List<Widget> children}) {
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? cs.surfaceContainer : cs.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: cs.outlineVariant.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.2)
                : Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold)),
          const Divider(height: 24),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(
      ThemeData theme, IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: theme.colorScheme.primary, size: 22),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w500)),
                const SizedBox(height: 2),
                Text(value,
                    style: theme.textTheme.bodyLarge
                        ?.copyWith(fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLinkRow(
      ThemeData theme, IconData icon, String label, String? url) {
    final hasUrl = url != null && url.isNotEmpty;

    return InkWell(
      onTap: hasUrl
          ? () async {
              final uri = Uri.tryParse(url);
              if (uri != null && await canLaunchUrl(uri)) {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              }
            }
          : null,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            Icon(icon, color: theme.colorScheme.primary, size: 22),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w500)),
                  const SizedBox(height: 2),
                  Text(hasUrl ? url : 'Belirtilmemiş',
                      style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: hasUrl
                              ? theme.colorScheme.onSurface
                              : theme.colorScheme.onSurfaceVariant
                                  .withOpacity(0.7))),
                ],
              ),
            ),
            if (hasUrl)
              Icon(Icons.open_in_new_rounded,
                  size: 18, color: theme.colorScheme.onSurfaceVariant),
          ],
        ),
      ),
    );
  }
}

class EditProfilePage extends StatefulWidget {
  final Map<String, dynamic> userProfile;
  const EditProfilePage({super.key, required this.userProfile});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _authController = AuthController.instance;
  bool _isLoading = false;

  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _addressLineController;
  late final TextEditingController _addressCityController;
  late final TextEditingController _addressPostalCodeController;
  late final TextEditingController _universityController;
  late final TextEditingController _departmentController;
  late final TextEditingController _githubController;
  late final TextEditingController _linkedinController;

  @override
  void initState() {
    super.initState();
    final profile = widget.userProfile;
    final address = profile['address'] as Map<String, dynamic>? ?? {};

    _firstNameController =
        TextEditingController(text: profile['firstName'] ?? '');
    _lastNameController =
        TextEditingController(text: profile['lastName'] ?? '');
    _phoneController = TextEditingController(text: profile['phone'] ?? '');
    _addressLineController = TextEditingController(text: address['line'] ?? '');
    _addressCityController = TextEditingController(text: address['city'] ?? '');
    _addressPostalCodeController =
        TextEditingController(text: address['postalCode'] ?? '');
    _universityController =
        TextEditingController(text: profile['university'] ?? '');
    _departmentController =
        TextEditingController(text: profile['department'] ?? '');
    _githubController = TextEditingController(text: profile['githubUrl'] ?? '');
    _linkedinController =
        TextEditingController(text: profile['linkedinUrl'] ?? '');
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _addressLineController.dispose();
    _addressCityController.dispose();
    _addressPostalCodeController.dispose();
    _universityController.dispose();
    _departmentController.dispose();
    _githubController.dispose();
    _linkedinController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final addressInfo = {
        'line': _addressLineController.text.trim(),
        'city': _addressCityController.text.trim(),
        'postalCode': _addressPostalCodeController.text.trim(),
      };

      await _authController.updateProfile(
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        phone: _phoneController.text.trim(),
        university: _universityController.text.trim(),
        department: _departmentController.text.trim(),
        githubUrl: _githubController.text.trim(),
        linkedinUrl: _linkedinController.text.trim(),
        extra: {'address': addressInfo},
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Profil başarıyla güncellendi!'),
            backgroundColor: Colors.green),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Hata: $e'),
            backgroundColor: Theme.of(context).colorScheme.error),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isStudent = widget.userProfile['isStudent'] == true;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Profili Düzenle"),
        centerTitle: true,
        scrolledUnderElevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Kişisel Bilgiler",
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              _buildTextField(_firstNameController, "Ad", Icons.person_outline),
              const SizedBox(height: 16),
              _buildTextField(
                  _lastNameController, "Soyad", Icons.person_outline),
              const SizedBox(height: 16),
              _buildTextField(_phoneController, "Telefon", Icons.phone_outlined,
                  keyboardType: TextInputType.phone),
              const SizedBox(height: 24),
              Text("Adres Bilgileri",
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              _buildTextField(_addressLineController, "Adres Satırı",
                  Icons.location_on_outlined,
                  maxLines: 3),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                      child: _buildTextField(_addressCityController, "Şehir",
                          Icons.location_city)),
                  const SizedBox(width: 16),
                  Expanded(
                      child: _buildTextField(_addressPostalCodeController,
                          "Posta Kodu", Icons.local_post_office_outlined,
                          keyboardType: TextInputType.number)),
                ],
              ),
              if (isStudent) ...[
                const SizedBox(height: 24),
                Text("Eğitim Bilgileri",
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                _buildTextField(
                    _universityController, "Üniversite", Icons.school_outlined),
                const SizedBox(height: 16),
                _buildTextField(
                    _departmentController, "Bölüm", Icons.book_outlined),
              ],
              const SizedBox(height: 24),
              Text("Sosyal Medya (İsteğe Bağlı)",
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              _buildTextField(
                  _githubController, "GitHub Profil URL", Icons.code_rounded,
                  isRequired: false),
              const SizedBox(height: 16),
              _buildTextField(_linkedinController, "LinkedIn Profil URL",
                  Icons.work_outline_rounded,
                  isRequired: false),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _isLoading ? null : _saveProfile,
                  icon: _isLoading
                      ? const SizedBox.shrink()
                      : const Icon(Icons.save_alt_outlined),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  label: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2))
                      : const Text("Değişiklikleri Kaydet"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
      TextEditingController controller, String label, IconData icon,
      {int maxLines = 1, TextInputType? keyboardType, bool isRequired = true}) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
        filled: true,
        fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
      ),
      validator: (value) {
        if (isRequired && (value == null || value.isEmpty)) {
          return '$label alanı boş bırakılamaz.';
        }
        return null;
      },
    );
  }
}
