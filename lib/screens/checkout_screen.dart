import 'package:flutter/material.dart';
import '../data/supabase_service.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _surnameController = TextEditingController();
  final _cardNoController = TextEditingController();
  final _cvvController = TextEditingController();
  final _supabaseService = SupabaseService();

  Future<void> _completePurchase() async {
    if (_formKey.currentState!.validate()) {
      final user = _supabaseService.currentUser;
      if (user != null) {
        await _supabaseService.clearCart(user.id);
      }
      
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: const Text('Sipariş Alındı!'),
            content: const Text('Siparişiniz başarıyla alındı. Ana sayfaya yönlendiriliyorsunuz.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                child: const Text('TAMAM'),
              ),
            ],
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ödeme'),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const Text('Kişisel Bilgiler', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'İsim', border: OutlineInputBorder()),
                validator: (value) => value!.isEmpty ? 'Lütfen isminizi girin' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _surnameController,
                decoration: const InputDecoration(labelText: 'Soyisim', border: OutlineInputBorder()),
                validator: (value) => value!.isEmpty ? 'Lütfen soyisminizi girin' : null,
              ),
              const SizedBox(height: 20),
              const Text('Kart Bilgileri', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              TextFormField(
                controller: _cardNoController,
                decoration: const InputDecoration(labelText: 'Kart Numarası', border: OutlineInputBorder()),
                keyboardType: TextInputType.number,
                validator: (value) => value!.length < 16 ? 'Geçerli bir kart numarası girin' : null,
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      decoration: const InputDecoration(labelText: 'Son Kullanma (AA/YY)', border: OutlineInputBorder()),
                      validator: (value) => value!.isEmpty ? 'Gerekli' : null,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: _cvvController,
                      decoration: const InputDecoration(labelText: 'CVV', border: OutlineInputBorder()),
                      keyboardType: TextInputType.number,
                      validator: (value) => value!.length != 3 ? 'Geçerli CVV girin' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _completePurchase,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                child: const Text('ÖDEMEYİ TAMAMLA', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
