import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/components/spaces.dart';
import '../../home/bloc/product/product_bloc.dart';
import '../widgets/menu_product_item.dart';
import 'add_product_page.dart';

class ManageProductPage extends StatefulWidget {
  const ManageProductPage({super.key});

  @override
  State<ManageProductPage> createState() => _ManageProductPageState();
}

class _ManageProductPageState extends State<ManageProductPage> {
  @override
  void initState() {
    super.initState();
    // Memanggil event fetch untuk mendapatkan produk
    context.read<ProductBloc>().add(const ProductEvent.fetch());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kelola Produk'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24.0),
        children: [
          const Text(
            'List Produk',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SpaceHeight(20.0),
          BlocBuilder<ProductBloc, ProductState>(
            builder: (context, state) {
              return state.maybeWhen(
                orElse: () {
                  return const Center(
                    child: CircularProgressIndicator(), // Menampilkan loading
                  );
                },
                success: (products) {
                  return ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: products.length,
                    separatorBuilder: (context, index) =>
                        const SpaceHeight(20.0),
                    itemBuilder: (context, index) => MenuProductItem(
                      data: products[index],
                    ),
                  );
                },
                error: (message) {
                  return Center(
                    child: Text(
                      'Error loading products: $message',
                      style: const TextStyle(color: Colors.red),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return const AddProductPage();
          }));
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
