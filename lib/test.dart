import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';
import 'result_page.dart'; // Make sure this file exists

class TestPage extends StatefulWidget {
  const TestPage({super.key});

  @override
  TestPageState createState() => TestPageState();
}

class TestPageState extends State<TestPage> {
  List<Map<String, dynamic>> _questions = [];
  bool _isLoading = true;
  final Map<int, String> _selectedAnswers = {};
  int _correctCount = 0;
  int _incorrectCount = 0;
  bool _isSubmitted = false;

  @override
  void initState() {
    super.initState();
    fetchQuestions();
  }

  Future<void> fetchQuestions() async {
    try {
      final snapshot =
          await FirebaseFirestore.instance.collection('questions').get();
      final random = Random();
      final shuffled = snapshot.docs..shuffle(random);
      final selected = shuffled.take(10).toList();

      setState(() {
        _questions =
            selected.map((doc) {
              final data = doc.data();
              return {
                'question': data['question'] ?? 'No question',
                'options': List<String>.from(data['options'] ?? []),
                'answer': data['answer'] ?? '',
              };
            }).toList();
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching questions: $e');
      setState(() => _isLoading = false);
    }
  }

  void _submitTest() {
    int correct = 0;
    int incorrect = 0;

    for (int i = 0; i < _questions.length; i++) {
      final correctAnswer = _questions[i]['answer'];
      final selected = _selectedAnswers[i];
      if (selected == correctAnswer) {
        correct++;
      } else {
        incorrect++;
      }
    }

    setState(() {
      _correctCount = correct;
      _incorrectCount = incorrect;
      _isSubmitted = true;
    });

    _showResultDialog();
  }

  void _showResultDialog() {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text("Test Result"),
          content: Text(
            "✅ Correct: $_correctCount\n❌ Incorrect: $_incorrectCount",
            style: const TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Close dialog
                Navigator.of(context).pop(); // Go back to home
              },
              child: const Text("Close"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Close dialog
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder:
                        (_) => ResultPage(
                          questions: _questions,
                          selectedAnswers: _selectedAnswers,
                        ),
                  ),
                );
              },
              child: const Text("Review"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Take Test"),
        backgroundColor: const Color.fromARGB(255, 1, 38, 67),
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _questions.isEmpty
              ? const Center(child: Text("❗ No questions available"))
              : Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: _questions.length,
                      itemBuilder: (context, index) {
                        final q = _questions[index];
                        final options = q['options'] as List<String>;

                        return Card(
                          margin: const EdgeInsets.all(12),
                          elevation: 3,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Q${index + 1}: ${q['question']}",
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                ...options.map((option) {
                                  return RadioListTile<String>(
                                    title: Text(option),
                                    value: option,
                                    groupValue: _selectedAnswers[index],
                                    onChanged:
                                        _isSubmitted
                                            ? null
                                            : (value) {
                                              setState(() {
                                                _selectedAnswers[index] =
                                                    value!;
                                              });
                                            },
                                  );
                                }).toList(),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: ElevatedButton(
                      onPressed: _isSubmitted ? null : _submitTest,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 1, 38, 67),
                        padding: const EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 32,
                        ),
                      ),
                      child: const Text(
                        "Submit Test",
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
    );
  }
}
