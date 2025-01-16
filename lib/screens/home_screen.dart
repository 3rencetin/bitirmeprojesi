import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'qr_scan_screen.dart';
import 'profile_screen.dart';
import 'order_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const MenuScreen(), // Ana ekran olarak MenuScreen kullanılıyor
      appBar: AppBar(
        backgroundColor: const Color(0xFFFAE3E3),
        centerTitle: true,
        title: const Text(
          'Restaurant Home',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFFD32F2F),
          ),
        ),
        leading: Builder(
          builder: (ctx) => IconButton(
            icon: const Icon(Icons.menu, color: Color(0xFFD32F2F)),
            onPressed: () {
              Scaffold.of(ctx).openDrawer();
            },
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications, color: Color(0xFFD32F2F)),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Bildirimlere tıklandı!')),
              );
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              decoration: const BoxDecoration(
                color: Color(0xFFFAE3E3),
              ),
              accountName: Text(user?.displayName ?? 'Kullanıcı',
                  style: const TextStyle(color: Color(0xFFD32F2F))),
              accountEmail: Text(user?.email ?? 'Email Yok',
                  style: const TextStyle(color: Color(0xFFD32F2F))),
              currentAccountPicture: const CircleAvatar(
                backgroundColor: Color(0xFFD32F2F),
                child: Icon(Icons.person, size: 40, color: Color(0xFFFAE3E3)),
              ),
            ),
            ListTile(
              leading:
                  const Icon(Icons.restaurant_menu, color: Color(0xFFD32F2F)),
              title: const Text('Menü'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MenuScreen()),
                );
              },
            ),
            ListTile(
              leading:
                  const Icon(Icons.qr_code_scanner, color: Color(0xFFD32F2F)),
              title: const Text('QR Oku'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const QRScanScreen()),
                );
              },
            ),
            ListTile(
              leading:
                  const Icon(Icons.shopping_cart, color: Color(0xFFD32F2F)),
              title: const Text('Siparişler'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const OrderScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.person, color: Color(0xFFD32F2F)),
              title: const Text('Profil'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const ProfileScreen()),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.exit_to_app, color: Color(0xFFD32F2F)),
              title: const Text('Çıkış'),
              onTap: () {
                Navigator.pop(context);
                FirebaseAuth.instance.signOut();
                Navigator.pushReplacementNamed(context, '/login');
              },
            ),
          ],
        ),
      ),
    );
  }
}

class MenuScreen extends StatelessWidget {
  const MenuScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFFCDD2),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(2, 4),
                ),
              ],
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Hoş geldin, ${FirebaseAuth.instance.currentUser?.displayName ?? 'Kullanıcı'}!',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFD32F2F),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Menüler',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFD32F2F),
                ),
              ),
              TextButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Tüm menüler gösteriliyor!')),
                  );
                },
                child: const Text(
                  'Tümünü Gör',
                  style: TextStyle(color: Color(0xFFFAE3E3)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              'Kahvaltı',
              'Öğle Yemeği',
              'Akşam Yemeği',
              'Tatlılar',
              'İçecekler',
            ].map((menuName) {
              return GestureDetector(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('$menuName menüsüne tıklandı!')),
                  );
                },
                child: Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFAE3E3),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFD32F2F)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 6,
                        offset: const Offset(2, 3),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      menuName,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Color(0xFFD32F2F),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
