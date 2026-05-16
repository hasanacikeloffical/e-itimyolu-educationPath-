import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_validator/email_validator.dart';
import 'package:education_path/UserUI/Controller/AuthController/AuthController.dart';

class HackatlonApplicationViewComponent extends StatefulWidget {
  const HackatlonApplicationViewComponent({Key? key}) : super(key: key);

  @override
  State<HackatlonApplicationViewComponent> createState() =>
      _HackathonApplicationPageState();
}

class _HackathonApplicationPageState
    extends State<HackatlonApplicationViewComponent> {
  final formKey = GlobalKey<FormState>();
  final FirebaseFirestore db = FirebaseFirestore.instance;
  final AuthController authController = AuthController.instance;

  bool isLoading = true;
  bool hasApplication = false;
  bool isSubmitting = false;

  int? teamSize;
  String? region;

  final teamNameCtrl = TextEditingController();
  final List<TextEditingController> nameControllers = [];
  final List<TextEditingController> emailControllers = [];
  final List<TextEditingController> phoneControllers = [];
  final List<TextEditingController> universityControllers = [];
  final List<TextEditingController> departmentControllers = [];
  final List<TextEditingController> linkedinControllers = [];

  final List<String> regionList = [
    "Marmara",
    "Ege",
    "İç Anadolu",
    "Akdeniz",
    "Karadeniz",
    "Doğu Anadolu",
    "Güneydoğu Anadolu"
  ];

  @override
  void initState() {
    super.initState();
    _initializePage();
  }

  @override
  void dispose() {
    teamNameCtrl.dispose();
    for (var c in nameControllers) {
      c.dispose();
    }
    for (var c in emailControllers) {
      c.dispose();
    }
    for (var c in phoneControllers) {
      c.dispose();
    }
    for (var c in universityControllers) {
      c.dispose();
    }
    for (var c in departmentControllers) {
      c.dispose();
    }
    for (var c in linkedinControllers) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _initializePage() async {
    final user = authController.currentUser;
    if (user == null || user.isAnonymous) {
      if (mounted) setState(() => isLoading = false);
      return;
    }

    try {
      final appSnap =
          await db.collection("hackathon_applications").doc(user.uid).get();

      if (appSnap.exists) {
        hasApplication = true;
        final data = appSnap.data()!;
        _populateFormFromData(data);
      }
    } catch (e) {
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  void _populateFormFromData(Map<String, dynamic> data) {
    teamNameCtrl.text = data["teamName"] ?? '';
    region = data["region"];
    teamSize = data["teamSize"];

    if (teamSize != null) {
      _initControllers(teamSize!);
      final members = List<Map<String, dynamic>>.from(data["members"] ?? []);
      for (int i = 0; i < members.length && i < teamSize!; i++) {
        nameControllers[i].text = members[i]["name"] ?? '';
        emailControllers[i].text = members[i]["email"] ?? '';
        if (teamSize == 2 || teamSize == 4) {
          phoneControllers[i].text = members[i]["phone"] ?? '';
          universityControllers[i].text = members[i]["university"] ?? '';
          departmentControllers[i].text = members[i]["department"] ?? '';
          linkedinControllers[i].text = members[i]["linkedin"] ?? '';
        }
      }
    }
  }

  void _initControllers(int size) {
    nameControllers.clear();
    emailControllers.clear();
    nameControllers.addAll(List.generate(size, (_) => TextEditingController()));
    emailControllers
        .addAll(List.generate(size, (_) => TextEditingController()));

    if (size == 2 || size == 4) {
      phoneControllers.clear();
      universityControllers.clear();
      departmentControllers.clear();
      linkedinControllers.clear();
      phoneControllers
          .addAll(List.generate(size, (_) => TextEditingController()));
      universityControllers
          .addAll(List.generate(size, (_) => TextEditingController()));
      departmentControllers
          .addAll(List.generate(size, (_) => TextEditingController()));
      linkedinControllers
          .addAll(List.generate(size, (_) => TextEditingController()));
    }

    final user = authController.currentUser;
    if (user != null) {
      nameControllers[0].text = user.displayName ?? 'Takım Lideri';
      emailControllers[0].text = user.email!;
    }
  }

  Future<void> _submit() async {
    if (isSubmitting || !formKey.currentState!.validate()) return;

    setState(() => isSubmitting = true);

    final user = authController.currentUser;
    if (user == null) return;

    try {
      List<Map<String, dynamic>> members = [];
      for (int i = 0; i < teamSize!; i++) {
        final memberData = {
          "name": nameControllers[i].text.trim(),
          "email": emailControllers[i].text.trim().toLowerCase(),
        };

        if (teamSize == 2 || teamSize == 4) {
          memberData["phone"] = phoneControllers[i].text.trim();
          memberData["university"] = universityControllers[i].text.trim();
          memberData["department"] = departmentControllers[i].text.trim();
          memberData["linkedin"] = linkedinControllers[i].text.trim();
        }
        members.add(memberData);
      }

      await db.collection("hackathon_applications").doc(user.uid).set({
        "teamName": teamNameCtrl.text.trim(),
        "region": region,
        "teamSize": teamSize,
        "members": members,
        "status": "pending",
        "submittedAt": FieldValue.serverTimestamp(),
        "userId": user.uid,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("🚀 Başvurunuz başarıyla alındı!"),
              backgroundColor: Colors.green),
        );
        setState(() => hasApplication = true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text("Bir hata oluştu: ${e.toString()}"),
              backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    if (isLoading) {
      return Scaffold(
          body: Center(child: CircularProgressIndicator(color: cs.primary)));
    }

    if (hasApplication) {
      return _buildAlreadyAppliedScaffold();
    }

    if (teamSize == null) {
      return _buildTeamSelectionScaffold();
    }

    return _buildApplicationFormScaffold();
  }

  Scaffold _buildErrorScaffold(String title, String message, IconData icon) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon,
                  size: 80, color: Theme.of(context).colorScheme.primary),
              const SizedBox(height: 20),
              Text(title,
                  style: Theme.of(context).textTheme.headlineSmall,
                  textAlign: TextAlign.center),
              const SizedBox(height: 12),
              Text(message,
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center),
              const SizedBox(height: 30),
              ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Geri Dön"))
            ],
          ),
        ),
      ),
    );
  }

  Scaffold _buildAlreadyAppliedScaffold() {
    return Scaffold(
      appBar: AppBar(title: const Text("Başvuru Durumu")),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_circle_outline_rounded,
                    size: 80, color: Theme.of(context).colorScheme.primary),
                const SizedBox(height: 20),
                Text("Zaten Bir Başvurun Var!",
                    style: Theme.of(context).textTheme.headlineSmall,
                    textAlign: TextAlign.center),
                const SizedBox(height: 12),
                Text(
                    "Hackathon başvurunuz daha önce alınmıştır. Değerlendirme sonuçları için takipte kalın.",
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center),
                const SizedBox(height: 30),
                ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Anasayfaya Dön"))
              ],
            ),
          ),
        ),
      ),
    );
  }

  Scaffold _buildTeamSelectionScaffold() {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text("1. Adım: Takım Büyüklüğü")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Takımın kaç kişiden oluşacak?",
                style: theme.textTheme.titleLarge),
            const SizedBox(height: 8),
            Text("Kendin dahil toplam kişi sayısını seçmelisin.",
                style: theme.textTheme.bodySmall),
            const SizedBox(height: 20),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [1, 2, 4].map((s) {
                  return Card(
                    elevation: 0,
                    color: cs.surfaceContainerLow,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side:
                          BorderSide(color: cs.outlineVariant.withOpacity(0.5)),
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () {
                        setState(() {
                          teamSize = s;
                          _initControllers(s);
                        });
                      },
                      child: Center(
                          child: Text("$s Kişilik Takım",
                              style: theme.textTheme.titleMedium)),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Scaffold _buildApplicationFormScaffold() {
    return Scaffold(
      appBar: AppBar(
        title: const Text("2. Adım: Başvuru Formu"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => setState(() => teamSize = null),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text("Takım Bilgileri",
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              TextFormField(
                controller: teamNameCtrl,
                decoration: const InputDecoration(
                    labelText: "Takım Adı", border: OutlineInputBorder()),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? "Takım adı zorunludur."
                    : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: region,
                hint: const Text("Bölge Seçin"),
                decoration: const InputDecoration(
                    labelText: "Yarışacağınız Bölge",
                    border: OutlineInputBorder()),
                items: regionList
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (v) => setState(() => region = v),
                validator: (v) => v == null ? "Bölge seçimi zorunludur." : null,
              ),
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 16),
              Text("Takım Üyeleri (${teamSize!} Kişi)",
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              ..._buildMemberFields(),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: isSubmitting ? null : _submit,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
                child: isSubmitting
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 3))
                    : const Text("Başvuruyu Gönder"),
              )
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildMemberFields() {
    return List.generate(teamSize!, (i) {
      final isLeader = i == 0;
      final showExtraFields = teamSize == 2 || teamSize == 4;

      final theme = Theme.of(context);
      final cs = theme.colorScheme;

      return Container(
        margin: const EdgeInsets.only(bottom: 16.0),
        decoration: BoxDecoration(
          color: cs.surfaceContainerLow,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: cs.outlineVariant.withOpacity(0.5)),
        ),
        child: Theme(
          data: theme.copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            key: ValueKey('member_$i'),
            initiallyExpanded: isLeader,
            title: Text("Üye ${i + 1} ${isLeader ? '(Takım Lideri)' : ''}",
                style: theme.textTheme.titleMedium),
            childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            expandedCrossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: nameControllers[i],
                readOnly: isLeader,
                decoration: const InputDecoration(
                    labelText: "Ad Soyad", border: OutlineInputBorder()),
                validator: (v) =>
                  (v == null || v.trim().isEmpty)
                    ? "Üye adı zorunludur."
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: emailControllers[i],
                readOnly: isLeader,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                    labelText: "E-posta Adresi", border: OutlineInputBorder()),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return "E-posta zorunludur.";
                  }
                  if (!EmailValidator.validate(v.trim())) {
                    return "Geçerli bir e-posta adresi girin.";
                  }
                  return null;
                },
              ),
              if (showExtraFields) ...[
                const SizedBox(height: 12),
                TextFormField(
                  controller: phoneControllers[i],
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                      labelText: "Telefon Numarası",
                      border: OutlineInputBorder()),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? "Telefon numarası zorunludur."
                      : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: universityControllers[i],
                  decoration: const InputDecoration(
                      labelText: "Okul", border: OutlineInputBorder()),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? "Okul bilgisi zorunludur."
                      : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: departmentControllers[i],
                  decoration: const InputDecoration(
                      labelText: "Bölüm", border: OutlineInputBorder()),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? "Bölüm bilgisi zorunludur."
                      : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: linkedinControllers[i],
                  keyboardType: TextInputType.url,
                  decoration: const InputDecoration(
                      labelText: "LinkedIn Profil URL",
                      border: OutlineInputBorder()),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? "LinkedIn profili zorunludur."
                      : null,
                ),
              ]
            ],
        ),
        ),
      );
    });
  }
}