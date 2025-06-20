import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:media_scanner/media_scanner.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path/path.dart' as path;
import 'package:permission_handler/permission_handler.dart';
import 'package:open_file/open_file.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/constants/colors.dart';
import '../../order/models/order_model.dart';

Future<bool> requestStoragePermission() async {
  if (Platform.isAndroid) {
    if (await Permission.manageExternalStorage.isGranted) return true;

    final status = await Permission.manageExternalStorage.request();

    if (status.isGranted) {
      return true;
    } else {
      // ⛔ Jika tetap ditolak, arahkan user ke pengaturan
      await openAppSettings();
      return false;
    }
  }
  return true;
}

Future<void> exportFilteredOrdersToPDF({
  required List<OrderModel> orders,
  required DateTime startDate,
  required DateTime endDate,
  required String kasir,
  required BuildContext context,
}) async {
  final filteredOrders = orders.where((order) {
    final orderDate =
        DateTime.tryParse(order.transactionTime) ?? DateTime.now();
    return orderDate.isAfter(startDate.subtract(const Duration(days: 1))) &&
        orderDate.isBefore(endDate.add(const Duration(days: 1)));
  }).toList();

  if (filteredOrders.isEmpty) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text("Tidak ada transaksi dalam rentang tanggal tersebut.")),
      );
    }
    return;
  }

  await generatePdfLaporan(
    orders: filteredOrders,
    startDate: startDate,
    endDate: endDate,
    kasir: kasir,
    context: context,
  );
}

Future<void> generatePdfLaporan({
  required List<OrderModel> orders,
  required DateTime startDate,
  required DateTime endDate,
  required String kasir,
  required BuildContext context,
}) async {
  final pdf = pw.Document();
  final dateFormat = DateFormat('dd-MM-yyyy');
  final timeFormat = DateFormat('HH:mm');
  final currencyFormat =
      NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
  int grandTotal = 0;

  pdf.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      build: (context) => [
        pw.Text('Laporan Penjualan',
            style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 5),
        pw.Text(
            'Periode: ${dateFormat.format(startDate)} s/d ${dateFormat.format(endDate)}',
            style: const pw.TextStyle(fontSize: 12)),
        pw.SizedBox(height: 10),
        pw.Table.fromTextArray(
          headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          headers: [
            'No',
            'Produk',
            'Total Item',
            'Total Harga',
            'Kasir',
            'Waktu Transaksi'
          ],
          cellAlignment: pw.Alignment.topLeft,
          columnWidths: {
            0: const pw.FixedColumnWidth(30),
            2: const pw.FixedColumnWidth(50),
            3: const pw.FixedColumnWidth(80),
            4: const pw.FixedColumnWidth(60),
            5: const pw.FixedColumnWidth(90),
          },
          data: List.generate(orders.length, (index) {
            final order = orders[index];
            grandTotal += order.totalPrice;
            final produkText = order.orders
                .map((item) =>
                    '${item.name}\n${item.quantity} x ${currencyFormat.format(item.price)}')
                .join('\n\n');
            final transactionDateTime =
                DateTime.tryParse(order.transactionTime) ?? DateTime.now();
            return [
              '${index + 1}',
              produkText,
              '${order.totalQuantity}',
              currencyFormat.format(order.totalPrice),
              order.namaKasir,
              '${dateFormat.format(transactionDateTime)} ${timeFormat.format(transactionDateTime)}',
            ];
          }),
        ),
        pw.SizedBox(height: 10),
        pw.Container(
          alignment: pw.Alignment.centerRight,
          child: pw.Text(
              'Total Keseluruhan: ${currencyFormat.format(grandTotal)}',
              style:
                  pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
        ),
        pw.SizedBox(height: 20),
        pw.Container(
          alignment: pw.Alignment.centerRight,
          child: pw.Text(
              'Dicetak pada: ${dateFormat.format(DateTime.now())} ${timeFormat.format(DateTime.now())}\nOleh: $kasir',
              style: const pw.TextStyle(fontSize: 10)),
        ),
      ],
    ),
  );

  try {
    final granted = await requestStoragePermission();
    if (!granted) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Izin penyimpanan ditolak")),
        );
      }
      return;
    }

    // ✅ Simpan ke folder Download
    final downloadsDir = Directory('/storage/emulated/0/Download');

    if (!downloadsDir.existsSync()) {
      downloadsDir.createSync(recursive: true);
    }

    final filename =
        'laporan_transaksi_${DateTime.now().millisecondsSinceEpoch}.pdf';
    final filePath = path.join(downloadsDir.path, filename);
    final file = File(filePath);

    await file.writeAsBytes(await pdf.save());

    // ✅ Pindai file agar muncul di File Manager
    await MediaScanner.loadMedia(path: filePath);

    // ✅ Tampilkan info ke user
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("File berhasil disimpan ke folder Download"),
          backgroundColor: AppColors.primary,
          duration: Duration(milliseconds: 1500),
        ),
      );

      await Future.delayed(const Duration(milliseconds: 1500));

      if (!context.mounted) return;

      showModalBottomSheet(
        context: context,
        builder: (context) => SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.open_in_new),
                title: const Text('Buka File'),
                onTap: () async {
                  Navigator.pop(context);
                  await OpenFile.open(filePath);
                },
              ),
              ListTile(
                leading: const Icon(Icons.share),
                title: const Text('Bagikan File'),
                onTap: () async {
                  Navigator.pop(context);
                  await Share.shareFiles([filePath], text: 'Laporan Penjualan');
                },
              ),
            ],
          ),
        ),
      );
    }
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Gagal menyimpan file: ${e.toString()}"),
          backgroundColor: AppColors.red,
        ),
      );
    }
    print('❌ ERROR saat menyimpan PDF: ${e.toString()}');
  }
}
