import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

/// Widget untuk menampilkan sparkline chart dengan Income & Expense
/// Digunakan untuk menampilkan tren pemasukan dan pengeluaran 7 hari terakhir
class SparklineChart extends StatelessWidget {
  final List<double> incomeData;
  final List<double> expenseData;
  final double animationValue;

  const SparklineChart({
    super.key,
    required this.incomeData,
    required this.expenseData,
    this.animationValue = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    if ((incomeData.isEmpty && expenseData.isEmpty) || 
        (incomeData.every((element) => element == 0) && expenseData.every((element) => element == 0))) {
      return Center(
        child: Text(
          'No data available',
          style: TextStyle(
            fontSize: 14,
            color: Colors.black.withValues(alpha: 0.4),
          ),
        ),
      );
    }

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildLegend('Income', const Color(0xFF4CAF50)),
            const SizedBox(width: 20),
            _buildLegend('Expense', const Color(0xFFE57373)),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 120,
          child: LineChart(
            LineChartData(
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: _getMaxValue() / 4,
                getDrawingHorizontalLine: (value) {
                  return FlLine(
                    color: Colors.black.withValues(alpha: 0.05),
                    strokeWidth: 1,
                  );
                },
              ),
              
              borderData: FlBorderData(show: false),
              
              titlesData: FlTitlesData(
                leftTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 24,
                    getTitlesWidget: (value, meta) {
                      const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                      final now = DateTime.now();
                      final index = value.toInt();
                      if (index >= 0 && index < 7) {
                        final day = now.subtract(Duration(days: 6 - index));
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            days[day.weekday - 1].substring(0, 1),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: Colors.black.withValues(alpha: 0.5),
                            ),
                          ),
                        );
                      }
                      return const Text('');
                    },
                  ),
                ),
              ),
              
              lineTouchData: LineTouchData(
                enabled: true,
                touchTooltipData: LineTouchTooltipData(
                  tooltipBgColor: Colors.black87,
                  tooltipRoundedRadius: 12,
                  tooltipPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  getTooltipItems: (touchedSpots) {
                    return touchedSpots.map((spot) {
                      return LineTooltipItem(
                        'Rp ${spot.y.toStringAsFixed(0)}',
                        const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      );
                    }).toList();
                  },
                ),
              ),

              minY: 0,
              maxY: _getMaxValue() * 1.2,
              
              lineBarsData: [
                // Income Line dengan animasi
                LineChartBarData(
                  spots: _generateAnimatedSpots(incomeData),
                  isCurved: true,
                  curveSmoothness: 0.4,
                  color: const Color(0xFF4CAF50),
                  barWidth: 3,
                  isStrokeCapRound: true,
                  dotData: FlDotData(
                    show: true,
                    getDotPainter: (spot, percent, barData, index) {
                      return FlDotCirclePainter(
                        radius: 4,
                        color: const Color(0xFF4CAF50),
                        strokeWidth: 2,
                        strokeColor: Colors.white,
                      );
                    },
                  ),
                  belowBarData: BarAreaData(
                    show: true,
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        const Color(0xFF4CAF50).withValues(alpha: 0.2),
                        const Color(0xFF4CAF50).withValues(alpha: 0.02),
                      ],
                    ),
                  ),
                ),
                // Expense Line dengan animasi
                LineChartBarData(
                  spots: _generateAnimatedSpots(expenseData),
                  isCurved: true,
                  curveSmoothness: 0.4,
                  color: const Color(0xFFE57373),
                  barWidth: 3,
                  isStrokeCapRound: true,
                  dotData: FlDotData(
                    show: true,
                    getDotPainter: (spot, percent, barData, index) {
                      return FlDotCirclePainter(
                        radius: 4,
                        color: const Color(0xFFE57373),
                        strokeWidth: 2,
                        strokeColor: Colors.white,
                      );
                    },
                  ),
                  belowBarData: BarAreaData(
                    show: true,
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        const Color(0xFFE57373).withValues(alpha: 0.2),
                        const Color(0xFFE57373).withValues(alpha: 0.02),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

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
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.black.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }

  /// Generate spots dengan animasi grow effect
  List<FlSpot> _generateAnimatedSpots(List<double> data) {
    return List.generate(
      data.length,
      (index) => FlSpot(index.toDouble(), data[index] * animationValue),
    );
  }

  double _getMaxValue() {
    final incomeMax = incomeData.isEmpty ? 0.0 : incomeData.reduce((a, b) => a > b ? a : b);
    final expenseMax = expenseData.isEmpty ? 0.0 : expenseData.reduce((a, b) => a > b ? a : b);
    final max = incomeMax > expenseMax ? incomeMax : expenseMax;
    return max == 0 ? 100000 : max;
  }
}