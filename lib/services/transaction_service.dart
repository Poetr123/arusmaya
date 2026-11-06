import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/transaction_model.dart';

class TransactionService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>> get _transactions {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('Pengguna belum login.');
    }

    return _db.collection('users').doc(user.uid).collection('transactions');
  }

  // READ: Real-time transaction stream
  Stream<List<TransactionModel>> getTransactions() {
    return _transactions.orderBy('date', descending: true).snapshots().map((
      snapshot,
    ) {
      return snapshot.docs.map(TransactionModel.fromFirestore).toList();
    });
  }

  // CREATE
  Future<void> addTransaction({
    required String title,
    required double amount,
    required String type,
    required String note,
    required DateTime date,
  }) async {
    if (amount <= 0) {
      throw Exception('Nominal harus lebih besar dari nol.');
    }

    await _transactions.add({
      'title': title.trim(),
      'amount': amount,
      'type': type,
      'note': note.trim(),
      'date': Timestamp.fromDate(date),
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // UPDATE
  Future<void> updateTransaction(TransactionModel transaction) async {
    await _transactions.doc(transaction.id).update(transaction.toUpdateMap());
  }

  // DELETE
  Future<void> deleteTransaction(String id) async {
    await _transactions.doc(id).delete();
  }

  // READ: Single transaction
  Future<TransactionModel?> getTransaction(String id) async {
    final doc = await _transactions.doc(id).get();

    if (!doc.exists) return null;

    return TransactionModel.fromFirestore(doc);
  }
}
