import 'package:flutter/material.dart';

class AddFlashcardScreen extends StatefulWidget {
  final String deckName;
  final Function(String, String) onAdd;

  const AddFlashcardScreen({super.key,required this.deckName, required this.onAdd});

  @override
  State<AddFlashcardScreen> createState() => _AddFlashcardScreenState();
}

class _AddFlashcardScreenState extends State<AddFlashcardScreen> {
  final TextEditingController questionController = TextEditingController();
  final TextEditingController answerController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Flashcard')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: questionController,
              decoration: const InputDecoration(
                labelText: 'Question',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: answerController,
              decoration: const InputDecoration(
                labelText: 'Answer',
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                final question = questionController.text.trim();
                final answer = answerController.text.trim();
                if (question.isNotEmpty && answer.isNotEmpty) {
                  widget.onAdd(question, answer);
                  Navigator.pop(context); // Quay về màn chính
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
