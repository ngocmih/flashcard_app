import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_animate/flutter_animate.dart';

class PracticeChoiceScreen extends StatefulWidget {
  final List<Map<String, dynamic>> flashcards;

  const PracticeChoiceScreen({super.key, required this.flashcards});

  @override
  State<PracticeChoiceScreen> createState() => _PracticeChoiceScreenState();
}

class _PracticeChoiceScreenState extends State<PracticeChoiceScreen> {
  late List<Map<String, dynamic>> shuffled;
  int currentIndex = 0;
  int correctCount = 0;
  bool answered = false;
  int? selectedIndex;
  List<String> options = [];

  final AudioPlayer _player = AudioPlayer();

  @override
  void initState() {
    super.initState();
    shuffled = [...widget.flashcards];
    shuffled.shuffle();
    _generateOptions();
  }

  void _generateOptions() {
    final correct = (shuffled[currentIndex]['answer'] ?? '') as String;
    final allAnswers = widget.flashcards.map((e) => e['answer'] ?? '').toSet().toList();

    allAnswers.remove(correct);
    allAnswers.shuffle();

    options = [correct, ...allAnswers.take(3).cast<String>()];
    options.shuffle();
    answered = false;
    selectedIndex = null;
  }

  void _selectAnswer(int index) {
    if (answered) return;

    final isCorrect = options[index] == shuffled[currentIndex]['answer'];
    setState(() {
      selectedIndex = index;
      answered = true;
      if (isCorrect) {
        correctCount++;
      }
    });

    _playSound(isCorrect);
  }

  Future<void> _playSound(bool correct) async {
    await _player.stop();
    await _player.play(
      AssetSource(correct ? 'sounds/correct.mp3' : 'sounds/wrong.mp3'),
    );
  }

  void _next() {
    if (currentIndex < shuffled.length - 1) {
      setState(() {
        currentIndex++;
        _generateOptions();
      });
    } else {
      _showResult();
    }
  }

  void _showResult() {
    final total = shuffled.length;
    final percent = (correctCount / total * 100).toStringAsFixed(1);
    final p = double.parse(percent);

    String message;
    if (p < 50) {
      message = 'Đừng nản! Bạn sẽ tiến bộ nếu chăm chỉ hơn 💪';
    } else if (p < 80) {
      message = 'Tốt lắm! Bạn đang đi đúng hướng 👍';
    } else {
      message = 'Xuất sắc! Bạn thật tuyệt vời! 🌟';
    }

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('🎯 Kết quả luyện tập'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('✅ Đúng: $correctCount'),
            Text('📊 Tỷ lệ đúng: $percent%'),
            const SizedBox(height: 12),
            Text(
              message,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: p >= 80
                    ? Colors.green
                    : (p >= 50 ? Colors.orange : Colors.red),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // đóng dialog
              Navigator.pop(context); // quay về màn chính
            },
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final question = shuffled[currentIndex]['question'] ?? '';
    final answer = shuffled[currentIndex]['answer'] ?? '';

    return Scaffold(
      appBar: AppBar(title: const Text('Luyện tập trắc nghiệm')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Câu ${currentIndex + 1}/${shuffled.length}',
                textAlign: TextAlign.center),
            const SizedBox(height: 20),
            Text(
              question,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),

            // Các lựa chọn
            ...List.generate(options.length, (i) {
              final isCorrect = options[i] == answer;
              Color? color;
              if (answered) {
                if (i == selectedIndex) {
                  color = isCorrect ? Colors.green : Colors.red;
                } else if (isCorrect) {
                  color = Colors.green.withOpacity(0.5);
                }
              }

              final choiceButton = _buildChoiceButton(i, color, isCorrect);

              // Nếu sai và đã chọn => rung
              if (i == selectedIndex && answered && !isCorrect) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: Animate(
                    effects: const [ShakeEffect()],
                    child: choiceButton,
                  ),
                );

              } else {
                return choiceButton;
              }
            }),

            const Spacer(),
            ElevatedButton(
              onPressed: answered ? _next : null,
              child: Text(currentIndex == shuffled.length - 1
                  ? 'Kết thúc'
                  : 'Câu tiếp'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChoiceButton(int i, Color? color, bool isCorrect) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color ?? Theme.of(context).primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          textStyle: const TextStyle(fontSize: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: answered
                ? BorderSide(
              color: i == selectedIndex
                  ? (isCorrect ? Colors.green : Colors.red)
                  : Colors.transparent,
              width: 1.5,
            )
                : BorderSide.none,
          ),
        ),
        onPressed: () => _selectAnswer(i),
        child: Text(options[i]),
      ),
    );
  }
}
