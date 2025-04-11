import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'home.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String userName = '';
  int attemptedCount = 0;
  int correctCount = 0;
  double accuracy = 0.0;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    final user = _auth.currentUser;
    if (user != null) {
      try {
        // Fetch user document
        DocumentSnapshot userDoc =
            await _firestore.collection('users').doc(user.uid).get();

        String name = 'User';
        if (userDoc.exists && userDoc.data() != null) {
          name = userDoc['name'] ?? 'User';
        }

        // Fetch attempted questions count
        QuerySnapshot attemptedQuestionsSnapshot = await _firestore
            .collection('attemptedQuestions')
            .where('userId', isEqualTo: user.uid)
            .get();

        int totalAttempts = attemptedQuestionsSnapshot.size;

        // Fetch correct questions count
        QuerySnapshot correctQuestionsSnapshot = await _firestore
            .collection('correctQuestions')
            .where('userId', isEqualTo: user.uid)
            .get();

        int totalCorrect = correctQuestionsSnapshot.size;

        // Calculate accuracy
        double calculatedAccuracy = 0.0;
        if (totalAttempts > 0) {
          calculatedAccuracy =
              (totalCorrect / totalAttempts * 100).toDouble();
        }

        setState(() {
          userName = name;
          attemptedCount = totalAttempts;
          correctCount = totalCorrect;
          accuracy = calculatedAccuracy;
        });
      } catch (e) {
        print('Error fetching user data: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF1E3C72),
                  Color(0xFF2A5298),
                  Color(0xFF4A90E2),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          // Blur glass effect
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
              child: Container(
                color: Colors.black.withOpacity(0.1),
              ),
            ),
          ),

          // Profile card
          Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                  border: Border.all(
                    color: Colors.white.withOpacity(0.4),
                    width: 1.5,
                  ),
                ),
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Profile Picture
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.white.withOpacity(0.3),
                      child: Icon(
                        Icons.person,
                        size: 60,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 15),

                    // User Name
                    Text(
                      userName,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1.2,
                      ),
                    ),
                    SizedBox(height: 10),
                    Divider(
                      color: Colors.white.withOpacity(0.4),
                      thickness: 1,
                      indent: 30,
                      endIndent: 30,
                    ),
                    SizedBox(height: 20),

                    // Attempted questions
                    Text(
                      'Questions Attempted:',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      '$attemptedCount',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 20),

                    // Correct answers
                    Text(
                      'Correct Answers:',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      '$correctCount',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 20),

                    // Accuracy Percentage
                    Text(
                      'Accuracy:',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      '${accuracy.toStringAsFixed(2)}%',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 30),

                    // Back Button
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white.withOpacity(0.25),
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                        side: BorderSide(
                          color: Colors.white.withOpacity(0.5),
                          width: 1,
                        ),
                      ),
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => HomePage()),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                        child: Text(
                          'Back',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
