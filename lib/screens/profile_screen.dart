import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final user = FirebaseAuth.instance.currentUser;
  List<String> allergies = [];
  List<String> illnesses = [];

  @override
  void initState() {
    super.initState();
    _fetchHealthData();
  }

  Future<void> _fetchHealthData() async {
    if (user == null) return;

    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .get();

      if (doc.exists && doc.data() != null) {
        setState(() {
          allergies = List<String>.from(doc.get('allergies') ?? []);
          illnesses = List<String>.from(doc.get('illnesses') ?? []);
        });
      }
    } catch (e) {
      print("❌ Firestore'dan veriler alınırken hata oluştu: $e");
    }
  }

  void _navigateToHealthManagement() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HealthManagementScreen(
          userId: user?.uid,
          onUpdate: _fetchHealthData,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text("Profil", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.redAccent,
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.settings, color: Colors.white),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Ayarlar Yakında Eklenecek!")),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 10),
            Card(
              margin: EdgeInsets.all(16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              elevation: 4,
              child: ListTile(
                leading: CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.redAccent,
                  child: Text(
                    user?.displayName?.substring(0, 1).toUpperCase() ?? '?',
                    style: const TextStyle(
                        fontSize: 30,
                        color: Colors.white,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                title: Text(user?.displayName ?? 'Bilinmiyor',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(user?.email ?? 'Bilinmiyor'),
              ),
            ),
            _buildSectionTitle("Alerji ve Hastalık Yönetimi"),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ElevatedButton(
                onPressed: _navigateToHealthManagement,
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12))),
                child:
                    const Text("Yönet", style: TextStyle(color: Colors.white)),
              ),
            ),
            _buildSectionTitle("Geçmiş Siparişler"),
            _buildOrderHistory(),
            _buildSectionTitle("Ödeme Yöntemleri"),
            _buildPaymentMethods(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.redAccent),
        ),
      ),
    );
  }

  Widget _buildOrderHistory() {
    return Column(
      children: List.generate(3, (index) {
        return Card(
          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            title: Text("Sipariş #${index + 1}"),
            subtitle: Text("Burger + Kola - 75₺"),
            trailing: Icon(Icons.fastfood, color: Colors.orange),
          ),
        );
      }),
    );
  }

  Widget _buildPaymentMethods() {
    return Column(
      children: [
        Card(
          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            title: Text("Visa **** 1234"),
            trailing: Icon(Icons.credit_card, color: Colors.blue),
          ),
        ),
        Card(
          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            title: Text("MasterCard **** 5678"),
            trailing: Icon(Icons.credit_card, color: Colors.green),
          ),
        ),
      ],
    );
  }
}

class HealthManagementScreen extends StatefulWidget {
  final String? userId;
  final VoidCallback onUpdate;

  const HealthManagementScreen(
      {Key? key, required this.userId, required this.onUpdate})
      : super(key: key);

  @override
  _HealthManagementScreenState createState() => _HealthManagementScreenState();
}

class _HealthManagementScreenState extends State<HealthManagementScreen> {
  final TextEditingController _allergyController = TextEditingController();
  final TextEditingController _illnessController = TextEditingController();
  List<String> allergies = [];
  List<String> illnesses = [];

  @override
  void initState() {
    super.initState();
    _fetchHealthData();
  }

  Future<void> _fetchHealthData() async {
    if (widget.userId == null) return;

    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .get();

      if (doc.exists && doc.data() != null) {
        setState(() {
          allergies = List<String>.from(doc.get('allergies') ?? []);
          illnesses = List<String>.from(doc.get('illnesses') ?? []);
        });
      }
    } catch (e) {
      print("❌ Firestore'dan veriler alınırken hata oluştu: $e");
    }
  }

  Future<void> _saveAllergy() async {
    final allergy = _allergyController.text.trim();
    if (allergy.isEmpty) {
      _showSnackbar("Lütfen bir alerji giriniz!", Colors.orange);
      return;
    }

    if (widget.userId == null) return;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .set({
      'allergies': FieldValue.arrayUnion([allergy]),
    }, SetOptions(merge: true));

    _showSnackbar("Alerji başarıyla eklendi!", Colors.green);
    _allergyController.clear();
    _fetchHealthData();
  }

  Future<void> _saveIllness() async {
    final illness = _illnessController.text.trim();
    if (illness.isEmpty) {
      _showSnackbar("Lütfen bir hastalık giriniz!", Colors.orange);
      return;
    }

    if (widget.userId == null) return;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .set({
      'illnesses': FieldValue.arrayUnion([illness]),
    }, SetOptions(merge: true));

    _showSnackbar("Hastalık başarıyla eklendi!", Colors.green);
    _illnessController.clear();
    _fetchHealthData();
  }

  Future<void> _removeItem(int index, bool isAllergy) async {
    if (widget.userId == null) return;

    try {
      String removedItem = isAllergy ? allergies[index] : illnesses[index];

      setState(() {
        isAllergy ? allergies.removeAt(index) : illnesses.removeAt(index);
      });

      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .update({
        isAllergy ? 'allergies' : 'illnesses':
            isAllergy ? allergies : illnesses,
      });

      _showSnackbar("$removedItem başarıyla silindi!", Colors.red);
    } catch (e) {
      print("❌ Silme hatası: $e");
    }
  }

  void _showSnackbar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text("Alerji & Hastalık Yönetimi",
            style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.redAccent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle("Alerji Ekle"),
              _buildInputField(
                  _allergyController, "Alerji Giriniz", Icons.warning_amber),
              const SizedBox(height: 8),
              _buildSaveButton(
                  "Alerjiyi Kaydet", Colors.redAccent, _saveAllergy),
              const SizedBox(height: 24),
              _buildSectionTitle("Hastalık Ekle"),
              _buildInputField(_illnessController, "Hastalık Giriniz",
                  Icons.medical_services),
              const SizedBox(height: 8),
              _buildSaveButton(
                  "Hastalığı Kaydet", Colors.blueAccent, _saveIllness),
              const SizedBox(height: 24),
              _buildSectionTitle("Kayıtlı Alerjiler"),
              _buildList(allergies, true),
              const SizedBox(height: 16),
              _buildSectionTitle("Kayıtlı Hastalıklar"),
              _buildList(illnesses, false),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: TextStyle(
            fontSize: 22, fontWeight: FontWeight.bold, color: Colors.redAccent),
      ),
    );
  }

  Widget _buildInputField(
      TextEditingController controller, String hint, IconData icon) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.redAccent),
        labelText: hint,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildSaveButton(String text, Color color, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(backgroundColor: color),
        child: Text(text, style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildList(List<String> items, bool isAllergy) {
    return items.isEmpty
        ? Text("Henüz eklenmedi.", style: TextStyle(color: Colors.grey))
        : Column(
            children: items.map((item) {
              return Dismissible(
                key: Key(item),
                direction: DismissDirection.endToStart,
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: EdgeInsets.only(right: 20),
                  child: Icon(Icons.delete, color: Colors.white),
                ),
                onDismissed: (direction) {
                  _removeItem(items.indexOf(item), isAllergy);
                },
                child: Card(
                  margin: EdgeInsets.symmetric(vertical: 4),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    title: Text(item),
                    trailing: IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () =>
                          _removeItem(items.indexOf(item), isAllergy),
                    ),
                  ),
                ),
              );
            }).toList(),
          );
  }
}
