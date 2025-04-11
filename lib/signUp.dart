import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Add this import
import 'home.dart'; // Replace with your actual home screen file
import 'login.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool loading = false;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance; // Add Firestore instance

  Future<void> signUpUser() async {
    setState(() {
      loading = true;
    });

    try {
      // Create user with email and password
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(
            email: emailController.text.trim(),
            password: passwordController.text.trim(),
          );
      void showError(String message) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
      }

      // ignore: unused_element
      bool validateInputs() {
        String name = nameController.text.trim();
        String email = emailController.text.trim();
        String password = passwordController.text.trim();

        // Name validation
        if (name.isEmpty) {
          showError("Name cannot be empty!");
          return false;
        }
        if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(name)) {
          showError("Name must only contain letters and spaces!");
          return false;
        }

        // Email validation
        if (email.isEmpty) {
          showError("Email cannot be empty!");
          return false;
        }
        if (RegExp(r'^\d+$').hasMatch(name)) {
          showError("Name cannot be numbers only!");
          return false;
        }
        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w]{2,4}').hasMatch(email)) {
          showError("Enter a valid email address!");
          return false;
        }

        // Password validation
        if (password.isEmpty) {
          showError("Password cannot be empty!");
          return false;
        }
        if (password.length < 6) {
          showError("Password must be at least 6 characters long!");
          return false;
        }

        return true;
      }

      // Save additional user info (like name) to Firestore
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'name': nameController.text.trim(),
        'email': emailController.text.trim(),
        'uid': userCredential.user!.uid,
        'createdAt': Timestamp.now(),
        'attemptedQuestions': [],
      });

      // Navigate to HomePage
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    } on FirebaseAuthException catch (e) {
      String message = e.message ?? "Signup failed!";
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //backgroundColor: Color(0xFF142850),
      body: Container(
        color: Color.fromARGB(255, 1, 38, 67),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Hello...!",
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 30),
                InputField(
                  controller: nameController,
                  icon: Icons.person,
                  hintText: "Your Name",
                ),
                SizedBox(height: 25),
                InputField(
                  controller: emailController,
                  icon: Icons.email,
                  hintText: "Your E-mail",
                ),
                SizedBox(height: 25),
                InputField(
                  controller: passwordController,
                  icon: Icons.lock,
                  hintText: "Password",
                  obscureText: true,
                ),
                SizedBox(height: 25),
                ElevatedButton(
                  onPressed: signUpUser,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: 100,
                      vertical: 15,
                    ),
                  ),
                  child:
                      loading
                          ? CircularProgressIndicator(color: Colors.white)
                          : Text(
                            "Signup",
                            style: TextStyle(color: Colors.white, fontSize: 18),
                          ),
                ),
                SizedBox(height: 20),
                TextButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => LoginScreen()),
                    );
                  },
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => LoginScreen())
                      );
                    },
                    child: Text(
                      "Already Have Account? Login",
                      style: TextStyle(color: Colors.white70),
                    ),
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

// Input Field Widget
class InputField extends StatelessWidget {
  final TextEditingController controller;
  final IconData icon;
  final String hintText;
  final bool obscureText;

  const InputField({
    super.key,
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
