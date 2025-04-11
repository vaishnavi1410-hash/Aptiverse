import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'signUp.dart';
import 'home.dart';
import 'admin_approval.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool loading = false;

  final String adminEmail = "admin@admin.com";

  Future<void> loginUser() async {
    setState(() {
      loading = true;
    });

    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      if (credential.user != null) {
        if (credential.user!.email == adminEmail) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => AdminApprovalPage()),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomePage()),
          );
        }
      }
    } on FirebaseAuthException catch (e) {
      String error = e.message ?? "Login failed!";
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error)));
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        
        color: Color.fromARGB(255, 1, 38, 67),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Welcome Back!",
                  style: TextStyle(fontSize: 32, color: Colors.white),
                ),
                SizedBox(height: 50),
                InputField(
                  
                  controller: emailController,
                  icon: Icons.email,
                  hintText: "E-mail",
                ),
                SizedBox(height: 30),
                InputField(
                  controller: passwordController,
                  icon: Icons.lock,
                  hintText: "Password",
                  obscureText: true,
                ),
                SizedBox(height: 25),
                ElevatedButton(
                  onPressed: loginUser,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 100, vertical: 15),
                  ),
                  child: loading
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text(
                          "Login",
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                ),
                SizedBox(height: 20),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => SignupScreen()),
                    );
                  },
                  child: Text(
                    "New user? Sign Up",
                    style: TextStyle(color: Colors.white70),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class InputField extends StatelessWidget {
  final TextEditingController controller;
  final IconData icon;
  final String hintText;
  final bool obscureText;

  const InputField({super.key, 
    required this.controller,
    required this.icon,
    required this.hintText,
    this.obscureText = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      style: TextStyle(color: Colors.white),
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white.withOpacity(0.2),
        prefixIcon: Icon(icon, color: Colors.white),
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.white70),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
