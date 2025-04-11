import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'article_detail_page.dart'; // Create this for full content view

class ArticlesPage extends StatefulWidget {
  const ArticlesPage({super.key});

  @override
  State<ArticlesPage> createState() => _ArticlesPageState();
}

class _ArticlesPageState extends State<ArticlesPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String searchQuery = '';
  String selectedTopic = 'All';

  List<String> topics = [
    'All',
    'AI',
    'Verbal Ability',
    'Data Science',
    'Numeric Ability',
    'Productivity',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Articles", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.lightBlue,
      ),
      body: Column(
        children: [
          // Search Field
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              onChanged:
                  (value) => setState(() => searchQuery = value.toLowerCase()),
              decoration: InputDecoration(
                hintText: "Search articles...",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),

          // Filter Dropdown
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: DropdownButton<String>(
              isExpanded: true,
              value: selectedTopic,
              onChanged: (value) => setState(() => selectedTopic = value!),
              items:
                  topics.map((topic) {
                    return DropdownMenuItem(value: topic, child: Text(topic));
                  }).toList(),
            ),
          ),

          // Article List
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection('approved_articles').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData)
                  return Center(child: CircularProgressIndicator());

                final docs =
                    snapshot.data!.docs.where((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      final title =
                          data['title']?.toString().toLowerCase() ?? '';
                      final topic = data['topic']?.toString() ?? 'Unknown';
                      final matchesSearch = title.contains(searchQuery);
                      final matchesFilter =
                          selectedTopic == 'All' || topic == selectedTopic;
                      return matchesSearch && matchesFilter;
                    }).toList();

                if (docs.isEmpty) {
                  return Center(child: Text("No articles found"));
                }

                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final doc = docs[index];
                    final data = doc.data() as Map<String, dynamic>;
                    return AnimatedContainer(
                      duration: Duration(milliseconds: 300),
                      margin: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      child: Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          title: Text(
                            data['title'],
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(data['topic'] ?? 'General'),
                          trailing: Icon(Icons.arrow_forward_ios, size: 16),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (_) => ArticleDetailPage(
                                      title: data['title'],
                                      content: data['content'],
                                      topic: data['topic'] ?? 'General',
                                    ),
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
