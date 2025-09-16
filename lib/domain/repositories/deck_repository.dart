// lib/domain/repositories/deck_repository.dart
import '../entities/deck.dart';


abstract class DeckRepository {
  Future<List<Deck>> getAll();
  Future<Deck> create(String name);
  Future<void> rename(String deckId, String newName);
  Future<void> delete(String deckId);
}