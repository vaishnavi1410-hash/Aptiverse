import 'dart:ui';
import 'package:flutter/material.dart';
import 'login.dart';

class StartingPage extends StatelessWidget {
  const StartingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Enhanced Background Gradient with more blue tones
          Container(
             color: Colors.white
          ),

          // Blur effect
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(
              color: Colors.black.withOpacity(0), // Transparent for blur
            ),
          ),

          // Main Content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Image
                Image.asset(
                  'assets/images/download.gif',
                  width: 400,
                  height: 400,
                ),

                SizedBox(height: 20),

                // Title
                Text(
                  'AptiVerse',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    letterSpacing: 1.2,
                  ),
                ),

                SizedBox(height: 10),

                // Subtitle (two lines)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40.0),
                  child: Text(
                    'Explore.Learn.Conquer Aptitude\n\nSharpen your skills and boost your confidence.\nGet ready to ace your placement exams!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                      height: 1.4,
                    ),
                  ),
                ),

                SizedBox(height: 30),

                // Arrow button
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => LoginScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent.withOpacity(0.8),
                    shape: CircleBorder(),
                    padding: EdgeInsets.all(18),
                    elevation: 8,
                    shadowColor: Colors.black45,
                  ),
                  child: Icon(Icons.arrow_forward, color: Colors.white, size: 32),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
