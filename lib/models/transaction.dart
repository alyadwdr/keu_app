import 'package:cloud_firestore/cloud_firestore.dart';

class TransactionModel {
  final String id;
  final String title;
  final double amount;
  final TransactionType type;
  final TransactionCategory category;
  final DateTime date;
  final String? note;

  TransactionModel({
    required this.id,
    required this.title,
    required this.amount,
    required this.type,
    required this.category,
    required this.date,
    this.note,
  });

  TransactionModel copyWith({
    String? id,
    String? title,
    double? amount,
    TransactionType? type,
    TransactionCategory? category,
    DateTime? date,
    String? note,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      category: category ?? this.category,
      date: date ?? this.date,
      note: note ?? this.note,
    );
  }

  // Convert to Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'amount': amount,
      'type': type.name,
      'category': category.name,
      'date': Timestamp.fromDate(date),
      'note': note,
    };
  }

  // Convert from Firestore
  factory TransactionModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TransactionModel(
      id: doc.id,
      title: data['title'] ?? '',
      amount: (data['amount'] ?? 0).toDouble(),
      type: TransactionType.values.firstWhere(
        (e) => e.name == data['type'],
        orElse: () => TransactionType.expense,
      ),
      category: TransactionCategory.values.firstWhere(
        (e) => e.name == data['category'],
        orElse: () => TransactionCategory.others,
      ),
      date: (data['date'] as Timestamp).toDate(),
      note: data['note'],
    );
  }
}

enum TransactionType {
  income,
  expense,
}

enum TransactionCategory {
  food,
  transport,
  shopping,
  entertainment,
  bills,
  salary,
  investment,
  others,
}

extension TransactionCategoryExtension on TransactionCategory {
  String get label {
    switch (this) {
      case TransactionCategory.food:
        return 'Makanan';
      case TransactionCategory.transport:
        return 'Transport';
      case TransactionCategory.shopping:
        return 'Belanja';
      case TransactionCategory.entertainment:
        return 'Hiburan';
      case TransactionCategory.bills:
        return 'Tagihan';
      case TransactionCategory.salary:
        return 'Gaji';
      case TransactionCategory.investment:
        return 'Investasi';
      case TransactionCategory.others:
        return 'Lainnya';
    }
  }

  String get icon {
    switch (this) {
      case TransactionCategory.food:
        return '🍽️';
      case TransactionCategory.transport:
        return '🚗';
      case TransactionCategory.shopping:
        return '🛍️';
      case TransactionCategory.entertainment:
        return '🎬';
      case TransactionCategory.bills:
        return '📄';
      case TransactionCategory.salary:
        return '💰';
      case TransactionCategory.investment:
        return '📈';
      case TransactionCategory.others:
        return '📦';
    }
  }
}