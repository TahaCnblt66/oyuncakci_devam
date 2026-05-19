import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/toy.dart';

class SupabaseService {
  final _client = Supabase.instance.client;

  // --- Auth ---
  Future<AuthResponse> signIn(String email, String password) async {
    return await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  Future<AuthResponse> signUp(
    String email,
    String password, {
    required String fullName,
    required String phone,
  }) async {
    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
      );

      if (response.user != null) {
        // Kullanıcı oluştuktan sonra profil tablosuna bilgileri ekle
        await _client.from('profiles').upsert({
          'id': response.user!.id,
          'full_name': fullName,
          'phone': phone,
          'role': 'customer',
        });
      }
      return response;
    } on AuthException catch (e) {
      // Supabase'den gelen özel hatalar (örn: "User already registered")
      throw e.message;
    } catch (e) {
      // Diğer hatalar
      throw "Kayıt hatası: $e";
    }
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  User? get currentUser => _client.auth.currentUser;

  // --- Profile ---
  Future<Map<String, dynamic>?> getProfile(String userId) async {
    final data = await _client
        .from('profiles')
        .select()
        .eq('id', userId)
        .single();
    return data;
  }

  // --- Toys ---
  Future<List<Toy>> getToys() async {
    final response = await _client.from('toys').select().order('name');
    return response.map((e) => Toy.fromMap(e)).toList();
  }

  Future<void> addToy(Toy toy) async {
    await _client.from('toys').insert(toy.toMap());
  }

  Future<void> updateToy(Toy toy) async {
    await _client.from('toys').update(toy.toMap()).eq('id', toy.id);
  }

  Future<void> deleteToy(String id) async {
    await _client.from('toys').delete().eq('id', id);
  }

  // --- Cart ---
  Future<List<Map<String, dynamic>>> getCartItems(String userId) async {
    return await _client
        .from('cart_items')
        .select('*, toys(*)')
        .eq('user_id', userId);
  }

  Future<void> addToCart(String userId, String toyId, int quantity) async {
    // Check if exists
    final existing = await _client
        .from('cart_items')
        .select()
        .eq('user_id', userId)
        .eq('toy_id', toyId)
        .maybeSingle();

    if (existing != null) {
      await _client
          .from('cart_items')
          .update({'quantity': existing['quantity'] + quantity})
          .eq('id', existing['id']);
    } else {
      await _client.from('cart_items').insert({
        'user_id': userId,
        'toy_id': toyId,
        'quantity': quantity,
      });
    }
  }

  Future<void> updateCartQuantity(String cartItemId, int quantity) async {
    await _client
        .from('cart_items')
        .update({'quantity': quantity})
        .eq('id', cartItemId);
  }

  Future<void> removeFromCart(String cartItemId) async {
    await _client.from('cart_items').delete().eq('id', cartItemId);
  }

  Future<void> clearCart(String userId) async {
    await _client.from('cart_items').delete().eq('user_id', userId);
  }
}
