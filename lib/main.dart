import 'package:flutter/material.dart';
import 'package:mobil_proje/login_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Supabase Cloud bağlantı bilgileri
  const String supabaseUrl = 'https://yffqipffjszdyzzqdvmz.supabase.co';
  const String anonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InlmZnFpcGZmanN6ZHl6enFkdm16Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzkxOTQ5NjUsImV4cCI6MjA5NDc3MDk2NX0.aUo59j1jSoh6PgXS3oXQFWLjoJPULtiRauHI3WqQui0';

  await Supabase.initialize(url: supabaseUrl, anonKey: anonKey);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false, home: LoginScreen());
  }
}
