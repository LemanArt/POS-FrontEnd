import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/components/spaces.dart';
import '../../order/models/order_model.dart';
import '../bloc/history/history_bloc.dart';
import '../utils/export_pdf.dart';
import '../widgets/history_transaction_card.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  List<OrderModel> allOrders = [];

  @override
  void initState() {
    super.initState();
    context.read<HistoryBloc>().add(const HistoryEvent.fetch());
  }

  Map<String, List<OrderModel>> groupOrders(List<OrderModel> orders) {
    final today = DateTime.now();
    final startOfWeek = today.subtract(Duration(days: today.weekday - 1));
    final startOfMonth = DateTime(today.year, today.month, 1);

    final Map<String, List<OrderModel>> grouped = {
      'Hari Ini': [],
      'Minggu Ini': [],
      'Bulan Ini': [],
    };

    for (var order in orders) {
      final orderDate = DateTime.parse(order.transactionTime);
      if (_isSameDay(orderDate, today)) {
        grouped['Hari Ini']!.add(order);
      } else if (orderDate.isAfter(startOfWeek)) {
        grouped['Minggu Ini']!.add(order);
      } else if (orderDate.isAfter(startOfMonth)) {
        grouped['Bulan Ini']!.add(order);
      }
    }

    return grouped;
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  Future<void> _showExportOptions(BuildContext context) async {
    final startDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 7)),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      helpText: 'Pilih tanggal mulai',
    );

    if (startDate == null) return;

    final endDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: startDate,
      lastDate: DateTime.now(),
      helpText: 'Pilih tanggal akhir',
    );

    if (endDate == null) return;

    await exportFilteredOrdersToPDF(
      context: context,
      orders: allOrders,
      startDate: startDate,
      kasir:
          allOrders.isNotEmpty ? allOrders.first.namaKasir : 'Tidak diketahui',
      endDate: endDate,
    );
  }

  @override
  Widget build(BuildContext context) {
    const paddingHorizontal = EdgeInsets.symmetric(horizontal: 16.0);

    return Scaffold(
      appBar: AppBar(
        title: const Text('History Orders',
            style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () => _showExportOptions(context),
            icon: const Icon(Icons.picture_as_pdf),
            tooltip: 'Export PDF',
          )
        ],
      ),
      body: BlocBuilder<HistoryBloc, HistoryState>(
        builder: (context, state) {
          return state.maybeWhen(
            orElse: () => const Center(child: Text('No data')),
            loading: () => const Center(child: CircularProgressIndicator()),
            success: (data) {
              allOrders = data;

              if (data.isEmpty) {
                return const Center(child: Text('No data'));
              }

              final grouped = groupOrders(data);

              return ListView(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                children: grouped.entries
                    .where((e) => e.value.isNotEmpty)
                    .map((entry) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 8.0),
                        child: Text(entry.key,
                            style: const TextStyle(
                                fontSize: 18.0, fontWeight: FontWeight.bold)),
                      ),
                      ...entry.value.map((order) => Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: HistoryTransactionCard(
                              padding: paddingHorizontal,
                              data: order,
                            ),
                          )),
                      const SpaceHeight(16.0),
                    ],
                  );
                }).toList(),
              );
            },
          );
        },
      ),
    );
  }
}
