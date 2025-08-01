import 'package:hive/hive.dart';

part 'flashcard_model.g.dart';

@HiveType(typeId: 0)
class Flashcard extends HiveObject {
  @HiveField(0)
  final String question;

  @HiveField(1)
  final String answer;

  @HiveField(2)
  final bool isLearned;

  @HiveField(3)
  final String? deck;

  Flashcard({
    required this.question,
    required this.answer,
    this.isLearned = false,
    this.deck,
  });

  factory Flashcard.fromJson(Map<String, dynamic> json) => Flashcard(
    question: json['question'],
    answer: json['answer'],
    isLearned: json['isLearned'] ?? false,
    deck: json['deck'],
  );

  Map<String, dynamic> toJson() => {
    'question': question,
    'answer': answer,
    'isLearned': isLearned,
    'deck': deck,
  };
}
