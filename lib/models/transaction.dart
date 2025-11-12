/// Model untuk menyimpan data transaksi keuangan
class Transaction {
  final String id;
  final String title; // Nama transaksi
  final double amount; // Nominal
  final TransactionType type; // Pemasukan atau Pengeluaran
  final TransactionCategory category; // Kategori
  final DateTime date; // Tanggal transaksi
  final String? note; // Catatan opsional

  Transaction({
    required this.id,
    required this.title,
    required this.amount,
    required this.type,
    required this.category,
    required this.date,
    this.note,
  });

  /// Copy with method untuk memudahkan update
  Transaction copyWith({
    String? id,
    String? title,
    double? amount,
    TransactionType? type,
    TransactionCategory? category,
    DateTime? date,
    String? note,
  }) {
    return Transaction(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      category: category ?? this.category,
      date: date ?? this.date,
      note: note ?? this.note,
    );
  }
}

/// Enum untuk tipe transaksi
enum TransactionType {
  income, // Pemasukan
  expense, // Pengeluaran
}

/// Enum untuk kategori transaksi
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

/// Extension untuk mendapatkan label kategori
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