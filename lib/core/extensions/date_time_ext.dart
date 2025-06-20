import 'package:intl/intl.dart';

extension DateTimeExt on DateTime {
  // Yang sudah ada
  String toFormattedTime() {
    final List<String> monthNames = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember'
    ];

    final int hour12 = hour % 12;
    final String monthName = monthNames[month - 1];

    return '$day $monthName, ${hour12.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
  }

  // Tambahan baru: untuk mengelompokkan berdasarkan waktu historis
  String toRelativeGroup() {
    final now = DateTime.now();
    final difference = now.difference(this);

    if (difference.inDays == 0) {
      return 'Hari ini';
    } else if (difference.inDays == 1) {
      return 'Kemarin';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} hari yang lalu';
    } else if (difference.inDays < 14) {
      return 'Minggu lalu';
    } else if (difference.inDays < 30) {
      return 'Bulan ini';
    } else if (difference.inDays < 60) {
      return 'Bulan lalu';
    } else {
      // Format bulan & tahun (misal: Januari 2024)
      final List<String> monthNames = [
        'Januari',
        'Februari',
        'Maret',
        'April',
        'Mei',
        'Juni',
        'Juli',
        'Agustus',
        'September',
        'Oktober',
        'November',
        'Desember'
      ];
      return '${monthNames[month - 1]} $year';
    }
  }
}

extension FormatTanggalJam on String {
  String get formatTanggalJam {
    try {
      final cleaned = trim();
      final dt = DateTime.tryParse(cleaned);
      if (dt == null) return this;

      return DateFormat('d MMM HH:mm', 'id_ID').format(dt);
    } catch (e) {
      return this;
    }
  }
}
