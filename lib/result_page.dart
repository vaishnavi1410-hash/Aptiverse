import 'package:flutter/material.dart';

class ResultPage extends StatelessWidget {
  final List<Map<String, dynamic>> questions;
  final Map<int, String> selectedAnswers;

  const ResultPage({
    super.key,
    required this.questions,
    required this.selectedAnswers,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Review Answers"),
        backgroundColor: const Color.fromARGB(255, 1, 38, 67),
      ),
      body: ListView.builder(
        itemCount: questions.length,
        itemBuilder: (context, index) {
          final question = questions[index];
          final correctAnswer = question['answer'] ?? '';
          final selectedAnswer = selectedAnswers[index];

          final isCorrect = selectedAnswer == correctAnswer;

          return Card(
            margin: const EdgeInsets.all(12),
            elevation: 3,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Q${index + 1}: ${question['question']}",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Your Answer: ${selectedAnswer ?? "Not Answered"}",
                    style: TextStyle(
                      color: isCorrect ? Colors.green : Colors.red,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 5),
                  if (!isCorrect)
                    Text(
                      "Correct Answer: $correctAnswer",
                      style: const TextStyle(color: Colors.green, fontSize: 16),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
