import 'package:flutter/material.dart';
import '../data/supabase_service.dart';
import '../models/toy.dart';
import '../login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _supabaseService = SupabaseService();
  Map<String, dynamic>? _profile;
  List<Toy> _allToys = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchProfileAndStats();
  }

  Future<void> _fetchProfileAndStats() async {
    setState(() => _isLoading = true);
    final user = _supabaseService.currentUser;
    if (user != null) {
      final profile = await _supabaseService.getProfile(user.id);
      _profile = profile;

      // Admin ise istatistikleri hesaplamak için tüm oyuncakları çek
      if (_profile?['role'] == 'admin') {
        _allToys = await _supabaseService.getToys();
      }

      setState(() => _isLoading = false);
    } else {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading)
      return const Scaffold(body: Center(child: CircularProgressIndicator()));

    final bool isAdmin = _profile?['role'] == 'admin';

    // İstatistik hesaplamaları
    int totalStock = _allToys.fold(0, (sum, item) => sum + item.stock);
    double totalValue = _allToys.fold(
      0,
      (sum, item) => sum + (item.price * item.stock),
    );
    int lowStockCount = _allToys.where((toy) => toy.stock < 5).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil & Özet'),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 60,
              backgroundColor: Colors.blueAccent,
              child: Icon(Icons.person, size: 80, color: Colors.white),
            ),
            const SizedBox(height: 20),
            Text(
              _profile?['full_name'] ?? 'Kullanıcı Adı',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(
              isAdmin ? 'Mağaza Yöneticisi (Admin)' : 'Müşteri',
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 30),
            const Divider(),
            const SizedBox(height: 20),

            // Kişisel Bilgiler (Herkes Görür)
            _buildInfoCard(
              title: 'E-posta',
              value: _supabaseService.currentUser?.email ?? '-',
              icon: Icons.email,
              color: Colors.blue,
            ),
            _buildInfoCard(
              title: 'Telefon',
              value: _profile?['phone'] ?? '-',
              icon: Icons.phone,
              color: Colors.orange,
            ),

            // Sadece Admin İstatistikleri
            if (isAdmin) ...[
              const SizedBox(height: 20),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Mağaza Özeti',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 15),
              _buildInfoCard(
                title: 'Toplam Oyuncak Türü',
                value: _allToys.length.toString(),
                icon: Icons.category,
                color: Colors.purple,
              ),
              _buildInfoCard(
                title: 'Toplam Stok Adedi',
                value: totalStock.toString(),
                icon: Icons.inventory_2,
                color: Colors.orange,
              ),
              _buildInfoCard(
                title: 'Toplam Envanter Değeri',
                value: '₺${totalValue.toStringAsFixed(2)}',
                icon: Icons.account_balance_wallet,
                color: Colors.green,
              ),
              _buildInfoCard(
                title: 'Kritik Stok Uyarısı',
                value: '$lowStockCount Ürün',
                icon: Icons.warning_amber_rounded,
                color: Colors.red,
              ),
            ],

            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () async {
                  await _supabaseService.signOut();
                  if (mounted) {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (context) => const LoginScreen(),
                      ),
                      (route) => false,
                    );
                  }
                },
                icon: const Icon(Icons.logout),
                label: const Text('ÇIKIŞ YAP'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 15),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.1),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
        trailing: Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ),
    );
  }
}
