import 'dart:math';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:flashcard_app/data/models/flashcard_model.dart';

class PracticeScreen extends StatefulWidget {
  final List<Flashcard> flashcards;

  const PracticeScreen({super.key, required this.flashcards});

  @override
  State<PracticeScreen> createState() => _PracticeScreenState();
}

class _PracticeScreenState extends State<PracticeScreen> {
  late List<Flashcard> shuffledCards;
  int currentIndex = 0;
  int correctCount = 0;
  final TextEditingController _controller = TextEditingController();
  String feedback = '';
  Color feedbackColor = Colors.transparent;
  bool answered = false;

  @override
  void initState() {
    super.initState();
    shuffledCards = [...widget.flashcards];
    shuffledCards.shuffle(Random());
  }

  void _checkAnswer() {
    final userInput = _controller.text.trim().toLowerCase();
    final correctAnswer = shuffledCards[currentIndex].answer.trim().toLowerCase();

    setState(() {
      if (userInput == correctAnswer) {
        feedback = '✅ Chính xác!';
        feedbackColor = Colors.green;
        correctCount++;
      } else {
        feedback = '❌ Sai! Đáp án: ${shuffledCards[currentIndex].answer}';
        feedbackColor = Colors.red;
      }
      answered = true;
    });
  }

  void _nextCard() {
    if (currentIndex < shuffledCards.length - 1) {
      setState(() {
        currentIndex++;
        _controller.clear();
        feedback = '';
        feedbackColor = Colors.transparent;
        answered = false;
      });
    } else {
      _showResult();
    }
  }

  void _showResult() async {
    final total = shuffledCards.length;
    final percent = (correctCount / total * 100).toStringAsFixed(1);
    final percentDouble = double.parse(percent);

    final box = await Hive.openBox('practice_stats');
    final lastCorrect = box.get('last_correct', defaultValue: -1);
    final lastTotal = box.get('last_total', defaultValue: -1);

    await box.put('last_correct', correctCount);
    await box.put('last_total', total);

    String message;
    if (percentDouble < 50) {
      message = 'Đừng nản! Bạn sẽ tiến bộ nếu chăm chỉ hơn 💪';
    } else if (percentDouble < 80) {
      message = 'Tốt lắm! Bạn đang đi đúng hướng 👍';
    } else {
      message = 'Xuất sắc! Bạn thật tuyệt vời! 🌟';
    }

    if (lastCorrect >= 0 && lastTotal > 0) {
      final lastPercent = lastCorrect / lastTotal * 100;
      if (percentDouble > lastPercent) {
        message += '\n💡 Bạn đã tiến bộ so với lần trước!';
      } else if (percentDouble < lastPercent) {
        message += '\n😥 Lần này hơi kém hơn, cố gắng lần sau nhé!';
      } else {
        message += '\n➡️ Kết quả ngang bằng lần trước, hãy tiếp tục!';
      }
    }

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('🎯 Kết quả luyện tập'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('✅ Đúng: $correctCount'),
            Text('❌ Sai: ${total - correctCount}'),
            Text('📊 Tỷ lệ đúng: $percent%'),
            const SizedBox(height: 12),
            Text(message, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final flashcard = shuffledCards[currentIndex];

    return Scaffold(
      appBar: AppBar(title: const Text('Luyện tập nhập đáp án')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Câu ${currentIndex + 1}/${shuffledCards.length}',
              style: const TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  flashcard.question,
                  style: const TextStyle(fontSize: 20),
                ),
              ),
            ),
            const SizedBox(height: 30),
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: 'Nhập câu trả lời của bạn',
                border: OutlineInputBorder(),
              ),
              enabled: !answered,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: feedbackColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: feedbackColor, width: 1),
              ),
              child: Text(
                feedback,
                style: TextStyle(
                  color: feedbackColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: answered ? _nextCard : _checkAnswer,
              child: Text(answered ? 'Tiếp theo' : 'Kiểm tra'),
            ),
          ],
        ),
      ),
    );
  }
}
