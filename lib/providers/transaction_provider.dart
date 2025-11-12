import 'package:flutter/foundation.dart';
import '../models/transaction.dart';

/// Provider untuk mengelola state transaksi menggunakan ChangeNotifier
class TransactionProvider extends ChangeNotifier {
  // List untuk menyimpan semua transaksi (in-memory)
  final List<Transaction> _transactions = [];

  // Getter untuk mendapatkan semua transaksi
  List<Transaction> get transactions => List.unmodifiable(_transactions);

  /// Konstruktor dengan data dummy untuk testing
  TransactionProvider() {
    _loadDummyData();
  }

  /// Load data dummy untuk melihat tampilan UI
  void _loadDummyData() {
    final now = DateTime.now();
    _transactions.addAll([
      Transaction(
        id: '1',
        title: 'Gaji Bulanan',
        amount: 8000000,
        type: TransactionType.income,
        category: TransactionCategory.salary,
        date: DateTime(now.year, now.month, 1),
      ),
      Transaction(
        id: '2',
        title: 'Makan Siang',
        amount: 45000,
        type: TransactionType.expense,
        category: TransactionCategory.food,
        date: now.subtract(const Duration(hours: 2)),
      ),
      Transaction(
        id: '3',
        title: 'Grab ke Kantor',
        amount: 25000,
        type: TransactionType.expense,
        category: TransactionCategory.transport,
        date: now.subtract(const Duration(days: 1)),
      ),
      Transaction(
        id: '4',
        title: 'Belanja Bulanan',
        amount: 500000,
        type: TransactionType.expense,
        category: TransactionCategory.shopping,
        date: now.subtract(const Duration(days: 3)),
      ),
      Transaction(
        id: '5',
        title: 'Netflix Subscription',
        amount: 186000,
        type: TransactionType.expense,
        category: TransactionCategory.entertainment,
        date: now.subtract(const Duration(days: 5)),
      ),
      Transaction(
        id: '6',
        title: 'Listrik',
        amount: 350000,
        type: TransactionType.expense,
        category: TransactionCategory.bills,
        date: now.subtract(const Duration(days: 7)),
      ),
      Transaction(
        id: '7',
        title: 'Freelance Project',
        amount: 2500000,
        type: TransactionType.income,
        category: TransactionCategory.investment,
        date: now.subtract(const Duration(days: 10)),
      ),
      Transaction(
        id: '8',
        title: 'Kopi & Snack',
        amount: 75000,
        type: TransactionType.expense,
        category: TransactionCategory.food,
        date: now.subtract(const Duration(days: 1)),
      ),
      Transaction(
        id: '9',
        title: 'Bensin Motor',
        amount: 50000,
        type: TransactionType.expense,
        category: TransactionCategory.transport,
        date: now.subtract(const Duration(hours: 5)),
      ),
      Transaction(
        id: '10',
        title: 'Belanja Online',
        amount: 350000,
        type: TransactionType.expense,
        category: TransactionCategory.shopping,
        date: now.subtract(const Duration(days: 2)),
      ),
      Transaction(
        id: '11',
        title: 'Bioskop',
        amount: 120000,
        type: TransactionType.expense,
        category: TransactionCategory.entertainment,
        date: now.subtract(const Duration(days: 6)),
      ),
      Transaction(
        id: '12',
        title: 'Internet',
        amount: 300000,
        type: TransactionType.expense,
        category: TransactionCategory.bills,
        date: now.subtract(const Duration(days: 8)),
      ),
    ]);
  }

  /// Menambah transaksi baru
  void addTransaction(Transaction transaction) {
    _transactions.insert(0, transaction); // Insert di awal list
    notifyListeners(); // Notify UI untuk update
  }

  /// Menghapus transaksi berdasarkan ID
  void deleteTransaction(String id) {
    _transactions.removeWhere((tx) => tx.id == id);
    notifyListeners();
  }

  /// Mendapatkan total saldo
  double get totalBalance {
    double balance = 0;
    for (var tx in _transactions) {
      if (tx.type == TransactionType.income) {
        balance += tx.amount;
      } else {
        balance -= tx.amount;
      }
    }
    return balance;
  }

  /// Mendapatkan total pemasukan hari ini
  double get todayIncome {
    final today = DateTime.now();
    return _transactions
        .where((tx) =>
            tx.type == TransactionType.income &&
            tx.date.year == today.year &&
            tx.date.month == today.month &&
            tx.date.day == today.day)
        .fold(0, (sum, tx) => sum + tx.amount);
  }

  /// Mendapatkan total pengeluaran hari ini
  double get todayExpense {
    final today = DateTime.now();
    return _transactions
        .where((tx) =>
            tx.type == TransactionType.expense &&
            tx.date.year == today.year &&
            tx.date.month == today.month &&
            tx.date.day == today.day)
        .fold(0, (sum, tx) => sum + tx.amount);
  }

  /// Mendapatkan 10 transaksi terbaru
  List<Transaction> get recentTransactions {
    final sorted = List<Transaction>.from(_transactions)
      ..sort((a, b) => b.date.compareTo(a.date));
    return sorted.take(10).toList();
  }

  /// Filter transaksi berdasarkan tipe
  List<Transaction> getTransactionsByType(TransactionType? type) {
    if (type == null) return transactions;
    return _transactions.where((tx) => tx.type == type).toList();
  }

  /// Mendapatkan transaksi berdasarkan bulan dan tahun
  List<Transaction> getTransactionsByMonth(int month, int year) {
    return _transactions
        .where((tx) => tx.date.month == month && tx.date.year == year)
        .toList();
  }

  /// Mendapatkan total pemasukan per bulan
  double getMonthlyIncome(int month, int year) {
    return getTransactionsByMonth(month, year)
        .where((tx) => tx.type == TransactionType.income)
        .fold(0, (sum, tx) => sum + tx.amount);
  }

  /// Mendapatkan total pengeluaran per bulan
  double getMonthlyExpense(int month, int year) {
    return getTransactionsByMonth(month, year)
        .where((tx) => tx.type == TransactionType.expense)
        .fold(0, (sum, tx) => sum + tx.amount);
  }

  /// Mendapatkan breakdown per kategori untuk bulan tertentu
  Map<TransactionCategory, double> getCategoryBreakdown(int month, int year) {
    final monthlyTransactions = getTransactionsByMonth(month, year);
    final Map<TransactionCategory, double> breakdown = {};

    for (var tx in monthlyTransactions) {
      if (tx.type == TransactionType.expense) {
        breakdown[tx.category] = (breakdown[tx.category] ?? 0) + tx.amount;
      }
    }

    return breakdown;
  }

  /// Mendapatkan data untuk sparkline chart (7 hari terakhir)
  List<double> getWeeklyExpenseData() {
    final now = DateTime.now();
    final List<double> data = [];

    for (int i = 6; i >= 0; i--) {
      final day = now.subtract(Duration(days: i));
      final dayExpense = _transactions
          .where((tx) =>
              tx.type == TransactionType.expense &&
              tx.date.year == day.year &&
              tx.date.month == day.month &&
              tx.date.day == day.day)
          .fold(0.0, (sum, tx) => sum + tx.amount);
      data.add(dayExpense);
    }

    return data;
  }

  /// Mendapatkan data income untuk sparkline chart (7 hari terakhir)
  List<double> getWeeklyIncomeData() {
    final now = DateTime.now();
    final List<double> data = [];

    for (int i = 6; i >= 0; i--) {
      final day = now.subtract(Duration(days: i));
      final dayIncome = _transactions
          .where((tx) =>
              tx.type == TransactionType.income &&
              tx.date.year == day.year &&
              tx.date.month == day.month &&
              tx.date.day == day.day)
          .fold(0.0, (sum, tx) => sum + tx.amount);
      data.add(dayIncome);
    }

    return data;
  }

  /// Update existing transaction
  void updateTransaction(Transaction updatedTransaction) {
    final index = _transactions.indexWhere((tx) => tx.id == updatedTransaction.id);
    if (index != -1) {
      _transactions[index] = updatedTransaction;
      notifyListeners();
    }
  }
}