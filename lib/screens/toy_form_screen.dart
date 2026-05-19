import 'package:flutter/material.dart';
import '../models/toy.dart';
import '../data/supabase_service.dart';

class ToyFormScreen extends StatefulWidget {
  final Toy? toy;
  const ToyFormScreen({super.key, this.toy});

  @override
  State<ToyFormScreen> createState() => _ToyFormScreenState();
}

class _ToyFormScreenState extends State<ToyFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descController;
  late TextEditingController _priceController;
  late TextEditingController _stockController;
  late TextEditingController _categoryController;
  late TextEditingController _imageUrlController;
  final _supabaseService = SupabaseService();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.toy?.name ?? '');
    _descController = TextEditingController(text: widget.toy?.description ?? '');
    _priceController = TextEditingController(text: widget.toy?.price.toString() ?? '');
    _stockController = TextEditingController(text: widget.toy?.stock.toString() ?? '');
    _categoryController = TextEditingController(text: widget.toy?.category ?? '');
    _imageUrlController = TextEditingController(text: widget.toy?.imageUrl ?? '');
  }

  Future<void> _saveForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isSaving = true);
      try {
        final toyData = Toy(
          id: widget.toy?.id ?? '',
          name: _nameController.text,
          description: _descController.text,
          price: double.parse(_priceController.text),
          stock: int.parse(_stockController.text),
          category: _categoryController.text,
          imageUrl: _imageUrlController.text.isNotEmpty 
              ? _imageUrlController.text 
              : 'lib/images/resim.jpg',
        );

        if (widget.toy == null) {
          await _supabaseService.addToy(toyData);
        } else {
          await _supabaseService.updateToy(toyData);
        }

        if (mounted) {
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Kaydetme hatası: $e")),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isSaving = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.toy == null ? 'Yeni Oyuncak Ekle' : 'Oyuncağı Düzenle'),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Oyuncak Adı', border: OutlineInputBorder()),
                validator: (value) => value!.isEmpty ? 'Lütfen bir ad girin' : null,
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _categoryController,
                decoration: const InputDecoration(labelText: 'Kategori', border: OutlineInputBorder()),
                validator: (value) => value!.isEmpty ? 'Lütfen bir kategori girin' : null,
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _descController,
                decoration: const InputDecoration(labelText: 'Açıklama', border: OutlineInputBorder()),
                maxLines: 3,
                validator: (value) => value!.isEmpty ? 'Lütfen bir açıklama girin' : null,
              ),
              const SizedBox(height: 15),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _priceController,
                      decoration: const InputDecoration(labelText: 'Fiyat (₺)', border: OutlineInputBorder()),
                      keyboardType: TextInputType.number,
                      validator: (value) => double.tryParse(value!) == null ? 'Geçerli bir fiyat girin' : null,
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: TextFormField(
                      controller: _stockController,
                      decoration: const InputDecoration(labelText: 'Stok Adedi', border: OutlineInputBorder()),
                      keyboardType: TextInputType.number,
                      validator: (value) => int.tryParse(value!) == null ? 'Geçerli bir sayı girin' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _imageUrlController,
                decoration: const InputDecoration(
                  labelText: 'Resim URL veya Yolu',
                  border: OutlineInputBorder(),
                  hintText: 'http://... veya lib/images/...',
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _isSaving ? null : _saveForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                child: _isSaving 
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('KAYDET', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
