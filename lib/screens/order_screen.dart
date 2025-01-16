import 'package:flutter/material.dart';

class OrderScreen extends StatelessWidget {
  const OrderScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> orders = [
      {
        'title': 'Kahvaltı Menüsü',
        'quantity': '2 Adet',
        'price': '120₺',
        'status': 'Hazırlanıyor',
      },
      {
        'title': 'Akşam Yemeği',
        'quantity': '1 Adet',
        'price': '75₺',
        'status': 'Teslim Edildi',
      },
      {
        'title': 'Tatlılar',
        'quantity': '3 Adet',
        'price': '150₺',
        'status': 'Hazırlanıyor',
      },
    ];

    double totalPrice = orders.fold(
        0,
        (sum, order) =>
            sum + double.parse(order['price']!.replaceAll('₺', '')));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Siparişler'),
        backgroundColor: Colors.deepOrange,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final order = orders[index];
                return _buildOrderCard(
                  context,
                  order['title']!,
                  order['quantity']!,
                  order['price']!,
                  order['status']!,
                  () {
                    // İptal Etme İşlevi
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content:
                            Text('${order['title']} siparişi iptal edildi!'),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          // Toplam Tutar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.deepOrange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start, // Sola hizalama
                children: [
                  const Text(
                    'Toplam Tutar:',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 16), // Araya boşluk ekliyoruz
                  Text(
                    '$totalPrice₺',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Ödeme Yap Butonu
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () {
                // Ödeme sayfasına yönlendirme
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PaymentScreen(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepOrange, // Buton rengi
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text(
                'Ödeme Yap',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(BuildContext context, String title, String quantity,
      String price, String status, VoidCallback onCancel) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Sipariş Görseli
            CircleAvatar(
              radius: 30,
              backgroundColor: Colors.deepOrange.withOpacity(0.2),
              child: const Icon(Icons.fastfood, color: Colors.deepOrange),
            ),
            const SizedBox(width: 16),
            // Sipariş Bilgileri
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Miktar: $quantity',
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Durum: $status',
                    style: TextStyle(
                      color: status == 'Hazırlanıyor'
                          ? Colors.orange
                          : Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            // Fiyat ve İptal Butonu
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  price,
                  style: const TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                if (status == 'Hazırlanıyor')
                  TextButton(
                    onPressed: onCancel,
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.red,
                    ),
                    child: const Text('İptal Et'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Ödeme Sayfası
class PaymentScreen extends StatefulWidget {
  const PaymentScreen({Key? key}) : super(key: key);

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _expiryController = TextEditingController();
  final TextEditingController _cvvController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ödeme Yap'),
        backgroundColor: Colors.deepOrange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Ad ve Soyad
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Ad Soyad',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Lütfen adınızı ve soyadınızı girin';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Kart Numarası
              TextFormField(
                controller: _cardNumberController,
                decoration: const InputDecoration(
                  labelText: 'Kart Numarası',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Lütfen kart numaranızı girin';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Son Kullanma Tarihi
              TextFormField(
                controller: _expiryController,
                decoration: const InputDecoration(
                  labelText: 'Son Kullanma Tarihi (MM/YY)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.datetime,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Lütfen son kullanma tarihini girin';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // CVV
              TextFormField(
                controller: _cvvController,
                decoration: const InputDecoration(
                  labelText: 'CVV',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Lütfen CVV kodunu girin';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Ödeme Yap Butonu
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    // Ödeme işlemi
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Ödeme başarılı!')),
                    );
                    // Burada ödeme işlemi yapılabilir.
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrange,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text(
                  'Ödemeyi Tamamla',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
