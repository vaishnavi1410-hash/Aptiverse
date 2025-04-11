import 'package:aptitude/test.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'questions.dart';
import 'articles.dart';
import 'submit_question.dart';
import 'submit_article.dart';
import 'profile.dart';
import 'login.dart';
import 'test.dart'; // Import your login screen

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: WavyAppBarScreen(),
    );
  }
}

Future<String?> getUserName() async {
  User? user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    DocumentSnapshot userDoc =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
    if (userDoc.exists) {
      return userDoc['name'];
    }
  }
  return null;
}

class WavyAppBarScreen extends StatelessWidget {
  const WavyAppBarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: const Color.fromARGB(255, 245, 247, 249),
        child: Column(
          children: [
            // Wavy AppBar with Logout and Profile Icon
            Stack(
              children: [
                ClipPath(
                  clipper: WavyClipper(),
                  child: Container(
                    height: 200,
                    color: const Color.fromARGB(255, 1, 38, 67),
                  ),
                ),
                Positioned(
                  top: 80,
                  left: 20,
                  child: FutureBuilder<String?>(
                    future: getUserName(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Text("loading");
                      } else if (snapshot.hasError) {
                        return Text("Error");
                      } else if (snapshot.hasData) {
                        return Text(
                          "Hi, ${snapshot.data}",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 30,
                            color: Colors.white,
                          ),
                        );
                      }
                      return Text("Student");
                    },
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(10),
                  child: Align(
                    alignment: Alignment.topRight,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.logout, color: Colors.white),
                          onPressed: () async {
                            await FirebaseAuth.instance.signOut();
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => LoginScreen(),
                              ),
                            );
                          },
                        ),
                        SizedBox(width: 8),
                        InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ProfilePage(),
                              ),
                            );
                          },
                          child: CircleAvatar(
                            backgroundColor: Colors.white,
                            radius: 25,
                            child: Image.asset('assets/images/profile.png'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      CustomCard(
                        title: "Questions",
                        color: const Color.fromARGB(255, 3, 49, 96),
                        icon: Icons.question_answer,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => QuestionScreen(),
                            ),
                          );
                        },
                      ),
                      SizedBox(height: 20),

                      CustomCard(
                        title: "Articles",
                        color: const Color.fromARGB(255, 16, 88, 147),
                        icon: Icons.article,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ArticlesPage(),
                            ),
                          );
                        },
                      ),
                      SizedBox(height: 20),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: CustomCard(
                              title: "Submit Question",
                              color: const Color.fromARGB(255, 16, 124, 212),
                              icon: Icons.upload_file,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => SubmitQuestionPage(),
                                  ),
                                );
                              },
                            ),
                          ),
                          SizedBox(width: 20),
                          Expanded(
                            child: CustomCard(
                              title: "Submit Article",
                              color: const Color.fromARGB(255, 19, 130, 221),
                              icon: Icons.upload,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => SubmitArticlePage(),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 25),

                      Center(
                        child: ElevatedButton(
                          
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => TestPage()),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                             backgroundColor: Colors.blue[800], // Background color
                             foregroundColor: Colors.white, // Text (foreground) color
                             minimumSize: Size(300, 80), // Width and Height
                             padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                             shape: RoundedRectangleBorder(
                             borderRadius: BorderRadius.circular(12), // Rounded corners
                              ),
                          ),
                          child: Text("Take Test", style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontSize: 20,
                          ),),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Custom Wavy AppBar Clipper
class WavyClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height - 50);
    path.quadraticBezierTo(
      size.width / 4,
      size.height,
      size.width / 2,
      size.height - 50,
    );
    path.quadraticBezierTo(
      size.width * 3 / 4,
      size.height - 100,
      size.width,
      size.height - 50,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

// Reusable Custom Card Widget
class CustomCard extends StatelessWidget {
  final String title;
  final Color color;
  final IconData icon;
  final VoidCallback onTap;

  const CustomCard({
    super.key,
    required this.title,
    required this.color,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              spreadRadius: 2,
              offset: Offset(2, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Icon(icon, color: Colors.white, size: 28),
          ],
        ),
      ),
    );
  }
}
