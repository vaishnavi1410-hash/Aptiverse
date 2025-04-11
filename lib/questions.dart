import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; //

class Question {
  final String question;
  final List<dynamic> options;
  final String answer;
  final String company;
  final String topic;

  Question({
    required this.question,
    required this.options,
    required this.answer,
    required this.company,
    required this.topic,
  });

  factory Question.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Question(
      question: data['question'] ?? '',
      options: List<String>.from(data['options'] ?? []),
      answer: data['answer'] ?? '',
      company: data['company'] ?? '',
      topic: data['topic'] ?? '',
    );
  }
}

Future<void> markQuestionAsAttempted(String questionId) async {
  final userId = FirebaseAuth.instance.currentUser!.uid;
  final userDoc = FirebaseFirestore.instance.collection('users').doc(userId);

  await userDoc.update({
    'attemptedQuestions': FieldValue.arrayUnion([questionId]),
  });
}

class QuestionScreen extends StatefulWidget {
  const QuestionScreen({super.key});

  @override
  State<QuestionScreen> createState() => _QuestionScreenState();
}

class _QuestionScreenState extends State<QuestionScreen> {
  String selectedCompany = 'All';
  String selectedTopic = 'All';

  final List<String> companies = [
    'All',
    'Wipro',
    'TCS',
    'Infosys',
    'Cognizant',
    'Tech Mahindra',
    'Accenture',
    'Capgemini',
    'Hexaware',
  ];
  final List<String> topics = [
    'All',
    'Blood Relation',
    'Arithmetic Aptitude',
    'Logical Reasoning',
    'Ratio and Propotion',
    'Problems on trains',
    'Calendar',
    'Percentage',
    'Clock',
    'Height and Distance',
  ];

  Stream<List<Question>> fetchFilteredQuestions() {
    Query<Map<String, dynamic>> query = FirebaseFirestore.instance.collection(
      'questions',
    );

    if (selectedCompany != 'All') {
      query = query.where('company', isEqualTo: selectedCompany);
    }

    if (selectedTopic != 'All') {
      query = query.where('topic', isEqualTo: selectedTopic);
    }

    return query.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Question.fromFirestore(doc)).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryBlue = const Color.fromARGB(255, 47, 121, 196);
    final Color lightBlue = Colors.blue.shade50;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 1, 38, 67),
        title: const Text(
          "Aptitude Questions",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      backgroundColor: lightBlue,
      body: Column(
        children: [
          // Filter dropdowns
          Container(
            color: primaryBlue,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),

            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    value: selectedCompany,
                    items:
                        companies
                            .map(
                              (e) => DropdownMenuItem(value: e, child: Text(e)),
                            )
                            .toList(),
                    onChanged: (val) {
                      setState(() => selectedCompany = val!);
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    value: selectedTopic,
                    items:
                        topics
                            .map(
                              (e) => DropdownMenuItem(value: e, child: Text(e)),
                            )
                            .toList(),
                    onChanged: (val) {
                      setState(() => selectedTopic = val!);
                    },
                  ),
                ),
              ],
            ),
          ),

          // Question list
          Expanded(
            child: StreamBuilder<List<Question>>(
              stream: fetchFilteredQuestions(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text("❗ No questions found."));
                }

                final questions = snapshot.data!;
                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: questions.length,
                  itemBuilder: (context, index) {
                    final q = questions[index];
                    return QuestionCard(question: q);
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

class QuestionCard extends StatefulWidget {
  final Question question;
  const QuestionCard({super.key, required this.question});

  @override
  State<QuestionCard> createState() => _QuestionCardState();
}

class _QuestionCardState extends State<QuestionCard> {
  bool isExpanded = false;
  String? selectedOption;
  bool isAttempted = false;
  List<String> attemptedQuestions = []; // ✅ Move this here as a state variable

  @override
  void initState() {
    super.initState();
    fetchAttemptedQuestions(); // ✅ Fetch in initState
  }

  Future<void> fetchAttemptedQuestions() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final snapshot =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

    if (snapshot.exists) {
      final data = snapshot.data();
      if (data != null && data['attemptedQuestions'] != null) {
        setState(() {
          attemptedQuestions = List<String>.from(data['attemptedQuestions']);
        });
      }
    }
  }

  void checkAnswer(String option) async {
    setState(() {
      selectedOption = option;
      isAttempted = true;
      attemptedQuestions.add(widget.question.question); // ✅ Update local state
    });

    final user = FirebaseAuth.instance.currentUser;

    try {
      await FirebaseFirestore.instance.collection('attemptedQuestions').add({
        'question': widget.question.question,
        'selectedOption': option,
        'correctAnswer': widget.question.answer,
        'isCorrect': option == widget.question.answer,
        'company': widget.question.company,
        'topic': widget.question.topic,
        'timestamp': FieldValue.serverTimestamp(),
        'userId': user?.uid,
      });
      print("Attempt saved successfully!");

      if (option == widget.question.answer) {
        await FirebaseFirestore.instance.collection('correctQuestions').add({
          'question': widget.question.question,
          'selectedOption': option,
          'correctAnswer': widget.question.answer,
          'company': widget.question.company,
          'topic': widget.question.topic,
          'timestamp': FieldValue.serverTimestamp(),
          'userId': user?.uid,
        });
        print("Correct question saved successfully!");
      }

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user?.uid)
          .update({
            'attemptedQuestions': FieldValue.arrayUnion([
              widget.question.question,
            ]),
          });
    } catch (e) {
      print("Error saving attempt: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryBlue = Colors.blue.shade700;
    final Color correctColor = Colors.green;
    final Color incorrectColor = Colors.red;
    final Color neutralColor = Colors.grey.shade300;

    final isAttempted = attemptedQuestions.contains(widget.question.question);

    return GestureDetector(
      onTap: () => setState(() => isExpanded = !isExpanded),
      child: Card(
        color: isAttempted ? neutralColor : Colors.white,
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Question text
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      widget.question.question,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: primaryBlue,
                      ),
                    ),
                  ),
                  if (isAttempted)
                    Icon(Icons.check_circle, color: Colors.green, size: 20),
                ],
              ),

              if (isExpanded)
                ...widget.question.options.map((option) {
                  bool isSelected = selectedOption == option;
                  bool isCorrect = option == widget.question.answer;

                  Color optionColor;
                  if (!isAttempted) {
                    optionColor = Colors.white;
                  } else if (isSelected && isCorrect) {
                    optionColor = correctColor;
                  } else if (isSelected && !isCorrect) {
                    optionColor = incorrectColor;
                  } else if (isCorrect) {
                    optionColor = correctColor.withOpacity(0.7);
                  } else {
                    optionColor = Colors.white;
                  }

                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: optionColor,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: isAttempted ? null : () => checkAnswer(option),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(option),
                      ),
                    ),
                  );
                }),
              SizedBox(height: 12),

              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      widget.question.company,
                      style: const TextStyle(fontSize: 12, color: Colors.blue),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      widget.question.topic,
                      style: const TextStyle(fontSize: 12, color: Colors.green),
                    ),
                  ),
                ],
              ),

              if (isAttempted) ...[
                const SizedBox(height: 8),
                Text(
                  selectedOption == widget.question.answer
                      ? "✅ Correct!"
                      : "❌ Incorrect. Correct answer: ${widget.question.answer}",
                  style: TextStyle(
                    color:
                        selectedOption == widget.question.answer
                            ? correctColor
                            : incorrectColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
