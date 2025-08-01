import 'dart:math';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:flashcard_app/data/models/flashcard_model.dart';
import 'package:flashcard_app/data/models/deck_model.dart';

class DailyFlashcardScreen extends StatefulWidget {
  const DailyFlashcardScreen({super.key});

  @override
  State<DailyFlashcardScreen> createState() => _DailyFlashcardScreenState();
}

class _DailyFlashcardScreenState extends State<DailyFlashcardScreen> {
  Flashcard? flashcard;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDailyFlashcard();
  }

  Future<void> _loadDailyFlashcard() async {
    final box = Hive.box<Deck>('decksBox');
    final allDecks = box.values.toList();

    final List<Flashcard> allCards = [
      for (final deck in allDecks)
        for (final card in deck.flashcards)
          Flashcard(
            question: card.question,
            answer: card.answer,
            deck: deck.title,
          )
    ];

    if (!mounted) return;

    setState(() {
      isLoading = false;
      flashcard =
      allCards.isNotEmpty ? allCards[Random().nextInt(allCards.length)] : null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('📅 Flashcard hôm nay')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Builder(
          builder: (_) {
            if (isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (flashcard == null) {
              return const Center(child: Text('Không có flashcard nào.'));
            }

            return Card(
              elevation: 4,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    title: Text('🔖 Bộ: ${flashcard!.deck}',
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('🧠 Câu hỏi:\n${flashcard!.question}',
                        style: const TextStyle(fontSize: 18)),
                  ),
                  const Divider(),
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Text('💡 Đáp án:\n${flashcard!.answer}',
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
