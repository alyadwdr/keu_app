import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/transaction_provider.dart';
import '../models/transaction.dart';
import '../widgets/add_transaction_sheet.dart';
import '../widgets/glass_card.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  TransactionType? _selectedType;
  String _searchQuery = '';
  int _selectedMonth = DateTime.now().month;

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TransactionProvider>(context);
    
    List<TransactionModel> filteredTransactions = provider.getTransactionsByType(_selectedType);
    
    filteredTransactions = filteredTransactions
        .where((tx) => tx.date.month == _selectedMonth)
        .toList();

    if (_searchQuery.isNotEmpty) {
      filteredTransactions = filteredTransactions.where((tx) {
        return tx.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
               tx.category.label.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }

    filteredTransactions = List.from(filteredTransactions)
      ..sort((a, b) => b.date.compareTo(a.date));

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFFFAFAFA),
              const Color(0xFFE7E9EE).withValues(alpha:0.3),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Transaction History',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              color: Colors.black87,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${filteredTransactions.length} transactions',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w400,
                              color: Colors.black.withValues(alpha:0.5),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: GlassCard(
                  child: TextField(
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Search transactions...',
                      hintStyle: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                        color: Colors.black.withValues(alpha:0.4),
                      ),
                      prefixIcon: Icon(
                        Icons.search_rounded,
                        color: Colors.black.withValues(alpha:0.4),
                        size: 22,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                child: GlassCard(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<int>(
                        value: _selectedMonth,
                        isExpanded: true,
                        icon: const Icon(Icons.keyboard_arrow_down_rounded),
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                        items: List.generate(12, (index) {
                          final month = DateFormat('MMMM', 'id_ID').format(DateTime(0, index + 1));
                          return DropdownMenuItem(
                            value: index + 1,
                            child: Text(month),
                          );
                        }),
                        onChanged: (selectedMonth) {
                          if (selectedMonth != null) {
                            setState(() {
                              _selectedMonth = selectedMonth;
                            });
                          }
                        },
                      ),
                    ),
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
                child: Row(
                  children: [
                    _buildFilterChip(
                      label: 'All',
                      isSelected: _selectedType == null,
                      onTap: () {
                        setState(() {
                          _selectedType = null;
                        });
                      },
                    ),
                    const SizedBox(width: 12),
                    _buildFilterChip(
                      label: 'Income',
                      isSelected: _selectedType == TransactionType.income,
                      onTap: () {
                        setState(() {
                          _selectedType = TransactionType.income;
                        });
                      },
                      color: const Color(0xFFD8F2E0),
                    ),
                    const SizedBox(width: 12),
                    _buildFilterChip(
                      label: 'Expense',
                      isSelected: _selectedType == TransactionType.expense,
                      onTap: () {
                        setState(() {
                          _selectedType = TransactionType.expense;
                        });
                      },
                      color: const Color(0xFFF8E8E9),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: filteredTransactions.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.receipt_long_outlined,
                              size: 80,
                              color: Colors.black.withValues(alpha:0.2),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No transactions',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.black.withValues(alpha:0.4),
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(24, 0, 24, 120),
                        itemCount: filteredTransactions.length,
                        itemBuilder: (context, index) {
                          final tx = filteredTransactions[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _buildTransactionCard(tx, context),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    Color? color,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? (color ?? const Color(0xFFF8E8E9))
              : Colors.white.withValues(alpha:0.8),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? (color ?? const Color(0xFFF8E8E9))
                : Colors.black.withValues(alpha:0.1),
            width: 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: (color ?? const Color(0xFFF8E8E9)).withValues(alpha:0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected ? Colors.black87 : Colors.black.withValues(alpha:0.6),
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionCard(TransactionModel tx, BuildContext context) {
    final isIncome = tx.type == TransactionType.income;

    return Dismissible(
      key: Key(tx.id),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: const Color(0xFFE57373),
          borderRadius: BorderRadius.circular(20),
        ),
        alignment: Alignment.centerRight,
        child: const Icon(
          Icons.delete_outline_rounded,
          color: Colors.white,
          size: 28,
        ),
      ),
      onDismissed: (direction) {
        Provider.of<TransactionProvider>(context, listen: false)
            .deleteTransaction(tx.id);
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${tx.title} deleted'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            backgroundColor: const Color(0xFFE57373),
          ),
        );
      },
      child: GestureDetector(
        onTap: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) => AddTransactionSheet(existingTransaction: tx),
          );
        },
        child: GlassCard(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: (isIncome
                            ? const Color(0xFFD8F2E0)
                            : const Color(0xFFF8E8E9))
                        .withValues(alpha:0.5),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Text(
                    tx.category.icon,
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
                const SizedBox(width: 16),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tx.title,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        tx.category.label,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          color: Colors.black.withValues(alpha:0.5),
                        ),
                      ),
                    ],
                  ),
                ),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${isIncome ? '+' : '-'} ${NumberFormat.currency(
                        locale: 'id_ID',
                        symbol: 'Rp ',
                        decimalDigits: 0,
                      ).format(tx.amount)}',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: isIncome
                            ? const Color(0xFF4CAF50)
                            : const Color(0xFFE57373),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat('dd MMM yyyy', 'id_ID').format(tx.date),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: Colors.black.withValues(alpha:0.5),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}