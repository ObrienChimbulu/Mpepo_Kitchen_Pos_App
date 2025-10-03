import 'package:flutter/material.dart';
import 'package:mpepo_kitchen_pos_app/utils/constants/colors.dart';
import 'package:mpepo_kitchen_pos_app/utils/constants/currency.dart';
import '../services/api_service.dart';

class ReportsScreen extends StatefulWidget {
  @override
  _ReportsScreenState createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  final ApiService _apiService = ApiService();
  Map<String, dynamic>? dailyReport;
  Map<String, dynamic>? salesSummary;
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  Future<void> _loadReports() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      final daily = await _apiService.getDailySalesReport();
      final summary = await _apiService.getSalesSummary(days: 7);

      setState(() {
        dailyReport = daily;
        salesSummary = summary;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sales Reports'),
        backgroundColor: TColors.primary,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadReports,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error, size: 64, color: Colors.red),
            SizedBox(height: 16),
            Text('Error: $error'),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadReports,
              child: Text('Retry'),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          _buildDailyReport(),
          SizedBox(height: 20),
          _buildSalesSummary(),
        ],
      ),
    );
  }

  Widget _buildDailyReport() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Daily Sales Report',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            if (dailyReport != null) ...[
              _buildReportRow('Date', dailyReport!['date']),
              _buildReportRow('Total Sales', '${TCurrency.ZambiaCurrency} ${dailyReport!['total_sales'].toStringAsFixed(2)}'),
              _buildReportRow('Total Orders', dailyReport!['total_orders'].toString()),
              _buildReportRow('Tax Collected', '${TCurrency.ZambiaCurrency} ${dailyReport!['total_tax'].toStringAsFixed(2)}'),
              _buildReportRow('Average Order', '${TCurrency.ZambiaCurrency} ${dailyReport!['average_order_value'].toStringAsFixed(2)}'),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSalesSummary() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Last 7 days Summary',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            if (salesSummary != null) ...[
              _buildReportRow('Period', salesSummary!['period']),
              _buildReportRow('Total Sales', '${TCurrency.ZambiaCurrency} ${salesSummary!['total_sales'].toStringAsFixed(2)}'),
              _buildReportRow('Total Orders', salesSummary!['total_orders'].toString()),
              _buildReportRow('Total Tax', '${TCurrency.ZambiaCurrency} ${salesSummary!['total_tax'].toStringAsFixed(2)}'),
              SizedBox(height: 16),
              Text('Daily Breakdown:', style: TextStyle(fontWeight: FontWeight.bold)),
              ..._buildDailyBreakdown(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildReportRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontWeight: FontWeight.w500)),
          Text(value, style: TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  List<Widget> _buildDailyBreakdown() {
    if (salesSummary == null || salesSummary!['daily_breakdown'] == null) {
      return [SizedBox.shrink()];
    }

    return salesSummary!['daily_breakdown'].map<Widget>((day) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(day['date']),
            Text('${TCurrency.ZambiaCurrency} ${day['total_sales'].toStringAsFixed(2)}'),
          ],
        ),
      );
    }).toList();
  }
}