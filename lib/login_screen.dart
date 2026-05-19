import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:mobil_proje/widgets/mytext_field.dart';
import 'package:mobil_proje/screens/toy_list_screen.dart';
import 'package:mobil_proje/data/supabase_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final userController = TextEditingController();
  final pwdController = TextEditingController();
  final nameController = TextEditingController();
  final phoneController = TextEditingController();

  final _supabaseService = SupabaseService();
  bool isLogin = true;
  bool isLoading = false;

  Future<void> _handleAuth() async {
    setState(() {
      isLoading = true;
    });

    try {
      if (isLogin) {
        await _supabaseService.signIn(userController.text, pwdController.text);
      } else {
        await _supabaseService.signUp(
          userController.text,
          pwdController.text,
          fullName: nameController.text,
          phone: phoneController.text,
        );
      }

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const ToyListScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Hata: ${e.toString()}")),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset("lib/images/resim.jpg", fit: BoxFit.cover),
          ),

          Center(
            child: ClipRRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: 10.0,
                  sigmaY: 10.0,
                ),
                child: Container(
                  padding: EdgeInsets.all(25),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(color: Colors.white, width: 2),
                  ),

                  width: 350,
                  height: isLogin ? 450 : 600, 

                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Container(
                          color: Colors.white12,
                          child: Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      isLogin = true;
                                    });
                                  },
                                  child: AnimatedContainer(
                                    duration: Duration(milliseconds: 500),
                                    padding: EdgeInsets.symmetric(vertical: 15),
                                    color: isLogin
                                        ? Colors.white24
                                        : Colors.transparent,
                                    child: Center(
                                      child: Text(
                                        "Giriş Yap",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                    
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      isLogin = false;
                                    });
                                  },
                                  child: AnimatedContainer(
                                    duration: Duration(milliseconds: 500),
                                    padding: EdgeInsets.symmetric(vertical: 15),
                                    color: !isLogin
                                        ? Colors.white24
                                        : Colors.transparent,
                                    child: Center(
                                      child: Text(
                                        "Kayıt Ol",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                    
                        SizedBox(height: 15),
                    
                        Align(
                          alignment: Alignment.bottomLeft,
                          child: Text(
                            isLogin
                                ? "Kullanıcı Adı ve Şifrenizi Giriniz"
                                : "Yeni Hesap Oluştur",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        SizedBox(height: 15),
                    
                        if (!isLogin) ...[
                          MytextField(
                            hintText: "Ad Soyad Giriniz",
                            prefixIcon: Icon(Icons.person),
                            controller: nameController,
                          ),
                          SizedBox(height: 15),
                          MytextField(
                            hintText: "Telefon Numarası Giriniz ",
                            prefixIcon: Icon(Icons.phone),
                            controller: phoneController,
                          ),
                          SizedBox(height: 15),
                        ],
                    
                        MytextField(
                          controller: userController,
                          hintText: "E-posta adresinizi giriniz",
                          prefixIcon: Icon(Icons.mail),
                        ),
                        SizedBox(height: 15),
                        MytextField(
                          controller: pwdController,
                          hintText: "Şifrenizi Giriniz",
                          prefixIcon: Icon(Icons.lock),
                          obscureText: true,
                        ),
                    
                        SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blueAccent,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: isLoading ? null : _handleAuth,
                            child: isLoading 
                              ? CircularProgressIndicator(color: Colors.white)
                              : Text(
                                isLogin ? "Giriş Yap" : "Kayıt Ol",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
