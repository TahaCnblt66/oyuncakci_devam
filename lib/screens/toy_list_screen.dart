import 'package:flutter/material.dart';
import '../models/toy.dart';
import '../data/supabase_service.dart';
import 'toy_detail_screen.dart';
import 'toy_form_screen.dart';
import 'profile_screen.dart';
import 'cart_screen.dart';

class ToyListScreen extends StatefulWidget {
  const ToyListScreen({super.key});

  @override
  State<ToyListScreen> createState() => _ToyListScreenState();
}

class _ToyListScreenState extends State<ToyListScreen> {
  final _supabaseService = SupabaseService();
  List<Toy> _toys = [];
  bool _isLoading = true;
  String? _userRole;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    try {
      // Önce oyuncakları çek (Profil hatası olsa bile bunlar gelmeli)
      final toys = await _supabaseService.getToys();

      // Sonra kullanıcı rolünü çekmeye çalış
      final user = _supabaseService.currentUser;
      String? role;
      if (user != null) {
        try {
          final profile = await _supabaseService.getProfile(user.id);
          role = profile?['role'];
        } catch (profileError) {
          print(
            "Profil çekilemedi (Muhtemelen henüz oluşturulmadı): $profileError",
          );
          // Profil yoksa varsayılan olarak müşteri rolü ver
          role = 'customer';
        }
      }

      setState(() {
        _toys = toys;
        _userRole = role;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Hata: $e ")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'Oyuncak Listesi',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CartScreen()),
              ).then((_) => _fetchData());
            },
          ),
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              ).then((_) => _fetchData());
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _toys.isEmpty
          ? const Center(child: Text("Henüz oyuncak eklenmemiş."))
          : RefreshIndicator(
              onRefresh: _fetchData,
              child: ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: _toys.length,
                itemBuilder: (context, index) {
                  final toy = _toys[index];
                  return Card(
                    elevation: 4,
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(10),
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: toy.imageUrl.startsWith('http')
                            ? Image.network(
                                toy.imageUrl,
                                width: 60,
                                height: 60,
                                fit: BoxFit.cover,
                              )
                            : Image.asset(
                                toy.imageUrl,
                                width: 60,
                                height: 60,
                                fit: BoxFit.cover,
                              ),
                      ),
                      title: Text(
                        toy.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            toy.category,
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '₺${toy.price.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  color: Colors.blueAccent,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                'Stok: ${toy.stock}',
                                style: TextStyle(
                                  color: toy.stock < 5
                                      ? Colors.red
                                      : Colors.green,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ToyDetailScreen(toy: toy),
                          ),
                        );
                        _fetchData();
                      },
                    ),
                  );
                },
              ),
            ),
      floatingActionButton: _userRole == 'admin'
          ? FloatingActionButton(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ToyFormScreen(),
                  ),
                );
                _fetchData();
              },
              backgroundColor: Colors.blueAccent,
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
    );
  }
}
