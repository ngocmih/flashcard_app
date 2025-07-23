import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DailyFlashcardScreen extends StatefulWidget {
  const DailyFlashcardScreen({super.key});

  @override
  State<DailyFlashcardScreen> createState() => _DailyFlashcardScreenState();
}

class _DailyFlashcardScreenState extends State<DailyFlashcardScreen> {
  Map<String, dynamic>? flashcard;

  @override
  void initState() {
    super.initState();
    _loadDailyFlashcard();
  }

  Future<void> _loadDailyFlashcard() async {
    final prefs = await SharedPreferences.getInstance();
    final String? storedDate = prefs.getString('daily_flashcard_date');
    final String? storedCard = prefs.getString('daily_flashcard_data');

    final String today = DateTime.now().toIso8601String().split('T').first;

    if (storedDate == today && storedCard != null) {
      setState(() {
        flashcard = jsonDecode(storedCard);
      });
      return;
    }

    final String? allDecks = prefs.getString('allDecks');
    if (allDecks == null) return;

    final Map<String, dynamic> decks = jsonDecode(allDecks);
    final List<Map<String, dynamic>> allCards = [];

    for (final entry in decks.entries) {
      final deckCards = (entry.value as List).cast<Map>();
      for (final card in deckCards) {
        allCards.add({
          'deck': entry.key,
          'question': card['question'],
          'answer': card['answer'],
        });
      }
    }

    if (allCards.isEmpty) return;

    final randomCard = allCards[Random().nextInt(allCards.length)];

    await prefs.setString('daily_flashcard_date', today);
    await prefs.setString('daily_flashcard_data', jsonEncode(randomCard));

    setState(() {
      flashcard = randomCard;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Flashcard hôm nay')),
      body: flashcard == null
          ? const Center(child: Text('Không có flashcard nào'))
          : Padding(
        padding: const EdgeInsets.all(24),
        child: Card(
          elevation: 4,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text('🔖 Bộ: ${flashcard!['deck']}',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('🧠 Câu hỏi:\n${flashcard!['question']}',
                    style: const TextStyle(fontSize: 18)),
              ),
              const Divider(),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text('💡 Đáp án:\n${flashcard!['answer']}',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
