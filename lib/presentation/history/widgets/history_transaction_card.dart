import 'package:flutter/material.dart';
import '../../../core/assets/assets.gen.dart';
import '../../../core/constants/colors.dart';
import '../../order/models/order_model.dart';
import '../../../core/extensions/int_ext.dart';

class HistoryTransactionCard extends StatelessWidget {
  final EdgeInsets padding;
  final OrderModel data;

  const HistoryTransactionCard({
    super.key,
    required this.padding,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.white,
      margin: const EdgeInsets.symmetric(vertical: 2.0),
      child: Padding(
        padding: padding,
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16),
          leading: Assets.icons.payments.svg(),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(data.paymentMethod),
              Text(
                '${data.totalQuantity} items',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                data.totalPrice.currencyFormatRp,
                style: const TextStyle(
                  color: AppColors.green,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.expand_more), // panah ekspansi
            ],
          ),
          children: [
            if (data.orders.isNotEmpty)
              ...data.orders.map((orderItem) {
                return ListTile(
                    title: Text(orderItem.product.name),
                    subtitle: Text(
                        '${orderItem.quantity} x ${orderItem.price.currencyFormatRp}'),
                    trailing: Text(
                      (orderItem.price * orderItem.quantity).currencyFormatRp,
                      style: const TextStyle(
                        color: AppColors.green,
                        fontWeight: FontWeight.w900,
                      ),
                    ));
              }),
            ListTile(
              title: Text('Total Harga: ${data.totalPrice.currencyFormatRp}'),
            ),
            if (data.orders.isEmpty)
              const ListTile(
                title: Text('Tidak ada produk yang dipesan'),
              ),
          ],
        ),
      ),
    );
  }
}
