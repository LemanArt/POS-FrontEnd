import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_pos_app/core/extensions/build_context_ext.dart';
import 'package:flutter_pos_app/core/extensions/date_time_ext.dart';
import 'package:flutter_pos_app/core/extensions/int_ext.dart';
import 'package:flutter_pos_app/presentation/home/bloc/checkout/checkout_bloc.dart';
import 'package:flutter_pos_app/presentation/home/pages/dashboard_page.dart';
import 'package:flutter_pos_app/presentation/order/bloc/order/order_bloc.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';

import '../../../core/assets/assets.gen.dart';
import '../../../core/components/buttons.dart';
import '../../../core/components/spaces.dart';
import '../../../core/constants/colors.dart';
import '../../../data/dataoutputs/cwb_print.dart';

class PaymentSuccessDialog extends StatefulWidget {
  const PaymentSuccessDialog({super.key});

  @override
  State<PaymentSuccessDialog> createState() => _PaymentSuccessDialogState();
}

class _PaymentSuccessDialogState extends State<PaymentSuccessDialog> {
  bool isHoveringPrint = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      scrollable: true,
      title: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(child: Assets.icons.done.svg()),
          const SpaceHeight(24.0),
          const Text(
            'Pembayaran telah sukses dilakukan',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
            ),
          ),
        ],
      ),
      content: BlocBuilder<OrderBloc, OrderState>(
        builder: (context, state) {
          return state.maybeWhen(
            orElse: () => const SizedBox.shrink(),
            success:
                (data, qty, total, paymentType, nominal, idKasir, nameKasir) {
              context.read<CheckoutBloc>().add(const CheckoutEvent.started());

              int kembalian = nominal - total;
              String kembalianText = kembalian.currencyFormatRp;

              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SpaceHeight(12.0),
                  _LabelValue(label: 'METODE PEMBAYARAN', value: paymentType),
                  const Divider(height: 36.0),
                  _LabelValue(
                      label: 'TOTAL PEMBELIAN', value: total.currencyFormatRp),
                  const Divider(height: 36.0),
                  _LabelValue(
                    label: 'NOMINAL BAYAR',
                    value: paymentType == 'QRIS'
                        ? total.currencyFormatRp
                        : nominal.currencyFormatRp,
                  ),
                  const Divider(height: 36.0),
                  _LabelValue(label: 'KEMBALIAN', value: kembalianText),
                  const Divider(height: 36.0),
                  _LabelValue(
                      label: 'WAKTU PEMBAYARAN',
                      value: DateTime.now().toFormattedTime()),
                  const SpaceHeight(40.0),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Button.filled(
                          onPressed: () {
                            context
                                .read<OrderBloc>()
                                .add(const OrderEvent.started());
                            context.pushReplacement(const DashboardPage());
                          },
                          label: 'Selesai',
                          fontSize: 13,
                        ),
                      ),
                      const SpaceWidth(10.0),
                      Flexible(
                        child: MouseRegion(
                          onEnter: (_) =>
                              setState(() => isHoveringPrint = true),
                          onExit: (_) =>
                              setState(() => isHoveringPrint = false),
                          child: OutlinedButton(
                            onPressed: () async {
                              final printValue =
                                  await CwbPrint.instance.printOrder(
                                data,
                                qty,
                                total,
                                paymentType,
                                nominal,
                                nameKasir,
                              );
                              await PrintBluetoothThermal.writeBytes(
                                  printValue);
                            },
                            style: OutlinedButton.styleFrom(
                              backgroundColor: isHoveringPrint
                                  ? AppColors.light
                                  : Colors.transparent,
                              side: const BorderSide(color: AppColors.primary),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Assets.icons.print.svg(width: 25, height: 25),
                                const SizedBox(width: 8),
                                Text(
                                  'Print',
                                  style: TextStyle(
                                    color: isHoveringPrint
                                        ? AppColors.black
                                        : AppColors.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

class _LabelValue extends StatelessWidget {
  final String label;
  final String value;

  const _LabelValue({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        const SpaceHeight(5.0),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}
