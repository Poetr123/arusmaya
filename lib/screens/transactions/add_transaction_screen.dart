import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../services/transaction_service.dart';
import '../../utils/app_theme.dart';

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  final TransactionService _service = TransactionService();

  String _type = 'expense';
  DateTime _date = DateTime.now();
  bool _loading = false;

  static const Color _navy = Color(0xFF142B4A);
  static const Color _blue = Color(0xFF2563EB);
  static const Color _background = Color(0xFFF5F7FB);

  String get _formattedDate {
    return DateFormat('dd MMMM yyyy', 'id_ID').format(_date);
  }

  Future<void> _selectDate() async {
    FocusScope.of(context).unfocus();

    final selected = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      locale: const Locale('id', 'ID'),
      helpText: 'PILIH TANGGAL TRANSAKSI',
      cancelText: 'BATAL',
      confirmText: 'PILIH',
      fieldLabelText: 'Tanggal transaksi',
      fieldHintText: 'DD/MM/YYYY',
      initialEntryMode: DatePickerEntryMode.calendarOnly,
      builder: (context, child) {
        final baseTheme = Theme.of(context);

        return Theme(
          data: baseTheme.copyWith(
            colorScheme: const ColorScheme.light(
              primary: _blue,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: _navy,
            ),
            dialogTheme: const DialogThemeData(
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.transparent,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: _blue,
                textStyle: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (!mounted) return;

    if (selected != null) {
      setState(() {
        _date = selected;
      });
    }
  }

  Future<void> _saveTransaction() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    try {
      final amount = double.parse(
        _amountController.text.trim().replaceAll(',', '.'),
      );

      await _service.addTransaction(
        title: _titleController.text.trim(),
        amount: amount,
        type: _type,
        note: _noteController.text.trim(),
        date: _date,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Transaksi berhasil disimpan!'),
          backgroundColor: AppTheme.income,
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      debugPrint('Gagal menyimpan transaksi: $e');

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal menyimpan transaksi.'),
          backgroundColor: AppTheme.expense,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
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
    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        title: const Text('Tambah Transaksi'),
        backgroundColor: Colors.white,
        foregroundColor: _navy,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(22),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Tipe Transaksi',
                style: TextStyle(fontWeight: FontWeight.bold, color: _navy),
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: _typeButton(
                      label: 'Pemasukan',
                      value: 'income',
                      icon: Icons.trending_up,
                      color: AppTheme.income,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _typeButton(
                      label: 'Pengeluaran',
                      value: 'expense',
                      icon: Icons.trending_down,
                      color: AppTheme.expense,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 25),

              _sectionLabel('Judul Transaksi'),
              const SizedBox(height: 8),

              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  hintText: 'Contoh: Makan siang',
                  prefixIcon: Icon(Icons.receipt_outlined),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Judul transaksi wajib diisi.';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),

              _sectionLabel('Nominal'),
              const SizedBox(height: 8),

              TextFormField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  hintText: 'Contoh: 50000',
                  prefixText: 'Rp ',
                  prefixIcon: Icon(Icons.payments_outlined),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Nominal wajib diisi.';
                  }

                  final amount = double.tryParse(
                    value.trim().replaceAll(',', '.'),
                  );

                  if (amount == null || amount <= 0) {
                    return 'Masukkan nominal yang valid.';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 20),

              _sectionLabel('Tanggal Transaksi'),
              const SizedBox(height: 8),

              InkWell(
                onTap: _selectDate,
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(17),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_month_outlined, color: _blue),
                      const SizedBox(width: 12),

                      Expanded(
                        child: Text(
                          _formattedDate,
                          style: const TextStyle(
                            color: _navy,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),

                      const Icon(Icons.keyboard_arrow_down, color: _navy),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              _sectionLabel('Catatan (Opsional)'),
              const SizedBox(height: 8),

              TextFormField(
                controller: _noteController,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'Tambahkan catatan transaksi...',
                  alignLabelWithHint: true,
                ),
              ),

              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _loading ? null : _saveTransaction,
                  child: _loading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Simpan Transaksi',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionLabel(String label) {
    return Text(
      label,
      style: const TextStyle(fontWeight: FontWeight.bold, color: _navy),
    );
  }

  Widget _typeButton({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    final selected = _type == value;

    return InkWell(
      onTap: () => setState(() => _type = value),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: 0.10) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? color : const Color(0xFFE5E7EB),
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
