import 'package:education_path/UserUI/View/AuthView/auth_register.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'password_reset_page.dart';
import 'package:education_path/UserUI/Controller/LayoutController.dart';
import 'package:education_path/UserUI/Controller/AuthController/AuthController.dart';
import 'package:email_validator/email_validator.dart';
import 'email_verification_page.dart';

class AuthEntry extends StatelessWidget {
  const AuthEntry({super.key});

  @override
  Widget build(BuildContext context) {
    return const AuthLoginPage();
  }
}

class AuthLoginPage extends StatefulWidget {
  const AuthLoginPage({super.key});

  @override
  State<AuthLoginPage> createState() => _AuthLoginPageState();
}

class _AuthLoginPageState extends State<AuthLoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _authService = AuthController.instance;

  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  final passFocus = FocusNode();

  bool busy = false;
  bool obscure = true;

  @override
  void dispose() {
    emailCtrl.dispose();
    passCtrl.dispose();
    passFocus.dispose();
    super.dispose();
  }

  void showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  Future<void> onSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => busy = true);

    try {
      await _authService.signIn(
        emailCtrl.text.trim(),
        passCtrl.text.trim(),
      );

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const MainPage(),
        ),
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        showSnack("E-posta veya şifre hatalı.");
      } else if (e.code == 'wrong-password') {
        showSnack("E-posta veya şifre hatalı.");
      } else if (e.code == 'email-not-verified') {
        showSnack(
            "E-posta adresiniz doğrulanmamış. Doğrulama sayfasına yönlendiriliyorsunuz.");

        await Future.delayed(const Duration(seconds: 2));
        if (!mounted) return;

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => EmailVerificationPage(
              email: emailCtrl.text.trim(),
            ),
          ),
        );
      } else {
        showSnack(_authService.mapError(e));
      }
    } catch (e) {
      showSnack("Bir hata oluştu: $e");
    }

    if (mounted) {
      setState(() => busy = false);
    }
  }

  Future<void> continueAsGuest() async {
    try {
      setState(() => busy = true);

      await FirebaseAuth.instance.signInAnonymously();

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const MainPage(),
        ),
      );
    } catch (e) {
      showSnack("Misafir girişi başarısız: $e");
    }

    if (mounted) {
      setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: AbsorbPointer(
          absorbing: busy,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 32,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 40),
                  Text(
                    "Tekrar Hoş Geldin 👋",
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Devam etmek için hesabına giriş yap.",
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: colorScheme.onSurface.withOpacity(.7),
                    ),
                  ),
                  const SizedBox(height: 40),
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: colorScheme.outlineVariant.withOpacity(.35),
                      ),
                      boxShadow: [
                        BoxShadow(
                          blurRadius: isDark ? 10 : 18,
                          spreadRadius: 1,
                          offset: const Offset(0, 8),
                          color: isDark
                              ? Colors.black.withOpacity(.25)
                              : Colors.black.withOpacity(.05),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        TextFormField(
                          controller: emailCtrl,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            labelText: "E-posta Adresi",
                            filled: true,
                            fillColor: colorScheme.surfaceContainerHighest
                                .withOpacity(.4),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(18),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(18),
                              borderSide: BorderSide(
                                color: colorScheme.primary,
                                width: 1.5,
                              ),
                            ),
                          ),
                          validator: (v) {
                            final value = v?.trim().toLowerCase() ?? '';

                            if (value.isEmpty) {
                              return 'E-posta adresi zorunludur.';
                            }

                            if (!EmailValidator.validate(value)) {
                              return 'Geçerli bir e-posta adresi girin.';
                            }

                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: passCtrl,
                          focusNode: passFocus,
                          obscureText: obscure,
                          decoration: InputDecoration(
                            labelText: "Şifre",
                            filled: true,
                            fillColor: colorScheme.surfaceContainerHighest
                                .withOpacity(.4),
                            suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  obscure = !obscure;
                                });
                              },
                              icon: Icon(
                                obscure
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                              ),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(18),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(18),
                              borderSide: BorderSide(
                                color: colorScheme.primary,
                                width: 1.5,
                              ),
                            ),
                          ),
                          validator: (v) {
                            if (v == null || v.isEmpty) {
                              return 'Şifre zorunludur.';
                            }

                            if (v.length < 6) {
                              return 'Şifre en az 6 karakter olmalıdır.';
                            }

                            return null;
                          },
                        ),
                        const SizedBox(height: 10),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const PasswordResetPage(),
                                ),
                              );
                            },
                            child: const Text(
                              "Şifremi Unuttum",
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          height: 58,
                          child: FilledButton(
                            onPressed: busy ? null : onSubmit,
                            style: FilledButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                            ),
                            child: busy
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text(
                                    "Giriş Yap",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          height: 58,
                          child: OutlinedButton(
                            onPressed: busy ? null : continueAsGuest,
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(
                                color: colorScheme.outlineVariant,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                            ),
                            child: const Text(
                              "Misafir Olarak Devam Et",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Hesabın yok mu?",
                        style: TextStyle(
                          color: colorScheme.onSurface.withOpacity(.7),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const AuthRegisterPage(),
                            ),
                          );
                        },
                        child: const Text(
                          "Kayıt Ol",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
