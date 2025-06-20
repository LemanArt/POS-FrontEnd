import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_pos_app/presentation/home/models/order_item.dart';
import 'package:flutter_pos_app/presentation/order/bloc/order/order_bloc.dart';
import '../../../core/assets/assets.gen.dart';
import '../../../core/components/menu_button.dart';
import '../../../core/components/spaces.dart';
import '../../../core/constants/colors.dart';
import '../../home/bloc/checkout/checkout_bloc.dart';
import '../widget/order_card.dart';
import '../widget/payment_cash_dialog.dart';
import '../widget/payment_qris_dialog.dart';
import '../widget/process_button.dart';

class OrderPage extends StatefulWidget {
  const OrderPage({super.key});

  @override
  State<OrderPage> createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  final indexValue = ValueNotifier(0);
  List<OrderItem> orders = [];
  int totalPrice = 0;

  int calculateTotalPrice(List<OrderItem> orders) {
    return orders.fold(
        0,
        (previousValue, element) =>
            previousValue + element.product.price * element.quantity);
  }

  @override
  Widget build(BuildContext context) {
    const paddingHorizontal = EdgeInsets.symmetric(horizontal: 16.0);
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Order Detail',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          // Tombol Trash untuk menghapus semua order
          IconButton(
            onPressed: () {
              // Tampilkan konfirmasi hapus semua order
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text("Konfirmasi Hapus Semua Order"),
                    content: const Text(
                        "Apakah Anda yakin ingin menghapus semua order?"),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(), // Tidak
                        child: const Text('Tidak'),
                      ),
                      TextButton(
                        onPressed: () {
                          // Menghapus semua produk dari daftar
                          context
                              .read<CheckoutBloc>()
                              .add(const CheckoutEvent.clearAllCheckout());
                          Navigator.of(context).pop(); // Ya
                        },
                        child: const Text('Ya'),
                      ),
                    ],
                  );
                },
              );
            },
            icon: Assets.icons.delete.svg(
              color: const Color.fromARGB(255, 227, 110, 71).withOpacity(0.8),
            ),
          ),
        ],
      ),
      body: BlocBuilder<CheckoutBloc, CheckoutState>(
        builder: (context, state) {
          return state.maybeWhen(
            orElse: () => const Center(child: Text('No Data')),
            success: (data, qty, total) {
              if (data.isEmpty) {
                return const Center(child: Text('No Data'));
              }
              totalPrice = total;
              return ListView.separated(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                itemCount: data.length,
                separatorBuilder: (context, index) => const SpaceHeight(20.0),
                itemBuilder: (context, index) => OrderCard(
                  padding: paddingHorizontal,
                  data: data[index],
                  onDeleteTap: () {
                    // Menghapus order jika tombol "X" diklik
                    context
                        .read<CheckoutBloc>()
                        .add(CheckoutEvent.removeCheckout(data[index].product));
                  },
                ),
              );
            },
          );
        },
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            BlocBuilder<CheckoutBloc, CheckoutState>(
              builder: (context, state) {
                return state.maybeWhen(
                  orElse: () => const SizedBox.shrink(),
                  success: (data, qty, total) {
                    return ValueListenableBuilder(
                      valueListenable: indexValue,
                      builder: (context, value, _) => Row(
                        children: [
                          const SpaceWidth(10.0),
                          MenuButton(
                            iconPath: Assets.icons.cash.path,
                            label: 'Tunai',
                            isActive: value == 1,
                            onPressed: () {
                              indexValue.value = 1;
                              context.read<OrderBloc>().add(
                                  OrderEvent.addPaymentMethod('Tunai', data));
                            },
                          ),
                          const SpaceWidth(10.0),
                          MenuButton(
                            iconPath: Assets.icons.qrCode.path,
                            label: 'QRIS',
                            isActive: value == 2,
                            onPressed: () {
                              indexValue.value = 2;
                              context.read<OrderBloc>().add(
                                  OrderEvent.addPaymentMethod('QRIS', data));
                            },
                          ),
                          const SpaceWidth(10.0),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
            const SpaceHeight(20.0),
            ProcessButton(
              price: 0,
              onPressed: () async {
                if (indexValue.value == 0) {
                } else if (indexValue.value == 1) {
                  showDialog(
                    context: context,
                    builder: (context) => PaymentCashDialog(price: totalPrice),
                  );
                } else if (indexValue.value == 2) {
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) => PaymentQrisDialog(price: totalPrice),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
