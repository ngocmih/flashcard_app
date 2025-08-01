import 'package:hive/hive.dart';
import 'flashcard_model.dart';

part 'deck_model.g.dart';

@HiveType(typeId: 1)
class Deck extends HiveObject {
  @HiveField(0)
  final String title;

  @HiveField(1)
  final String iconName;

  @HiveField(2)
  final List<Flashcard> flashcards;

  Deck({
    required this.title,
    required this.iconName,
    required this.flashcards,
  });

  factory Deck.fromMap(Map<String, dynamic> map) => Deck(
    title: map['title'],
    iconName: map['iconName'],
    flashcards: (map['flashcards'] as List)
        .map((e) => Flashcard.fromJson(Map<String, dynamic>.from(e)))
        .toList(),
  );

  Map<String, dynamic> toMap() => {
    'title': title,
    'iconName': iconName,
    'flashcards': flashcards.map((f) => f.toJson()).toList(),
  };
}
