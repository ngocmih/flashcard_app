import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flip_card/flip_card.dart';
import 'add_flashcard_screen.dart';
import 'practice_screen.dart';
import 'practice_choice_screen.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:csv/csv.dart';


class FlashcardScreen extends StatefulWidget {
  final String deckName;

  const FlashcardScreen({super.key, required this.deckName});

  @override
  State<FlashcardScreen> createState() => _FlashcardScreenState();
}

class _FlashcardScreenState extends State<FlashcardScreen> {
  List<Map<String, dynamic>> flashcards = [];

  @override
  void initState() {
    super.initState();
    _loadFlashcards();
  }

  Future<void> _loadFlashcards() async {
    final prefs = await SharedPreferences.getInstance();
    final String? decksData = prefs.getString('allDecks');
    if (decksData != null) {
      final decoded = jsonDecode(decksData) as Map<String, dynamic>;
      final List<dynamic>? currentDeck = decoded[widget.deckName];
      if (currentDeck != null) {
        setState(() {
          flashcards = currentDeck.map<Map<String, dynamic>>((item) => {
            'question': item['question'],
            'answer': item['answer'],
            'isLearned': item['isLearned'] ?? false,
          }).toList();
        });
      }
    }
  }

  Future<void> _saveFlashcards() async {
    final prefs = await SharedPreferences.getInstance();
    final String? decksData = prefs.getString('allDecks');
    final Map<String, dynamic> decoded =
    decksData != null ? jsonDecode(decksData) : {};
    decoded[widget.deckName] = flashcards;
    await prefs.setString('allDecks', jsonEncode(decoded));
  }

  Future<void> _importFlashcards() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
      withData: true,
    );

    if (result == null || result.files.isEmpty) {
      print('No file selected.');
      return;
    }

    try {
      String content;

      if (result.files.single.bytes != null) {
        print('Running on Web – reading file from bytes.');
        content = utf8.decode(result.files.single.bytes!);
      } else if (result.files.single.path != null) {
        print('Running on Mobile/Desktop – reading file from path.');
        final file = File(result.files.single.path!);
        content = await file.readAsString(encoding: utf8);
      } else {
        throw Exception('Unable to read file content.');
      }

      // Detect line endings
      final eol = content.contains('\r\n') ? '\r\n' : '\n';

      final rows = CsvToListConverter(eol: eol).convert(content);
      print('Total rows read: ${rows.length}');

      int count = 0;
      final List<Map<String, dynamic>> newCards = [];

      for (int i = 0; i < rows.length; i++) {
        final row = rows[i];

        if (i == 0 &&
            row.length >= 2 &&
            row[0].toString().toLowerCase().contains('question')) {
          print('Skipped header row: $row');
          continue;
        }

        if (row.length >= 2) {
          final question = row[0].toString().trim();
          final answer = row[1].toString().trim();

          if (question.isNotEmpty && answer.isNotEmpty) {
            newCards.add({
              'question': question,
              'answer': answer,
              'isLearned': false,
            });
            print('Added flashcard: "$question" → "$answer"');
            count++;
          } else {
            print('Skipped empty or invalid row: $row');
          }
        } else {
          print('Invalid row (less than 2 columns): $row');
        }
      }

      if (newCards.isNotEmpty) {
        setState(() {
          flashcards.addAll(newCards);
        });

        await _saveFlashcards();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Successfully imported $count flashcards.')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No valid flashcards found in the file.')),
        );
      }
    } catch (e) {
      print('Error while processing file: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An error occurred while importing the file.')),
      );
    }
  }


  void _addFlashcard(String question, String answer) {
    setState(() {
      flashcards.add({
        'question': question,
        'answer': answer,
        'isLearned': false,
      });
    });
    _saveFlashcards();
  }

  void _removeFlashcard(int index) {
    setState(() {
      flashcards.removeAt(index);
    });
    _saveFlashcards();
  }

  void _showEditDialog(int index) {
    final questionController =
    TextEditingController(text: flashcards[index]['question']);
    final answerController =
    TextEditingController(text: flashcards[index]['answer']);

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
                  flashcards[index]['question'] = question;
                  flashcards[index]['answer'] = answer;
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

  void _toggleLearned(int index) {
    setState(() {
      flashcards[index]['isLearned'] = !(flashcards[index]['isLearned'] ?? false);
    });
    _saveFlashcards();
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
          IconButton(
            icon: const Icon(Icons.upload_file),
            tooltip: 'Import flashcard',
            onPressed: _importFlashcards,
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
                front: Card(
                  color: flashcard['isLearned'] == true
                      ? Colors.green.shade100
                      : null,
                  child: ListTile(
                    title: Text(flashcard['question'] ?? ''),
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
                            flashcard['isLearned'] == true
                                ? Icons.check_circle
                                : Icons.check_circle_outline,
                            color: flashcard['isLearned'] == true
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
                  color: flashcard['isLearned'] == true
                      ? Colors.green.shade100
                      : Colors.teal.shade100,
                  child: ListTile(
                    title: Text(flashcard['answer'] ?? '',
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

