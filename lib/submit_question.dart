import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SubmitQuestionPage extends StatefulWidget {
  const SubmitQuestionPage({super.key});

  @override
  _SubmitQuestionPageState createState() => _SubmitQuestionPageState();
}

class _SubmitQuestionPageState extends State<SubmitQuestionPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController questionController = TextEditingController();
  final TextEditingController optionAController = TextEditingController();
  final TextEditingController optionBController = TextEditingController();
  final TextEditingController optionCController = TextEditingController();
  final TextEditingController optionDController = TextEditingController();
  final TextEditingController answerController = TextEditingController();
  final TextEditingController companyController = TextEditingController();
  final TextEditingController topicController = TextEditingController();

  void submitQuestion() async {
    if (_formKey.currentState!.validate()) {
      await FirebaseFirestore.instance.collection('pending_questions').add({
        'question': questionController.text,
        'options': [
          optionAController.text,
          optionBController.text,
          optionCController.text,
          optionDController.text
        ],
        'answer': answerController.text,
        'company': companyController.text,
        'topic': topicController.text,
        'submittedAt': Timestamp.now(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Question submitted for review!')),
      );

      // Clear all fields
      questionController.clear();
      optionAController.clear();
      optionBController.clear();
      optionCController.clear();
      optionDController.clear();
      answerController.clear();
      companyController.clear();
      topicController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Submit a Question'), backgroundColor: Colors.blue),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              buildTextField(questionController, 'Question'),
              buildTextField(optionAController, 'Option A'),
              buildTextField(optionBController, 'Option B'),
              buildTextField(optionCController, 'Option C'),
              buildTextField(optionDController, 'Option D'),
              buildTextField(answerController, 'Correct Answer (e.g., A)<answer>)'),

              
              buildTextField(companyController, 'Company'),
              buildTextField(topicController, 'Topic'),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: submitQuestion,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: EdgeInsets.symmetric(vertical: 14),
                ),
                child: Text('Submit'),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTextField(TextEditingController controller, String hint) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        validator: (value) =>
            value == null || value.isEmpty ? 'Please enter $hint' : null,
        decoration: InputDecoration(
          labelText: hint,
          border: OutlineInputBorder(),
        ),
      ),
    );
  }
}
