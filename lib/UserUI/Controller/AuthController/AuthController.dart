import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'emailValidationController.dart';
import 'package:rxdart/rxdart.dart';
class AuthController {
  AuthController._privateConstructor();
  static final AuthController instance = AuthController._privateConstructor();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  final EmailValidationService _validator = EmailValidationService();

  Stream<User?> get authState => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;

  bool isLoggedIn() => currentUser != null;

  bool isUserAnonymous() => currentUser?.isAnonymous ?? false;

  String _formatName(String text) {
    final parts = text.trim().split(' ');
    return parts
        .where((e) => e.isNotEmpty)
        .map((w) => w[0].toUpperCase() + w.substring(1).toLowerCase())
        .join(' ');
  }

  String _normalizePhone(String phone) {
    phone = phone.trim();
    if (phone.startsWith('+90')) return phone;
    if (phone.startsWith('0')) return '+90${phone.substring(1)}';
    return '+90$phone';
  }

  Future<void> signIn(String email, String password) async {
    try {
      UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      await credential.user?.reload();
      final user = _auth.currentUser;

      if (user == null) {
        throw FirebaseAuthException(
          code: 'user-not-found',
        );
      }

      if (!user.emailVerified) {
        await _auth.signOut();
        throw FirebaseAuthException(
          code: 'email-not-verified',
        );
      }
    } on FirebaseAuthException catch (e) {
      rethrow;
    } catch (e) {
      throw FirebaseAuthException(
        code: 'unknown',
        message: 'Giriş yapılamadı: $e',
      );
    }
  }

  Future<void> signInAnonymously() async {
    try {
      await _auth.signInAnonymously();
    } catch (e) {
      throw Exception("Anonymous sign-in failed: $e");
    }
  }

  Future<void> register({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String university,
    required String department,
    required String education,
    required String password,
    String? address,
    String? gender,
  }) async {
    final mail = email.trim().toLowerCase();

    if (await _validator.isEmailAlreadyRegistered(mail)) {
      throw FirebaseAuthException(
        code: 'email-already-in-use',
        message: 'Bu e-posta zaten kayıtlı.',
      );
    }

    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: mail,
        password: password,
      );

      final uid = cred.user!.uid;
      final fname = _formatName(firstName);
      final lname = _formatName(lastName);
      final fullName = '$fname $lname';
      final isStudent = mail.endsWith('.edu.tr');

      await cred.user!.updateDisplayName(fullName);

      await cred.user!.sendEmailVerification();

      await Future.delayed(const Duration(milliseconds: 400));

      await _db.collection('users').doc(uid).set({
        'uid': uid,
        'firstName': fname,
        'lastName': lname,
        'displayName': fullName,
        'email': mail,
        'phone': _normalizePhone(phone),
        'isStudent': isStudent,
        if (isStudent) 'education': education,
        if (isStudent) 'department': department,
        if (isStudent) 'university': university,
        if (address != null && address.isNotEmpty) 'address': address,
        if (gender != null && gender.isNotEmpty) 'gender': gender,
        'emailVerified': false,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } on FirebaseAuthException {
      rethrow;
    } catch (e) {
      throw FirebaseAuthException(
        code: 'unknown',
        message: 'Kayıt başarısız: $e',
      );
    }
  }

  Future<void> resetPassword(String email) async {
    final mail = email.trim().toLowerCase();
    await _auth.sendPasswordResetEmail(email: mail);
  }

  Future<void> markEmailVerified() async {
    final user = currentUser;
    if (user == null) return;

    await _db.collection('users').doc(user.uid).set(
      {
        'emailVerified': true,
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  Future<Map<String, dynamic>?> getProfile() async {
    final user = currentUser;
    if (user == null) return null;

    final snap = await _db.collection('users').doc(user.uid).get();
    return snap.data();
  }

  Future<Map<String, dynamic>?> getUserProfile() async => getProfile();

  Stream<Map<String, dynamic>?> get userProfileStream {
    return authState.switchMap((user) {
      if (user == null || user.isAnonymous) {
        return Stream.value(null);
      }
      return _db.collection('users').doc(user.uid).snapshots().map((snap) {
        return snap.data();
      });
    });
  }
  FirebaseFirestore get db => _db;

  Stream<List<Map<String, dynamic>>> cartStreamReactive() {
    return _auth.authStateChanges().switchMap((user) {
      if (user == null) {
        return const Stream.empty();
      }

      return _db
          .collection('users')
          .doc(user.uid)
          .collection('cart')
          .snapshots()
          .map((snap) => snap.docs.map((d) {
                final data = d.data();
                return {
                  'id': d.id,
                  'title': data['title'] ?? '',
                  'price': (data['price'] ?? 0).toDouble(),
                  'image': data['image'] ?? '',
                  'quantity': (data['quantity'] ?? 1) as int,
                };
              }).toList());
    });
  }

  Future<void> addToCart(Map<String, dynamic> product) async {
    final user = currentUser;
    if (user == null) throw Exception('Not authenticated');
    final docRef = _db
        .collection('users')
        .doc(user.uid)
        .collection('cart')
        .doc(product['id'].toString());

    final userProfile = await getProfile();
    final isStudent = userProfile?['isStudent'] == true;

    await _db.runTransaction((tx) async {
      final snap = await tx.get(docRef);
      if (snap.exists) {
        if (isStudent) {
          throw Exception(
              'Öğrenci olarak bir üründen sadece 1 adet alabilirsiniz.');
        } else {
          final qty = (snap.data()?['quantity'] ?? 1) as int;
          tx.update(docRef,
              {'quantity': qty + 1, 'updatedAt': FieldValue.serverTimestamp()});
        }
      } else {
        tx.set(docRef, {
          'productId': product['id'].toString(),
          'title': product['title'] ?? '',
          'price': (product['price'] ?? 0).toDouble(),
          'image': product['image'] ?? '',
          'quantity': 1,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    });
  }

  Future<void> increaseCartQty(String productId) async {
    final user = currentUser;
    if (user == null) throw Exception('Not authenticated');
    final docRef =
        _db.collection('users').doc(user.uid).collection('cart').doc(productId);
    await _db.runTransaction((tx) async {
      final snap = await tx.get(docRef);
      if (!snap.exists) return;
      final qty = (snap.data()?['quantity'] ?? 1) as int;
      tx.update(docRef,
          {'quantity': qty + 1, 'updatedAt': FieldValue.serverTimestamp()});
    });
  }

  Future<void> decreaseCartQty(String productId) async {
    final user = currentUser;
    if (user == null) throw Exception('Not authenticated');
    final docRef =
        _db.collection('users').doc(user.uid).collection('cart').doc(productId);
    await _db.runTransaction((tx) async {
      final snap = await tx.get(docRef);
      if (!snap.exists) return;
      final qty = (snap.data()?['quantity'] ?? 1) as int;
      if (qty <= 1) {
        tx.delete(docRef);
      } else {
        tx.update(docRef,
            {'quantity': qty - 1, 'updatedAt': FieldValue.serverTimestamp()});
      }
    });
  }

  Future<void> removeFromCart(String productId) async {
    final user = currentUser;
    if (user == null) throw Exception('Not authenticated');
    final docRef =
        _db.collection('users').doc(user.uid).collection('cart').doc(productId);
    await docRef.delete();
  }

  Future<void> clearCart() async {
    final user = currentUser;
    if (user == null) throw Exception('Not authenticated');
    final cartRef = _db.collection('users').doc(user.uid).collection('cart');
    final snapshot = await cartRef.get();

    final WriteBatch batch = _db.batch();
    for (var doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }

  Future<void> placeOrder({
    required List<Map<String, dynamic>> cartItems,
    required double totalAmount,
    required Map<String, dynamic> addressInfo,
  }) async {
    final user = currentUser;
    if (user == null) throw Exception('Not authenticated');

    final orderRef = _db.collection('orders').doc();

    await orderRef.set({
      'orderId': orderRef.id,
      'userId': user.uid,
      'items': cartItems,
      'totalAmount': totalAmount,
      'address': addressInfo,
      'status': 'Hazırlanıyor',
      'paymentMethod': 'Kapıda Ödeme',
      'createdAt': FieldValue.serverTimestamp(),
    });

    await updateProfile(
      phone: addressInfo['phone'],
      extra: {'address': addressInfo},
    );

    await clearCart();
  }

  Future<void> updateProfile({
    String? firstName,
    String? lastName,
    String? phone,
    String? photoUrl,
    String? bio,
    String? university,
    String? department,
    String? githubUrl,
    String? linkedinUrl,
    Map<String, dynamic>? extra,
  }) async {
    final user = currentUser;
    if (user == null) {
      throw Exception("Kullanıcı bulunamadı.");
    }

    final Map<String, dynamic> data = {
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if (firstName != null && firstName.isNotEmpty) {
      data['firstName'] = _formatName(firstName);
    }
    if (lastName != null && lastName.isNotEmpty) {
      data['lastName'] = _formatName(lastName);
    }
    if (phone != null && phone.isNotEmpty) {
      data['phone'] = _normalizePhone(phone);
    }
    if (photoUrl != null && photoUrl.isNotEmpty) {
      data['photoUrl'] = photoUrl.trim();
    }
    if (bio != null && bio.isNotEmpty) {
      data['bio'] = bio.trim();
    }
    if (university != null && university.isNotEmpty) {
      data['university'] = university.trim();
    }
    if (department != null && department.isNotEmpty) {
      data['department'] = department.trim();
    }
    if (githubUrl != null) {
      data['githubUrl'] = githubUrl.trim();
    }
    if (linkedinUrl != null) {
      data['linkedinUrl'] = linkedinUrl.trim();
    }
    if (extra != null && extra.isNotEmpty) {
      data.addAll(extra);
    }

    await _db.collection('users').doc(user.uid).set(
          data,
          SetOptions(merge: true),
        );

    if (data.containsKey('firstName') || data.containsKey('lastName')) {
      final fname = data['firstName'] ?? '';
      final lname = data['lastName'] ?? '';
      final display = '$fname $lname'.trim();

      if (display.isNotEmpty) {
        await user.updateDisplayName(display);
        await user.reload();
      }
    }
  }

  Future<void> signOut() => _auth.signOut();

  String mapError(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'Bu e-posta adresi zaten kayıtlı.';

      case 'invalid-email':
        return 'Geçerli bir e-posta giriniz.';

      case 'weak-password':
        return 'Şifre en az 6 karakter olmalıdır.';

      case 'wrong-password':
        return 'Şifre hatalı.';

      case 'user-not-found':
        return 'Bu e-posta ile hesap bulunamadı.';

      case 'invalid-email-domain':
        return 'Sadece .edu.tr uzantılı öğrenci e-postası kullanılabilir.';

      case 'email-not-verified':
        return 'Lütfen e-posta adresinizi doğrulayın. Gelen kutunuzu kontrol edin.';

      default:
        return 'Bir hata oluştu. Lütfen tekrar deneyiniz.';
    }
  }
}
