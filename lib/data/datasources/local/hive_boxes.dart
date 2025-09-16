// lib/data/datasources/local/hive_boxes.dart
import 'package:hive_flutter/hive_flutter.dart';
import '../../../domain/entities/deck.dart';
import '../../../domain/entities/flashcard.dart';


class HiveBoxes {
  static Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(DeckAdapter());
    Hive.registerAdapter(FlashcardAdapter());
    await Hive.openBox<Deck>('decks');
    await Hive.openBox<Flashcard>('cards');
  }


  static Box<Deck> get decks => Hive.box<Deck>('decks');
  static Box<Flashcard> get cards => Hive.box<Flashcard>('cards');
}