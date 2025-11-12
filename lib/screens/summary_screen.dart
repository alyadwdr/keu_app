import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/transaction_provider.dart';
import '../models/transaction.dart';
import '../widgets/glass_card.dart';

/// Halaman Summary - menampilkan ringkasan bulanan
class SummaryScreen extends StatefulWidget {
  const SummaryScreen({super.key});

  @override
  State<SummaryScreen> createState() => _SummaryScreenState();
}

class _SummaryScreenState extends State<SummaryScreen> {
  late int _selectedMonth;
  late int _selectedYear;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedMonth = now.month;
    _selectedYear = now.year;
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TransactionProvider>(context);
    final monthlyIncome = provider.getMonthlyIncome(_selectedMonth, _selectedYear);
    final monthlyExpense = provider.getMonthlyExpense(_selectedMonth, _selectedYear);
    final difference = monthlyIncome - monthlyExpense;
    final categoryBreakdown = provider.getCategoryBreakdown(_selectedMonth, _selectedYear);

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
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Monthly Summary',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800, // More bold
                          color: Colors.black87,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Financial recap per month',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                          color: Colors.black.withValues(alpha:0.5),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Dropdown Bulan
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: GlassCard(
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: '$_selectedMonth-$_selectedYear',
                        isExpanded: true,
                        icon: Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: Colors.black.withValues(alpha:0.6),
                        ),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        items: _generateMonthItems(),
                        onChanged: (value) {
                          if (value != null) {
                            final parts = value.split('-');
                            setState(() {
                              _selectedMonth = int.parse(parts[0]);
                              _selectedYear = int.parse(parts[1]);
                            });
                          }
                        },
                      ),
                    ),
                  ),
                ),
              ),

              // Pie Chart
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                  child: GlassCard(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          const Text(
                            'Income vs Expense Comparison',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            height: 200,
                            child: monthlyIncome == 0 && monthlyExpense == 0
                                ? Center(
                                    child: Text(
                                      'No data',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.black.withValues(alpha:0.4),
                                      ),
                                    ),
                                  )
                                : PieChart(
                                    PieChartData(
                                      sectionsSpace: 4,
                                      centerSpaceRadius: 50,
                                      sections: [
                                        PieChartSectionData(
                                          value: monthlyIncome,
                                          title: '${((monthlyIncome / (monthlyIncome + monthlyExpense)) * 100).toStringAsFixed(0)}%',
                                          color: const Color(0xFF81C784),
                                          radius: 60,
                                          titleStyle: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white,
                                          ),
                                        ),
                                        PieChartSectionData(
                                          value: monthlyExpense,
                                          title: '${((monthlyExpense / (monthlyIncome + monthlyExpense)) * 100).toStringAsFixed(0)}%',
                                          color: const Color(0xFFE57373),
                                          radius: 60,
                                          titleStyle: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildLegend('Income', const Color(0xFF81C784)),
                              const SizedBox(width: 24),
                              _buildLegend('Expense', const Color(0xFFE57373)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Summary Cards
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildSummaryCard(
                          icon: Icons.arrow_downward_rounded,
                          label: 'Income',
                          amount: monthlyIncome,
                          color: const Color(0xFFD8F2E0),
                          iconColor: const Color(0xFF4CAF50),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildSummaryCard(
                          icon: Icons.arrow_upward_rounded,
                          label: 'Expense',
                          amount: monthlyExpense,
                          color: const Color(0xFFF8E8E9),
                          iconColor: const Color(0xFFE57373),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Difference Card
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
                  child: GlassCard(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: (difference >= 0 
                                  ? const Color(0xFFD8F2E0) 
                                  : const Color(0xFFF8E8E9)).withValues(alpha:0.5),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Icon(
                              difference >= 0 
                                  ? Icons.trending_up_rounded 
                                  : Icons.trending_down_rounded,
                              color: difference >= 0 
                                  ? const Color(0xFF4CAF50) 
                                  : const Color(0xFFE57373),
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  difference >= 0 ? 'Surplus' : 'Deficit',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black.withValues(alpha:0.6),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  NumberFormat.currency(
                                    locale: 'id_ID',
                                    symbol: 'Rp ',
                                    decimalDigits: 0,
                                  ).format(difference.abs()),
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                    color: difference >= 0 
                                        ? const Color(0xFF4CAF50) 
                                        : const Color(0xFFE57373),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Category Breakdown
              if (categoryBreakdown.isNotEmpty) ...[
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(24, 8, 24, 12),
                    child: Text(
                      'Expense by Category',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 120),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final entry = categoryBreakdown.entries.toList()[index];
                        final percentage = (entry.value / monthlyExpense) * 100;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _buildCategoryCard(
                            category: entry.key,
                            amount: entry.value,
                            percentage: percentage,
                            totalExpense: monthlyExpense,
                          ),
                        );
                      },
                      childCount: categoryBreakdown.length,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// Generate list bulan untuk dropdown
  List<DropdownMenuItem<String>> _generateMonthItems() {
    final List<DropdownMenuItem<String>> items = [];
    final now = DateTime.now();

    // Generate 12 bulan terakhir
    for (int i = 0; i < 12; i++) {
      final date = DateTime(now.year, now.month - i, 1);
      items.add(
        DropdownMenuItem(
          value: '${date.month}-${date.year}',
          child: Text(DateFormat('MMMM yyyy', 'id_ID').format(date)),
        ),
      );
    }

    return items;
  }

  /// Widget untuk legend pie chart
  Widget _buildLegend(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Colors.black.withValues(alpha:0.7),
          ),
        ),
      ],
    );
  }

  /// Widget untuk summary card
  Widget _buildSummaryCard({
    required IconData icon,
    required String label,
    required double amount,
    required Color color,
    required Color iconColor,
  }) {
    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha:0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                size: 20,
                color: iconColor,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Colors.black.withValues(alpha:0.6),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              NumberFormat.currency(
                locale: 'id_ID',
                symbol: 'Rp ',
                decimalDigits: 0,
              ).format(amount),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Widget untuk category card
  Widget _buildCategoryCard({
    required TransactionCategory category,
    required double amount,
    required double percentage,
    required double totalExpense,
  }) {
    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Text(
                  category.icon,
                  style: const TextStyle(fontSize: 28),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        category.label,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        NumberFormat.currency(
                          locale: 'id_ID',
                          symbol: 'Rp ',
                          decimalDigits: 0,
                        ).format(amount),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Colors.black.withValues(alpha:0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '${percentage.toStringAsFixed(1)}%',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFE57373),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: percentage / 100,
                minHeight: 8,
                backgroundColor: const Color(0xFFF8E8E9).withValues(alpha:0.3),
                valueColor: const AlwaysStoppedAnimation<Color>(
                  Color(0xFFE57373),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}