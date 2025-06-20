import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_pos_app/core/extensions/build_context_ext.dart';
import 'package:flutter_pos_app/core/extensions/int_ext.dart'; // Extension currencyFormatRp
import 'package:flutter_pos_app/core/extensions/string_ext.dart';
import 'package:flutter_pos_app/data/datasources/product_local_datasource.dart';
import 'package:flutter_pos_app/presentation/order/bloc/order/order_bloc.dart';
import 'package:flutter_pos_app/presentation/order/models/order_model.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart'; // Untuk TextInputFormatter

import '../../../core/components/buttons.dart';
import '../../../core/components/custom_text_field.dart';
import '../../../core/components/spaces.dart';
import '../../../core/constants/colors.dart';
import 'payment_success_dialog.dart';

class PaymentCashDialog extends StatefulWidget {
  final int price;
  const PaymentCashDialog({super.key, required this.price});

  @override
  State<PaymentCashDialog> createState() => _PaymentCashDialogState();
}

class _PaymentCashDialogState extends State<PaymentCashDialog> {
  TextEditingController? priceController; // Controller untuk harga
  TextEditingController?
      paidAmountController; // Controller untuk uang yang diberikan pelanggan
  double _change = 0.0; // Variabel untuk menyimpan kembalian
  bool _isAmountValid = true;
  bool _canProceed = false;
// Untuk mengecek apakah uang yang diberikan cukup

  @override
  void initState() {
    priceController =
        TextEditingController(text: widget.price.currencyFormatRp);
    paidAmountController = TextEditingController();
    super.initState();
  }

  // Fungsi untuk menghitung kembalian
  void _calculateChange() {
    double paidAmount = double.tryParse(
            paidAmountController!.text.replaceAll(RegExp(r'[^\d]'), '')) ??
        0.0;

    if (paidAmount >= widget.price) {
      setState(() {
        _change = paidAmount - widget.price;
        _isAmountValid = true;
        _canProceed = true;
      });
    } else {
      setState(() {
        _change = 0.0;
        _isAmountValid = false;
        _canProceed = false;
      });
    }
  }

  // Fungsi untuk memformat uang dengan simbol Rp
  String formatCurrency(double amount) {
    return NumberFormat.currency(locale: 'id', symbol: 'Rp. ', decimalDigits: 0)
        .format(amount);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      scrollable: true,
      title: Stack(
        children: [
          IconButton(
            onPressed: () => context.pop(),
            icon: const Icon(Icons.highlight_off),
            color: AppColors.primary,
          ),
          const Center(
            child: Padding(
              padding: EdgeInsets.only(top: 12.0),
              child: Text(
                'Pembayaran - Tunai',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SpaceHeight(16.0),
          // Ganti CustomTextField untuk memasukkan jumlah uang yang diberikan pelanggan
          CustomTextField(
            controller: paidAmountController!,
            label: 'Jumlah Uang yang Diberikan', // Menampilkan label
            showLabel: true, // Menampilkan label
            keyboardType: TextInputType.number,
            onChanged: (value) {
              // Format input sebagai mata uang otomatis
              double paidAmount =
                  double.tryParse(value.replaceAll(RegExp(r'\D'), '')) ?? 0.0;
              paidAmountController!.text = formatCurrency(paidAmount);
              paidAmountController!.selection = TextSelection.fromPosition(
                  TextPosition(offset: paidAmountController!.text.length));

              // Menghitung kembalian setiap kali ada perubahan
              _calculateChange();
            },
          ),
          const SpaceHeight(16.0),

          // Menampilkan kembalian jika ada
          if (_change > 0)
            Text(
              'Kembalian: ${_change.currencyFormatRp}', // Menampilkan kembalian dengan format Rp
              style: const TextStyle(
                  color: Colors.green,
                  fontSize: 16,
                  fontWeight: FontWeight.bold),
            ),
          if (!_isAmountValid && paidAmountController!.text.isNotEmpty)
            const Text(
              'Jumlah uang yang diberikan kurang!',
              style: TextStyle(fontSize: 16, color: Colors.red),
            ),
          const SpaceHeight(16.0),

          // Menampilkan tombol untuk memproses pembayaran
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Button.filled(
                onPressed: () {
                  paidAmountController!.text = widget.price.currencyFormatRp;
                  _calculateChange(); // penting
                },
                label: 'Uang Pas (${widget.price.currencyFormatRp})',
                disabled: false, // Tombol aktif
                textColor: const Color.fromARGB(255, 255, 255, 255),
                fontSize: 13.0,
                width: 200.0,
                height: 50.0,
                color: const Color.fromARGB(199, 121, 120, 120),
              ),
              const SpaceWidth(4.0),
            ],
          ),
          const SpaceHeight(30.0),
          // Tombol Proses untuk menyelesaikan pembayaran
          BlocConsumer<OrderBloc, OrderState>(
            listener: (context, state) {
              state.maybeWhen(
                orElse: () {},
                success:
                    (data, qty, total, payment, nominal, idKasir, namaKasir) {
                  final orderModel = OrderModel(
                      paymentMethod: payment,
                      nominalBayar: nominal,
                      orders: data,
                      totalQuantity: qty,
                      totalPrice: total,
                      idKasir: idKasir,
                      namaKasir: namaKasir,
                      transactionTime: DateFormat('yyyy-MM-ddTHH:mm:ss')
                          .format(DateTime.now()),
                      isSync: false);
                  ProductLocalDatasource.instance.saveOrder(orderModel);
                  context.pop();
                  showDialog(
                    context: context,
                    builder: (context) => const PaymentSuccessDialog(),
                  );
                },
              );
            },
            builder: (context, state) {
              return state.maybeWhen(
                orElse: () {
                  return const SizedBox();
                },
                success: (data, qty, total, payment, _, idKasir, mameKasir) {
                  return Button.filled(
                    onPressed: () {
                      if (_canProceed) {
                        context
                            .read<OrderBloc>()
                            .add(OrderEvent.addNominalBayar(
                              paidAmountController!.text.toIntegerFromText,
                            ));
                      }
                    },
                    label: 'Proses',
                    disabled:
                        !_canProceed, // Tetap membuat tombol abu-abu saat tidak bisa
                  );
                },
                error: (message) {
                  return const SizedBox();
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
