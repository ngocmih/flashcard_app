// lib/domain/entities/flashcard.dart
import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';
part 'flashcard.g.dart';


@HiveType(typeId: 2)
class Flashcard extends Equatable {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String deckId;
  @HiveField(2)
  final String question;
  @HiveField(3)
  final String answer;
  @HiveField(4)
  final int ease; // dùng cho spaced repetition
  @HiveField(5)
  final DateTime? due; // lịch ôn tập


  const Flashcard({
    required this.id,
    required this.deckId,
    required this.question,
    required this.answer,
    this.ease = 250,
    this.due,
  });


  Flashcard copyWith({
    String? id,
    String? deckId,
    String? question,
    String? answer,
    int? ease,
    DateTime? due,
  }) => Flashcard(
    id: id ?? this.id,
    deckId: deckId ?? this.deckId,
    question: question ?? this.question,
    answer: answer ?? this.answer,
    ease: ease ?? this.ease,
    due: due ?? this.due,
  );


  @override
  List<Object?> get props => [id, deckId, question, answer, ease, due];
}