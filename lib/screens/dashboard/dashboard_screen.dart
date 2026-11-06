import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

import '../../models/transaction_model.dart';
import '../../services/auth_service.dart';
import '../../services/transaction_service.dart';
import '../../utils/app_theme.dart';
import '../../widgets/summary_card.dart';
import '../../widgets/transaction_card.dart';

import '../transactions/add_transaction_screen.dart';
import '../transactions/transaction_detail_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  String _currency(double amount) {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(amount);
  }

  Future<void> _logout(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Logout'),
        content: const Text(
          'Apakah kamu yakin ingin keluar dari akun ArusMaya?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.expense),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await AuthService().logout();
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final transactionService = TransactionService();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'ArusMaya',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
        ),
        actions: [
          IconButton(
            onPressed: () => _logout(context),
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'Logout',
          ),
          const SizedBox(width: 8),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddTransactionScreen()),
          );
        },
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Transaksi'),
      ),
      body: StreamBuilder<List<TransactionModel>>(
        stream: transactionService.getTransactions(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Text('Gagal memuat transaksi. Periksa koneksi.'),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final transactions = snapshot.data ?? [];

          final totalIncome = transactions
              .where((t) => t.isIncome)
              .fold<double>(0, (sum, t) => sum + t.amount);

          final totalExpense = transactions
              .where((t) => !t.isIncome)
              .fold<double>(0, (sum, t) => sum + t.amount);

          final balance = totalIncome - totalExpense;

          return RefreshIndicator(
            onRefresh: () async {
              await transactionService.getTransactions().first;
            },
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
              children: [
                Text(
                  'Halo, ${user?.displayName ?? 'Pengguna'} 👋',
                  style: const TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.navy,
                  ),
                ),
                const SizedBox(height: 5),
                const Text(
                  'Berikut ringkasan keuanganmu.',
                  style: TextStyle(color: Colors.grey),
                ),

                const SizedBox(height: 24),

                // BALANCE CARD
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppTheme.navy, AppTheme.primary],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Saldo Bersih',
                        style: TextStyle(color: Colors.white70),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _currency(balance),
                        style: const TextStyle(
                          fontSize: 29,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          const Icon(
                            Icons.account_balance_wallet_outlined,
                            color: Colors.white70,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${transactions.length} transaksi tercatat',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 22),

                const Text(
                  'Ringkasan Keuangan',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.navy,
                  ),
                ),

                const SizedBox(height: 14),

                Row(
                  children: [
                    Expanded(
                      child: SummaryCard(
                        title: 'Pemasukan',
                        value: _currency(totalIncome),
                        icon: Icons.trending_up_rounded,
                        color: AppTheme.income,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SummaryCard(
                        title: 'Pengeluaran',
                        value: _currency(totalExpense),
                        icon: Icons.trending_down_rounded,
                        color: AppTheme.expense,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 26),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Transaksi Terbaru',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.navy,
                      ),
                    ),
                    Text(
                      '${transactions.length} transaksi',
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),

                const SizedBox(height: 15),

                if (transactions.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(30),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: const Column(
                      children: [
                        Icon(
                          Icons.receipt_long_outlined,
                          size: 45,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 12),
                        Text(
                          'Belum ada transaksi',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 5),
                        Text(
                          'Mulai catat pemasukan dan pengeluaranmu.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      ],
                    ),
                  )
                else
                  ...transactions.map(
                    (transaction) => TransactionCard(
                      transaction: transaction,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => TransactionDetailScreen(
                              transaction: transaction,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
