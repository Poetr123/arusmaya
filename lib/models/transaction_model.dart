import 'package:cloud_firestore/cloud_firestore.dart';

class TransactionModel {
  final String id;
  final String title;
  final double amount;
  final String type;
  final String note;
  final DateTime date;
  final DateTime? createdAt;

  const TransactionModel({
    required this.id,
    required this.title,
    required this.amount,
    required this.type,
    required this.note,
    required this.date,
    this.createdAt,
  });

  bool get isIncome => type == 'income';

  factory TransactionModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};

    return TransactionModel(
      id: doc.id,
      title: data['title'] ?? '',
      amount: (data['amount'] as num?)?.toDouble() ?? 0,
      type: data['type'] ?? 'expense',
      note: data['note'] ?? '',
      date: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'amount': amount,
      'type': type,
      'note': note,
      'date': Timestamp.fromDate(date),
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  Map<String, dynamic> toUpdateMap() {
    return {
      'title': title,
      'amount': amount,
      'type': type,
      'note': note,
      'date': Timestamp.fromDate(date),
    };
  }
}
