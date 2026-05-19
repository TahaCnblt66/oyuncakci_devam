import 'package:flutter/material.dart';
import '../models/toy.dart';
import 'toy_form_screen.dart';
import 'return_screen.dart';
import '../data/supabase_service.dart';

class ToyDetailScreen extends StatefulWidget {
  final Toy toy;
  const ToyDetailScreen({super.key, required this.toy});

  @override
  State<ToyDetailScreen> createState() => _ToyDetailScreenState();
}

class _ToyDetailScreenState extends State<ToyDetailScreen> {
  final _supabaseService = SupabaseService();
  String? _userRole;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkRole();
  }

  Future<void> _checkRole() async {
    final user = _supabaseService.currentUser;
    if (user != null) {
      final profile = await _supabaseService.getProfile(user.id);
      setState(() {
        _userRole = profile?['role'];
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _addToCart() async {
    final user = _supabaseService.currentUser;
    if (user == null) return;

    if (widget.toy.stock > 0) {
      try {
        await _supabaseService.addToCart(user.id, widget.toy.id, 1);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${widget.toy.name} sepete eklendi!')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Hata: $e")),
          );
        }
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Stokta yok!')),
      );
    }
  }

  Future<void> _sellToy() async {
    if (widget.toy.stock > 0) {
      setState(() {
        widget.toy.stock--;
      });
      await _supabaseService.updateToy(widget.toy);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${widget.toy.name} satıldı!')),
        );
      }
    }
  }

  void _returnToy() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReturnScreen(toy: widget.toy),
      ),
    );
    if (result == true) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.toy.name),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        actions: _userRole == 'admin' 
          ? [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ToyFormScreen(toy: widget.toy),
                  ),
                );
                setState(() {});
              },
            ),
          ]
          : null,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            widget.toy.imageUrl.startsWith('http')
                ? Image.network(widget.toy.imageUrl, width: double.infinity, height: 300, fit: BoxFit.cover)
                : Image.asset(widget.toy.imageUrl, width: double.infinity, height: 300, fit: BoxFit.cover),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        widget.toy.category,
                        style: const TextStyle(
                          color: Colors.blueAccent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '₺${widget.toy.price.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    widget.toy.name,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Stok Durumu: ${widget.toy.stock} adet',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: widget.toy.stock < 5 ? Colors.red : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Açıklama',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.toy.description,
                    style: const TextStyle(fontSize: 16, color: Colors.black54),
                  ),
                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _addToCart,
                      icon: const Icon(Icons.add_shopping_cart),
                      label: const Text('SEPETE EKLE'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                      ),
                    ),
                  ),
                  if (_userRole == 'admin') ...[
                    const SizedBox(height: 15),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _sellToy,
                        icon: const Icon(Icons.shopping_cart),
                        label: const Text('SATIŞ YAP'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                        ),
                      ),
                    ),
                  ],
                  if (_userRole == 'customer') ...[
                    const SizedBox(height: 15),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _returnToy,
                        icon: const Icon(Icons.assignment_return),
                        label: const Text('İADE ET'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orangeAccent,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
