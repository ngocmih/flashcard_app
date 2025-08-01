import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flashcard_app/data/models/flashcard_model.dart';

class FlashcardService {
  Future<List<Flashcard>> loadFlashcards(String deckName) async {
    final prefs = await SharedPreferences.getInstance();
    final decksData = prefs.getString('allDecks');
    if (decksData != null) {
      final decoded = jsonDecode(decksData) as Map<String, dynamic>;
      final deckObject = decoded[deckName];
      if (deckObject != null && deckObject['cards'] != null) {
        final List<dynamic> cardList = deckObject['cards'];
        return cardList.map((item) => Flashcard.fromJson(item)).toList();
      }
    }
    return [];
  }

  Future<void> saveFlashcards(String deckName, List<Flashcard> cards) async {
    final prefs = await SharedPreferences.getInstance();
    final decksData = prefs.getString('allDecks');
    final Map<String, dynamic> decoded =
    decksData != null ? jsonDecode(decksData) : {};

    decoded[deckName] = {
      'icon': 'folder',
      'cards': cards.map((card) => card.toJson()).toList(),
    };

    await prefs.setString('allDecks', jsonEncode(decoded));
  }
}
