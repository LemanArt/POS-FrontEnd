import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_pos_app/core/extensions/int_ext.dart';
import 'package:flutter_pos_app/presentation/home/models/order_item.dart';
import '../../../core/components/spaces.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/variables.dart';
import '../../home/bloc/checkout/checkout_bloc.dart';

class OrderCard extends StatelessWidget {
  final OrderItem data;
  final VoidCallback onDeleteTap; // Callback untuk menghapus produk
  final EdgeInsetsGeometry? padding;

  const OrderCard({
    super.key,
    required this.data,
    required this.onDeleteTap,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        Container(
          margin: padding,
          padding: const EdgeInsets.all(16.0),
          decoration: ShapeDecoration(
            color: const Color.fromARGB(255, 248, 246, 246),
            shape: RoundedRectangleBorder(
              side: const BorderSide(width: 2, color: Color(0xFFD7CCC8)),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: Row(
            children: [
              ClipRRect(
                  borderRadius: const BorderRadius.all(Radius.circular(50.0)),
                  child: CachedNetworkImage(
                    width: 76,
                    height: 76,
                    fit: BoxFit.cover,
                    imageUrl: '${Variables.ImagebaseUrl}${data.product.image}',
                    placeholder: (context, url) =>
                        const CircularProgressIndicator(),
                    errorWidget: (context, url, error) => const Icon(
                      Icons.food_bank_outlined,
                      size: 80,
                    ),
                  )),
              const SpaceWidth(24.0),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          data.product.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          data.product.price.currencyFormatRp,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SpaceHeight(20.0),
                    StatefulBuilder(
                      builder: (context, setState) => Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              if (data.quantity > 1) {
                                // Langsung kurangi jumlah
                                context.read<CheckoutBloc>().add(
                                    CheckoutEvent.removeCheckout(data.product));
                              } else {
                                // Tampilkan konfirmasi hapus kalau quantity == 1
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title:
                                          const Text("Konfirmasi Hapus Produk"),
                                      content: const Text(
                                          "Apakah Anda ingin menghapus produk ini dari pesanan?"),
                                      actions: <Widget>[
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.of(context).pop(),
                                          child: const Text('Tidak'),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            context.read<CheckoutBloc>().add(
                                                CheckoutEvent
                                                    .removeOrderCompletely(
                                                        data.product));
                                            Navigator.of(context).pop();
                                          },
                                          child: const Text('Ya'),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              }
                            },
                            child: Container(
                              color: AppColors.white,
                              child: const Icon(
                                Icons.remove_circle,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 40.0,
                            child: Center(
                              child: Text(data.quantity.toString()),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              context
                                  .read<CheckoutBloc>()
                                  .add(CheckoutEvent.addCheckout(data.product));
                            },
                            child: Container(
                              color: AppColors.white,
                              child: const Icon(
                                Icons.add_circle,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 16.0),
          child: IconButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text("Konfirmasi Hapus Produk"),
                    content: const Text(
                        "Apakah Anda yakin ingin menghapus produk ini?"),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Tidak'),
                      ),
                      TextButton(
                        onPressed: () {
                          context.read<CheckoutBloc>().add(
                              CheckoutEvent.removeOrderCompletely(
                                  data.product));
                          Navigator.of(context).pop();
                        },
                        child: const Text('Ya'),
                      ),
                    ],
                  );
                },
              );
            },
            icon: const Icon(
              Icons.highlight_off,
              color: AppColors.primary,
            ),
          ),
        ),
      ],
    );
  }
}
