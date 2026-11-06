import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/transaction_model.dart';
import '../../services/transaction_service.dart';
import '../../utils/app_theme.dart';

class TransactionDetailScreen extends StatefulWidget {
  final TransactionModel transaction;

  const TransactionDetailScreen({super.key, required this.transaction});

  @override
  State<TransactionDetailScreen> createState() =>
      _TransactionDetailScreenState();
}

class _TransactionDetailScreenState extends State<TransactionDetailScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _titleController;
  late final TextEditingController _amountController;
  late final TextEditingController _noteController;

  final TransactionService _service = TransactionService();

  late String _type;
  late DateTime _date;

  bool _editing = false;
  bool _loading = false;

  TransactionModel get transaction => widget.transaction;

  String _currency(double amount) {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(amount);
  }

  @override
  void initState() {
    super.initState();

    _titleController = TextEditingController(text: transaction.title);

    _amountController = TextEditingController(
      text: transaction.amount.toString(),
    );

    _noteController = TextEditingController(text: transaction.note);

    _type = transaction.type;
    _date = transaction.date;
  }

  Future<void> _selectDate() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      locale: const Locale('id', 'ID'),
    );

    if (selected != null) {
      setState(() => _date = selected);
    }
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    try {
      final updated = TransactionModel(
        id: transaction.id,
        title: _titleController.text.trim(),
        amount: double.parse(
          _amountController.text.trim().replaceAll(',', '.'),
        ),
        type: _type,
        note: _noteController.text.trim(),
        date: _date,
        createdAt: transaction.createdAt,
      );

      await _service.updateTransaction(updated);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Transaksi berhasil diperbarui.'),
          backgroundColor: AppTheme.income,
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal memperbarui transaksi.'),
          backgroundColor: AppTheme.expense,
        ),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _deleteTransaction() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Hapus Transaksi'),
        content: const Text(
          'Apakah kamu yakin ingin menghapus transaksi ini? '
          'Data yang dihapus tidak dapat dikembalikan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.expense),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _loading = true);

    try {
      await _service.deleteTransaction(transaction.id);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Transaksi berhasil dihapus.')),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal menghapus transaksi.'),
          backgroundColor: AppTheme.expense,
        ),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = transaction.isIncome ? AppTheme.income : AppTheme.expense;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Transaksi'),
        actions: [
          if (!_editing)
            IconButton(
              onPressed: () => setState(() => _editing = true),
              icon: const Icon(Icons.edit_outlined),
              tooltip: 'Edit',
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(22),
        child: _editing ? _buildEditForm() : _buildDetails(color),
      ),
    );
  }

  Widget _buildDetails(Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.10),
              shape: BoxShape.circle,
            ),
            child: Icon(
              transaction.isIncome ? Icons.trending_up : Icons.trending_down,
              size: 42,
              color: color,
            ),
          ),
        ),
        const SizedBox(height: 20),
        Center(
          child: Text(
            transaction.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 23,
              fontWeight: FontWeight.bold,
              color: AppTheme.navy,
            ),
          ),
        ),
        const SizedBox(height: 10),
        Center(
          child: Text(
            '${transaction.isIncome ? '+' : '-'}${_currency(transaction.amount)}',
            style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
        const SizedBox(height: 32),
        _detailRow('Tipe', transaction.isIncome ? 'Pemasukan' : 'Pengeluaran'),
        _detailRow(
          'Tanggal',
          DateFormat('dd MMMM yyyy', 'id_ID').format(transaction.date),
        ),
        _detailRow(
          'Catatan',
          transaction.note.isEmpty ? '-' : transaction.note,
        ),
        const SizedBox(height: 35),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => setState(() => _editing = true),
            icon: const Icon(Icons.edit_outlined),
            label: const Text('Edit Transaksi'),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _loading ? null : _deleteTransaction,
            icon: const Icon(Icons.delete_outline),
            label: const Text('Hapus Transaksi'),
            style: OutlinedButton.styleFrom(foregroundColor: AppTheme.expense),
          ),
        ),
      ],
    );
  }

  Widget _detailRow(String label, String value) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: AppTheme.navy,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Judul Transaksi',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _titleController,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Judul wajib diisi.';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),

          const Text('Nominal', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          TextFormField(
            controller: _amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(prefixText: 'Rp '),
            validator: (value) {
              final amount = double.tryParse(
                (value ?? '').trim().replaceAll(',', '.'),
              );

              if (amount == null || amount <= 0) {
                return 'Nominal tidak valid.';
              }

              return null;
            },
          ),
          const SizedBox(height: 20),

          const Text(
            'Tipe Transaksi',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            initialValue: _type,
            decoration: const InputDecoration(),
            items: const [
              DropdownMenuItem(value: 'income', child: Text('Pemasukan')),
              DropdownMenuItem(value: 'expense', child: Text('Pengeluaran')),
            ],
            onChanged: (value) {
              if (value != null) setState(() => _type = value);
            },
          ),
          const SizedBox(height: 20),

          const Text('Tanggal', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.calendar_month),
            title: Text(DateFormat('dd MMMM yyyy', 'id_ID').format(_date)),
            onTap: _selectDate,
          ),
          const SizedBox(height: 20),

          const Text('Catatan', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          TextFormField(
            controller: _noteController,
            maxLines: 3,
            decoration: const InputDecoration(hintText: 'Catatan transaksi...'),
          ),
          const SizedBox(height: 30),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _loading ? null : _saveChanges,
              child: _loading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Simpan Perubahan'),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () => setState(() => _editing = false),
              child: const Text('Batal'),
            ),
          ),
        ],
      ),
    );
  }
}
