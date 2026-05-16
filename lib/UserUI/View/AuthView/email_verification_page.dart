import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:education_path/UserUI/Controller/AuthController/AuthController.dart';
import 'auth_page.dart';

class EmailVerificationPage extends StatefulWidget {
  final String email;

  const EmailVerificationPage({super.key, required this.email});

  @override
  State<EmailVerificationPage> createState() => _EmailVerificationPageState();
}

class _EmailVerificationPageState extends State<EmailVerificationPage> {
  final _auth = FirebaseAuth.instance;

  bool _sending = false;
  int _remainingSeconds = 60;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  void _startCountdown() async {
    setState(() => _remainingSeconds = 60);

    while (_remainingSeconds > 0 && mounted) {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return;

      setState(() {
        _remainingSeconds--;
      });
    }
  }

  Future<void> _resendEmail() async {
    if (_sending || _remainingSeconds > 0) return;

    setState(() => _sending = true);

    try {
      await _auth.currentUser?.reload();

      await _auth.currentUser?.sendEmailVerification();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Doğrulama e-postası tekrar gönderildi.'),
          backgroundColor: Colors.green,
        ),
      );

      _startCountdown();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Hata: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  Future<void> _onVerificationDone() async {
    await FirebaseAuth.instance.currentUser?.reload();

    await FirebaseAuth.instance.authStateChanges().first;

    final user = FirebaseAuth.instance.currentUser;

    if (user != null && user.emailVerified) {
      await AuthController.instance.markEmailVerified();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("E-posta başarıyla doğrulandı!")),
      );

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const AuthLoginPage()),
        (_) => false,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('E-posta henüz doğrulanmadı.')),
      );
    }
  }

  Future<void> _cancelRegistration() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Kaydı iptal et'),
        content: const Text(
          'Kayıt işleminden çıkmak istiyor musunuz?\n'
          'Bilgileriniz silinmeyecek, sadece işlemi durduracaksınız.',
        ),
        actions: [
          TextButton(
            child: const Text('Hayır'),
            onPressed: () => Navigator.pop(context, false),
          ),
          TextButton(
            child: const Text('Evet, çık'),
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );

    if (result == true) {
      await _auth.signOut();
      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const AuthLoginPage()),
        (_) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('E-posta doğrulama'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: _cancelRegistration,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                const Icon(
                  Icons.mark_email_unread,
                  size: 100,
                  color: Colors.blue,
                ),
                const SizedBox(height: 32),

                Text(
                  'Doğrulama e-postası gönderildi!',
                  style: Theme.of(context).textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 8),

                Text(
                  widget.email,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 24),

                const Text(
                  'E-postadaki bağlantıya tıklayın.\n'
                  'Doğruladıktan sonra giriş yapabilirsiniz.',
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 40),

                ElevatedButton.icon(
                  onPressed: _onVerificationDone,
                  icon: const Icon(Icons.check_circle_outline),
                  label: const Text('Doğrulamayı Tamamladım'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                  ),
                ),

                const SizedBox(height: 24),

                ElevatedButton.icon(
                  onPressed: (_remainingSeconds == 0 && !_sending)
                      ? _resendEmail
                      : null,
                  icon: _sending
                      ? const CircularProgressIndicator(strokeWidth: 2)
                      : const Icon(Icons.refresh),
                  label: Text(
                    _remainingSeconds > 0
                        ? "Tekrar gönder ($_remainingSeconds)"
                        : "E-postayı tekrar gönder",
                  ),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    backgroundColor: Colors.blueGrey,
                  ),
                ),

                const SizedBox(height: 32),

                TextButton(
                  onPressed: _cancelRegistration,
                  child: const Text(
                    'Kaydı iptal et',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
