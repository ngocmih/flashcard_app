import 'package:flutter/material.dart';
import 'package:flip_card/flip_card.dart';
import 'package:flashcard_app/core/services/flashcard_service.dart';
import 'package:flashcard_app/data/models/flashcard_model.dart';
import 'package:flashcard_app/features/flashcard/screens/add_flashcard_screen.dart';
import 'package:flashcard_app/features/practice/screens/practice_choice_screen.dart';
import 'package:flashcard_app/features/practice/screens/practice_screen.dart';

class FlashcardScreen extends StatefulWidget {
  final String deckName;

  const FlashcardScreen({super.key, required this.deckName});

  @override
  State<FlashcardScreen> createState() => _FlashcardScreenState();
}

class _FlashcardScreenState extends State<FlashcardScreen> {
  List<Flashcard> flashcards = [];
  List<Flashcard> filteredFlashcards = [];
  final TextEditingController _searchController = TextEditingController();
  final FlashcardService _flashcardService = FlashcardService();

  @override
  void initState() {
    super.initState();
    _loadFlashcards();
  }

  Future<void> _loadFlashcards() async {
    final cards = await _flashcardService.loadFlashcards(widget.deckName);
    setState(() {
      flashcards = cards;
      filteredFlashcards = List.from(cards);
    });
  }

  Future<void> _saveFlashcards() async {
    await _flashcardService.saveFlashcards(widget.deckName, flashcards);
  }

  void _searchFlashcards(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredFlashcards = List.from(flashcards);
      } else {
        filteredFlashcards = flashcards.where((card) {
          final q = card.question.toLowerCase();
          final a = card.answer.toLowerCase();
          return q.contains(query.toLowerCase()) ||
              a.contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  void _addFlashcard(String question, String answer) {
    setState(() {
      flashcards.add(
          Flashcard(question: question, answer: answer, isLearned: false));
      filteredFlashcards = List.from(flashcards);
    });
    _saveFlashcards();
  }

  void _removeFlashcard(int index) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Xoá thẻ?'),
        content: const Text('Bạn có chắc muốn xoá flashcard này không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Huỷ'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                flashcards.removeAt(index);
                filteredFlashcards = List.from(flashcards);
              });
              _saveFlashcards();
              Navigator.pop(context);
            },
            child: const Text('Xoá'),
          ),
        ],
      ),
    );
  }

  void _toggleLearned(int index) {
    setState(() {
      flashcards[index] = Flashcard(
        question: flashcards[index].question,
        answer: flashcards[index].answer,
        isLearned: !flashcards[index].isLearned,
      );
      filteredFlashcards = List.from(flashcards);
    });
    _saveFlashcards();
  }

  void _showEditDialog(int index) {
    final questionController =
    TextEditingController(text: flashcards[index].question);
    final answerController =
    TextEditingController(text: flashcards[index].answer);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Sửa Flashcard'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: questionController,
              decoration: const InputDecoration(labelText: 'Question'),
            ),
            TextField(
              controller: answerController,
              decoration: const InputDecoration(labelText: 'Answer'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Huỷ'),
          ),
          TextButton(
            onPressed: () {
              final question = questionController.text.trim();
              final answer = answerController.text.trim();
              if (question.isNotEmpty && answer.isNotEmpty) {
                setState(() {
                  flashcards[index] = Flashcard(
                    question: question,
                    answer: answer,
                    isLearned: flashcards[index].isLearned,
                  );
                  filteredFlashcards = List.from(flashcards);
                });
                _saveFlashcards();
              }
              Navigator.pop(context);
            },
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.deckName),
        actions: [
          IconButton(
            icon: const Icon(Icons.play_arrow),
            tooltip: 'Luyện tập',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PracticeScreen(flashcards: flashcards),
                ),
              );
            },
          ),
        ],
      ),
      body: flashcards.isEmpty
          ? const Center(child: Text('No flashcards yet'))
          : ListView.builder(
        itemCount: flashcards.length,
        itemBuilder: (context, index) {
          final flashcard = flashcards[index];
          return Dismissible(
            key: UniqueKey(),
            background: Container(
              color: Colors.redAccent,
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            direction: DismissDirection.endToStart,
            onDismissed: (_) => _removeFlashcard(index),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: FlipCard(
                direction: FlipDirection.VERTICAL,
                front: Card(
                  color: flashcard.isLearned
                      ? Colors.green.shade100
                      : null,
                  child: ListTile(
                    title: Text(flashcard.question),
                    subtitle: const Text('Tap to see answer'),
                    trailing: Wrap(
                      spacing: 4,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => _showEditDialog(index),
                        ),
                        IconButton(
                          icon: Icon(
                            flashcard.isLearned
                                ? Icons.check_circle
                                : Icons.check_circle_outline,
                            color: flashcard.isLearned
                                ? Colors.green
                                : Colors.grey,
                          ),
                          onPressed: () => _toggleLearned(index),
                        ),
                      ],
                    ),
                  ),
                ),
                back: Card(
                  color: flashcard.isLearned
                      ? Colors.green.shade100
                      : Colors.teal.shade100,
                  child: ListTile(
                    title: Text(flashcard.answer,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold)),
                    subtitle: const Text('Tap to go back'),
                  ),
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          FloatingActionButton.extended(
            heroTag: 'multiple_choice',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PracticeChoiceScreen(flashcards: flashcards),
                ),
              );
            },
            icon: const Icon(Icons.quiz),
            label: const Text('Trắc nghiệm'),
          ),
          const SizedBox(height: 12),
          FloatingActionButton(
            heroTag: 'add_card',
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AddFlashcardScreen(
                    deckName: widget.deckName,
                    onAdd: _addFlashcard,
                  ),
                ),
              );
            },
            child: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }
}
