import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  CollectionReference<Map<String, dynamic>> get _users =>
      _db.collection('users');

  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    final user = credential.user;

    if (user == null) {
      throw Exception('Gagal membuat akun.');
    }

    await user.updateDisplayName(name.trim());

    await _users.doc(user.uid).set({
      'uid': user.uid,
      'name': name.trim(),
      'email': email.trim(),
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> login({required String email, required String password}) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    final user = credential.user;

    if (user != null) {
      await ensureUserProfile(user);
    }
  }

  Future<void> ensureUserProfile(User user) async {
    final userRef = _users.doc(user.uid);
    final snapshot = await userRef.get();

    if (!snapshot.exists) {
      await userRef.set({
        'uid': user.uid,
        'name': user.displayName ?? 'Pengguna ArusMaya',
        'email': user.email ?? '',
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> getUserProfile() async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('Pengguna belum login.');
    }

    return _users.doc(user.uid).get();
  }

  Future<void> logout() async {
    await _auth.signOut();
  }
}
