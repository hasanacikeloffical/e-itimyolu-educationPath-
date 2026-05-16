import 'package:cloud_firestore/cloud_firestore.dart';


class ValidationResult {
  final bool isValid;
  final String message;
  ValidationResult._(this.isValid, this.message);

  factory ValidationResult.valid(String msg) => ValidationResult._(true, msg);
  factory ValidationResult.invalid(String msg) =>
      ValidationResult._(false, msg);
}


class EmailValidationService {
  final _firestore = FirebaseFirestore.instance;


  static const List<String> _domains = [
    'metu.edu.tr',
    'itu.edu.tr',
    'boun.edu.tr',
    'omu.edu.tr',
    'ege.edu.tr',
    'mersin.edu.tr',
    'cukurova.edu.tr',
    'bilkent.edu.tr',
    'koc.edu.tr',
    'sabanci.edu.tr',
    'ktu.edu.tr',
    'yildiz.edu.tr',
    'istanbul.edu.tr',
    'hacettepe.edu.tr',
    'ankara.edu.tr',
    'gazi.edu.tr',
    'akdeniz.edu.tr',
    'uludag.edu.tr',
    'atauni.edu.tr',
    'cumhuriyet.edu.tr',
    'anadolu.edu.tr',
    'erciyes.edu.tr',
    'selcuk.edu.tr',
    'kocaeli.edu.tr',
    'gtu.edu.tr',
    'firat.edu.tr',
    'bilgi.edu.tr',
    'bahcesehir.edu.tr',
    'yeditepe.edu.tr',
    'kadir-has.edu.tr',
    'ozyegin.edu.tr',
    'atilim.edu.tr',
    'tobb.edu.tr',
    'yasar.edu.tr',
    'deu.edu.tr',
    'marmara.edu.tr',
    'sakarya.edu.tr',
    'sdu.edu.tr',
    'pau.edu.tr',
    'maltepe.edu.tr',
  ];

  String normalize(String email) => email.trim().toLowerCase();

  
  bool _validateDomain(String email) {
    final normalized = normalize(email);

    final parts = normalized.split('@');
    if (parts.length != 2) return false;

    final domain = parts[1];

 
    return domain.endsWith('.edu.tr');
  }

 
  String? extractDomain(String email) {
    final normalized = normalize(email);

    final parts = normalized.split('@');
    if (parts.length != 2) return null;

    return parts[1];
  }

  
  ValidationResult validateStudentEmail(String email) {
    final normalized = normalize(email);

    if (normalized.isEmpty) {
      return ValidationResult.invalid('E-posta zorunludur.');
    }
  
    if (!_validateDomain(normalized)) {
      return ValidationResult.invalid(
        'Sadece .edu.tr uzantılı e-postalar kabul edilir.',
      );
    }

    return ValidationResult.valid('Geçerli e-posta.');
  }

 
  Future<bool> isEmailAlreadyRegistered(String email) async {
    try {
      final normalized = normalize(email);
      final query = await _firestore
          .collection('users')
          .where('email', isEqualTo: normalized)
          .limit(1)
          .get();
      return query.docs.isNotEmpty;
    } catch (e) {
      print('[EmailValidation] Firestore error: $e');
      return false;
    }
  }

  List<String> getSupportedDomains() => List.unmodifiable(_domains);
}
