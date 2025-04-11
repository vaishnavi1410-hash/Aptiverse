import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class AdminApprovalPage extends StatefulWidget {
  const AdminApprovalPage({super.key});

  @override
  _AdminApprovalPageState createState() => _AdminApprovalPageState();
}

class _AdminApprovalPageState extends State<AdminApprovalPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // === ARTICLE METHODS ===
  Future<void> approveArticle(DocumentSnapshot doc) async {
    try {
      final data = doc.data() as Map<String, dynamic>;

      await _firestore.collection('approved_articles').add({
        'title': data['title'] ?? 'Untitled',
        'content': data['content'] ?? '',
        'topic': data['topic'] ?? 'General',
        'author': data['author'] ?? 'Admin',
        'timestamp': FieldValue.serverTimestamp(),
        'thumbnail': data['thumbnail'] ?? '',
      });

      await _firestore.collection('pending_articles').doc(doc.id).delete();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Article approved successfully')));
    } catch (e) {
      print("Error approving article: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to approve article')));
    }
  }

  Future<void> rejectArticle(DocumentSnapshot doc) async {
    try {
      await _firestore.collection('pending_articles').doc(doc.id).delete();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Article rejected and deleted')));
    } catch (e) {
      print("Error rejecting article: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to reject article')));
    }
  }

  // === QUESTION METHODS ===
  Future<void> approveQuestion(DocumentSnapshot doc) async {
    try {
      await _firestore
          .collection('questions')
          .add(doc.data() as Map<String, dynamic>);
      await _firestore.collection('pending_questions').doc(doc.id).delete();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Question approved successfully')));
    } catch (e) {
      print("Error approving question: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to approve question')));
    }
  }

  Future<void> rejectQuestion(DocumentSnapshot doc) async {
    try {
      await _firestore.collection('pending_questions').doc(doc.id).delete();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Question rejected and deleted')));
    } catch (e) {
      print("Error rejecting question: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to reject question')));
    }
  }

  // === BUILD WIDGETS ===
  Widget buildPendingArticles() {
    return StreamBuilder<QuerySnapshot>(
      stream:
          _firestore
              .collection('pending_articles')
              .orderBy('timestamp', descending: true)
              .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return CircularProgressIndicator();

        if (snapshot.data!.docs.isEmpty) {
          return Center(child: Text('No pending articles'));
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Pending Articles",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            ...snapshot.data!.docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              final ts = data['timestamp'] as Timestamp?;
              final time =
                  ts != null
                      ? DateFormat('MMM d, yyyy • h:mm a').format(ts.toDate())
                      : '';

              return Card(
                margin: EdgeInsets.symmetric(vertical: 8),
                elevation: 3,
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data['title'] ?? 'Untitled',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        data['content'] ?? '',
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (time.isNotEmpty) ...[
                        SizedBox(height: 8),
                        Text(
                          time,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                      SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          ElevatedButton.icon(
                            icon: Icon(Icons.check),
                            label: Text("Approve"),
                            onPressed: () => approveArticle(doc),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                            ),
                          ),
                          SizedBox(width: 10),
                          ElevatedButton.icon(
                            icon: Icon(Icons.close),
                            label: Text("Reject"),
                            onPressed: () => rejectArticle(doc),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ],
        );
      },
    );
  }

  Widget buildPendingQuestions() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('pending_questions').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return CircularProgressIndicator();

        if (snapshot.data!.docs.isEmpty) {
          return Center(child: Text('No pending questions'));
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Pending Questions",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            ...snapshot.data!.docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;

              return Card(
                margin: EdgeInsets.symmetric(vertical: 8),
                elevation: 3,
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Question: ${data['question']}",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 10),
                      ...List.generate(data['options'].length, (index) {
                        return Text(
                          "${String.fromCharCode(65 + index)}) ${data['options'][index]}",
                        );
                      }),
                      SizedBox(height: 10),
                      Text("Answer: ${data['answer']}"),
                      Text("Company: ${data['company']}"),
                      Text("Topic: ${data['topic']}"),
                      SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          ElevatedButton.icon(
                            icon: Icon(Icons.check),
                            label: Text("Approve"),
                            onPressed: () => approveQuestion(doc),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                            ),
                          ),
                          SizedBox(width: 10),
                          ElevatedButton.icon(
                            icon: Icon(Icons.close),
                            label: Text("Reject"),
                            onPressed: () => rejectQuestion(doc),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Approval Dashboard'),
        backgroundColor: Colors.blueAccent,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            buildPendingArticles(),
            SizedBox(height: 30),
            buildPendingQuestions(),
          ],
        ),
      ),
    );
  }
}
