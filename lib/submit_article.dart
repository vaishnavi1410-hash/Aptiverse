import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'home.dart'; // <-- Make sure to import your HomePage

class SubmitArticlePage extends StatefulWidget {
  const SubmitArticlePage({super.key});

  @override
  _SubmitArticlePageState createState() => _SubmitArticlePageState();
}

class _SubmitArticlePageState extends State<SubmitArticlePage> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController contentController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? selectedTopic;

  final List<String> topics = [
    'AI',
    'Productivity',
    'Health',
    'Education',
    'Technology',
  ];

  void previewArticle() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            titleController.text.isEmpty ? "No Title" : titleController.text,
          ),
          content: SingleChildScrollView(
            child: Text(
              contentController.text.isEmpty
                  ? "No Content"
                  : contentController.text,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Close"),
            ),
          ],
        );
      },
    );
  }

  void submitArticle() async {
    final String title = titleController.text.trim();
    final String content = contentController.text.trim();

    if (title.isEmpty || content.isEmpty || selectedTopic == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Please enter title, content, and select a topic."),
        ),
      );
      return;
    }

    try {
      print("📤 Submitting article...");
      await _firestore.collection('pending_articles').add({
        'title': title,
        'content': content,
        'topic': selectedTopic,
        'timestamp': FieldValue.serverTimestamp(),
      });
      print("✅ Article submitted to Firestore!");

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Article Submitted Successfully!")),
      );

      // Clear input
      titleController.clear();
      contentController.clear();

      // 🧭 Navigate to HomePage after a slight delay (optional, to show snackbar)
      Future.delayed(Duration(milliseconds: 500), () {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
          (Route<dynamic> route) => false, // removes all previous routes
        );
      });
    } catch (e) {
      print("❌ Error submitting article: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Failed to submit article.")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 8, 39, 125),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      backgroundColor: Colors.blue.shade50,
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  "Article Submission",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            SizedBox(height: 20),
            Text(
              "Title",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                hintText: "Enter title here",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            Text(
              "Content",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            TextField(
              controller: contentController,
              maxLines: 6,
              decoration: InputDecoration(
                hintText: "Write your content here",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            Text(
              "Select Topic",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            DropdownButtonFormField<String>(
              value: selectedTopic,
              hint: Text("Choose a topic"),
              onChanged: (value) => setState(() => selectedTopic = value),
              items:
                  topics.map((topic) {
                    return DropdownMenuItem<String>(
                      value: topic,
                      child: Text(topic),
                    );
                  }).toList(),
              decoration: InputDecoration(border: OutlineInputBorder()),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: previewArticle,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade400,
                  ),
                  child: Text("Preview", style: TextStyle(color: Colors.black)),
                ),
                SizedBox(width: 15),
                ElevatedButton(
                  onPressed: submitArticle,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade300,
                  ),
                  child: Text("Submit", style: TextStyle(color: Colors.black)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
