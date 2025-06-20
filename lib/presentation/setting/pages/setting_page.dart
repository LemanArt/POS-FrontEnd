import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_pos_app/core/extensions/build_context_ext.dart';
// import 'package:flutter_pos_app/presentation/setting/pages/manage_product_page.dart';
import '../../../core/assets/assets.gen.dart';
import '../../../data/datasources/auth_local_datasource.dart';
import '../../../data/models/response/auth_response_model.dart';
import '../../auth/bloc/logout/logout_bloc.dart';
import '../../auth/pages/login_page.dart';
import '../widgets/settingTile.dart';
import 'manage_printer_page.dart';
import 'save_server_key_page.dart';
import 'sync_data_page.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Konfirmasi Logout'),
          content: const Text('Apakah Anda yakin ingin logout?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // batal
              },
              child: const Text('Tidak'),
            ),
            TextButton(
              onPressed: () {
                context.read<LogoutBloc>().add(const LogoutEvent.logout());
                Navigator.of(context).pop(); // tutup dialog
              },
              child: const Text('Ya'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildUserInfo(AuthResponseModel auth) {
    final user = auth.user;

    return Column(
      children: [
        Text(
          user.name,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        Text(
          user.roles,
          style: const TextStyle(fontSize: 14, color: Colors.grey),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Setting',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // LOGO APLIKASI
            Center(
              child: Image.asset(
                Assets.images.logo.path,
                height: 100,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Titip Penatmu Disini !',
              style: TextStyle(
                fontSize: 14,
                fontStyle: FontStyle.normal,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 10),

            // USER INFO
            // FutureBuilder<AuthResponseModel>(
            //   future: AuthLocalDatasource().getAuthData(),
            //   builder: (context, snapshot) {
            //     if (snapshot.connectionState == ConnectionState.waiting) {
            //       return const CircularProgressIndicator();
            //     } else if (!snapshot.hasData) {
            //       return const Text('Tidak ada data user');
            //     }

            //     return _buildUserInfo(snapshot.data!);
            //   },
            // ),

            // MENU SETTING
            // SettingTile(
            //   iconPath: Assets.images.manageProduct.path,
            //   title: 'Kelola Produk',
            //   subtitle: 'Detail Produk dan Tambah produk baru',
            //   onPressed: () {
            //     context.push(const ManageProductPage());
            //   },
            // ),
            SettingTile(
              iconPath: Assets.images.synclogo.path,
              title: 'Sinkronisasi Data',
              subtitle: 'Sinkronkan data lokal dengan server pusat.',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SyncDataPage()),
                );
              },
            ),
            SettingTile(
              iconPath: Assets.images.managePrinter.path,
              title: 'Kelola Printer',
              subtitle: 'Atur koneksi dan pengaturan printer thermal.',
              onPressed: () {
                context.push(const ManagePrinterPage());
              },
            ),
            SettingTile(
              iconPath: Assets.images.serverkey.path,
              title: 'QRIS Server Key',
              subtitle: 'Setel koneksi server QRIS secara aman.',
              onPressed: () {
                context.push(const SaveServerKeyPage());
              },
            ),
            SettingTile(
              iconPath: Assets.images.logout.path,
              title: 'Logout',
              subtitle: 'Keluar dari aplikasi',
              onPressed: _showLogoutDialog,
            ),

            // HANDLE LOGOUT SUCCESS
            BlocConsumer<LogoutBloc, LogoutState>(
              listener: (context, state) {
                state.maybeMap(
                  orElse: () {},
                  success: (_) {
                    AuthLocalDatasource().removeAuthData();
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginPage()),
                    );
                  },
                );
              },
              builder: (context, state) {
                return const SizedBox.shrink(); // Tidak menampilkan apapun
              },
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
