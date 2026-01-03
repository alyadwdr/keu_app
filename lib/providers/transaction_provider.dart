import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/transaction.dart';

class TransactionProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<TransactionModel> _transactions = [];
  bool _isLoading = false;

  List<TransactionModel> get transactions => List.unmodifiable(_transactions);
  bool get isLoading => _isLoading;

  TransactionProvider() {
    _loadTransactions();
  }

  // Load semua transaksi dari Firestore
  Future<void> _loadTransactions() async {
    _isLoading = true;
    notifyListeners();

    try {
      final snapshot = await _firestore
          .collection('transactions')
          .orderBy('date', descending: true)
          .get();

      _transactions = snapshot.docs
          .map((doc) => TransactionModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      debugPrint('Error loading transactions: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Tambah transaksi baru
  Future<void> addTransaction(TransactionModel transaction) async {
    try {
      await _firestore.collection('transactions').add(transaction.toFirestore());
      await _loadTransactions();
    } catch (e) {
      debugPrint('Error adding transaction: $e');
    }
  }

  // Update transaksi
  Future<void> updateTransaction(TransactionModel transaction) async {
    try {
      await _firestore
          .collection('transactions')
          .doc(transaction.id)
          .update(transaction.toFirestore());
      await _loadTransactions();
    } catch (e) {
      debugPrint('Error updating transaction: $e');
    }
  }

  // Hapus transaksi
  Future<void> deleteTransaction(String id) async {
    try {
      await _firestore.collection('transactions').doc(id).delete();
      await _loadTransactions();
    } catch (e) {
      debugPrint('Error deleting transaction: $e');
    }
  }

  // Total saldo
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

  // Total pemasukan hari ini
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

  // Total pengeluaran hari ini
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

  // 10 transaksi terbaru
  List<TransactionModel> get recentTransactions {
    final sorted = List<TransactionModel>.from(_transactions)
      ..sort((a, b) => b.date.compareTo(a.date));
    return sorted.take(10).toList();
  }

  // Filter berdasarkan tipe
  List<TransactionModel> getTransactionsByType(TransactionType? type) {
    if (type == null) return transactions;
    return _transactions.where((tx) => tx.type == type).toList();
  }

  // Filter berdasarkan bulan dan tahun
  List<TransactionModel> getTransactionsByMonth(int month, int year) {
    return _transactions
        .where((tx) => tx.date.month == month && tx.date.year == year)
        .toList();
  }

  // Total pemasukan per bulan
  double getMonthlyIncome(int month, int year) {
    return getTransactionsByMonth(month, year)
        .where((tx) => tx.type == TransactionType.income)
        .fold(0, (sum, tx) => sum + tx.amount);
  }

  // Total pengeluaran per bulan
  double getMonthlyExpense(int month, int year) {
    return getTransactionsByMonth(month, year)
        .where((tx) => tx.type == TransactionType.expense)
        .fold(0, (sum, tx) => sum + tx.amount);
  }

  // Breakdown per kategori
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

  // Data expense 7 hari terakhir
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

  // Data income 7 hari terakhir
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

  // Refresh data
  Future<void> refreshTransactions() async {
    await _loadTransactions();
  }
}