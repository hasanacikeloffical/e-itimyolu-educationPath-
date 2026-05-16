import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:email_validator/email_validator.dart';

import 'email_verification_page.dart';
import 'package:education_path/UserUI/Controller/AuthController/AuthController.dart';

class AuthRegisterPage extends StatefulWidget {
  const AuthRegisterPage({super.key});

  @override
  State<AuthRegisterPage> createState() => _AuthRegisterPageState();
}

class _AuthRegisterPageState extends State<AuthRegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _authService = AuthController.instance;

  final firstCtrl = TextEditingController();
  final lastCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  final confirmCtrl = TextEditingController();

  bool busy = false;
  bool obscure = true;

  @override
  void dispose() {
    firstCtrl.dispose();
    lastCtrl.dispose();
    emailCtrl.dispose();
    phoneCtrl.dispose();
    passCtrl.dispose();
    confirmCtrl.dispose();
    super.dispose();
  }

  void showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
      ),
    );
  }

  Future<void> register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => busy = true);

    try {
      await _authService.register(
        firstName: firstCtrl.text.trim(),
        lastName: lastCtrl.text.trim(),
        email: emailCtrl.text.trim(),
        phone: phoneCtrl.text.trim(),
        university: '',
        department: '',
        education: '',
        password: passCtrl.text.trim(),
      );

      if (!mounted) return;

      showSnack(
        "Doğrulama maili gönderildi.",
      );

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => EmailVerificationPage(
            email: emailCtrl.text.trim(),
          ),
        ),
        (route) => false,
      );
    } on FirebaseAuthException catch (e) {
      showSnack(_authService.mapError(e));
    } catch (e) {
      showSnack("Hata oluştu: $e");
    }

    if (mounted) {
      setState(() => busy = false);
    }
  }

  Widget modernField({
    required TextEditingController controller,
    required String label,
    bool obscureText = false,
    TextInputType? keyboardType,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest.withOpacity(.35),
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
        suffixIcon: suffixIcon,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: colorScheme.onSurface,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 10,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                Text(
                  "Hesap Oluştur ✨",
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "Yeni hesabını oluştur ve eğitim dünyasına katıl.",
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurface.withOpacity(.7),
                  ),
                ),
                const SizedBox(height: 35),
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
                      Row(
                        children: [
                          Expanded(
                            child: modernField(
                              controller: firstCtrl,
                              label: "Ad",
                              validator: (v) {
                                if (v == null || v.isEmpty) {
                                  return "Ad zorunludur.";
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: modernField(
                              controller: lastCtrl,
                              label: "Soyad",
                              validator: (v) {
                                if (v == null || v.isEmpty) {
                                  return "Soyad zorunludur.";
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      modernField(
                        controller: emailCtrl,
                        label: "E-posta",
                        keyboardType: TextInputType.emailAddress,
                        validator: (v) {
                          final value = v?.trim().toLowerCase() ?? '';

                          if (value.isEmpty) {
                            return "E-posta zorunludur.";
                          }

                          if (!EmailValidator.validate(value)) {
                            return "Geçerli e-posta girin.";
                          }

                          return null;
                        },
                      ),
                      const SizedBox(height: 18),
                      modernField(
                        controller: phoneCtrl,
                        label: "Telefon",
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 18),
                      modernField(
                        controller: passCtrl,
                        label: "Şifre",
                        obscureText: obscure,
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
                        validator: (v) {
                          if (v == null || v.length < 6) {
                            return "Şifre en az 6 karakter olmalı.";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 18),
                      modernField(
                        controller: confirmCtrl,
                        label: "Şifre Tekrar",
                        obscureText: obscure,
                        validator: (v) {
                          if (v != passCtrl.text) {
                            return "Şifreler uyuşmuyor.";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 28),
                      SizedBox(
                        width: double.infinity,
                        height: 58,
                        child: FilledButton(
                          onPressed: busy ? null : register,
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
                                  "Kayıt Ol",
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
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          style: OutlinedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                            side: BorderSide(
                              color: colorScheme.outlineVariant,
                            ),
                          ),
                          child: const Text(
                            "Giriş Yap",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
