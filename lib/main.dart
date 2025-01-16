import 'package:dialogflow_flutter/googleAuth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:dialogflow_flutter/dialogflowFlutter.dart'; // Dialogflow SDK eklendi

import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/home_screen.dart';
import 'screens/qr_scan_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/order_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const RestaurantApp());
}

class RestaurantApp extends StatelessWidget {
  const RestaurantApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Restaurant App',
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => const MainScreen(),
      },
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  bool _isChatOpen = false;
  final List<Map<String, String>> _messages = []; // Mesaj listesi
  final TextEditingController _messageController = TextEditingController();

  final List<Widget> _screens = [
    const HomeScreen(),
    const QRScanScreen(),
    const OrderScreen(),
    const ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _sendMessage(String message) async {
    setState(() {
      _messages.add({'role': 'user', 'message': message});
    });

    _messageController.clear();

    try {
      // Dialogflow için doğru yapılandırmayı ekliyoruz
      AuthGoogle authGoogle = await AuthGoogle(
        fileJson:
            "assets/fiery-orb-446117-a6-d22d86b170d6.json", // Dialogflow anahtar dosyası
      ).build();

      // Türkçe dil desteği için language parametresi değiştirilmiştir
      DialogFlow dialogflow = DialogFlow(
          authGoogle: authGoogle, language: 'tr'); // Türkçe dil parametresi

      AIResponse response = await dialogflow.detectIntent(message);

      setState(() {
        _messages.add({
          'role': 'bot',
          'message':
              response.getMessage() ?? "Anlayamadım, lütfen tekrar deneyin.",
        });
      });
    } catch (e) {
      setState(() {
        _messages.add({
          'role': 'bot',
          'message': 'Bir hata oluştu, lütfen tekrar deneyin.'
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _screens[_selectedIndex],
          if (_isChatOpen) _buildChatWindow(),
        ],
      ),
      floatingActionButton: Draggable(
        feedback: Material(
          color: Colors.transparent,
          child: FloatingActionButton(
            backgroundColor: const Color(0xFFD32F2F),
            onPressed: () {},
            child: const Icon(Icons.chat, color: Colors.white),
          ),
        ),
        childWhenDragging: const SizedBox.shrink(),
        onDragEnd: (details) {
          setState(() {
            // Optional: Keep chat button position based on the user's drag
            // You can save the position of the icon here if needed
          });
        },
        child: FloatingActionButton(
          onPressed: () {
            setState(() {
              _isChatOpen = !_isChatOpen;
            });
          },
          backgroundColor: const Color(0xFFD32F2F),
          child: const Icon(Icons.chat, color: Colors.white),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFFFAE3E3),
        selectedItemColor: const Color(0xFFD32F2F),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.restaurant_menu),
            label: 'Menü',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.qr_code_scanner),
            label: 'QR Oku',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Siparişler',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }

  Widget _buildChatWindow() {
    return Positioned(
      bottom: 80, // Buton biraz daha yukarıya taşındı
      right: 20,
      child: Container(
        width: 300,
        height: 400,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(2, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFD32F2F),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Sohbet',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _isChatOpen = false;
                      });
                    },
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final message = _messages[index];
                  final isUser = message['role'] == 'user';
                  return Container(
                    margin:
                        const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                    alignment:
                        isUser ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isUser ? Colors.green[200] : Colors.grey[300],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        message['message']!,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: 'Mesaj yazın...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      final message = _messageController.text.trim();
                      if (message.isNotEmpty) {
                        _sendMessage(message);
                      }
                    },
                    icon: const Icon(Icons.send, color: Color(0xFFD32F2F)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
