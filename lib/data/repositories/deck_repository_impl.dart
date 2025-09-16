// lib/data/repositories/deck_repository_impl.dart
import 'package:uuid/uuid.dart';
import '../../domain/entities/deck.dart';
import '../../domain/repositories/deck_repository.dart';
import '../datasources/local/hive_boxes.dart';


class DeckRepositoryImpl implements DeckRepository {
  final _uuid = const Uuid();


  @override
  Future<List<Deck>> getAll() async {
    final list = HiveBoxes.decks.values.toList();
// cập nhật cardCount (đếm theo deckId)
    final counts = <String, int>{};
    for (final c in HiveBoxes.cards.values) {
      counts.update(c.deckId, (v) => v + 1, ifAbsent: () => 1);
    }
    return list.map((d) => d.copyWith(cardCount: counts[d.id] ?? 0)).toList();
  }


  @override
  Future<Deck> create(String name) async {
    final deck = Deck(id: _uuid.v4(), name: name);
    await HiveBoxes.decks.put(deck.id, deck);
    return deck;
  }


  @override
  Future<void> rename(String deckId, String newName) async {
    final old = HiveBoxes.decks.get(deckId);
    if (old == null) return;
    await HiveBoxes.decks.put(deckId, old.copyWith(name: newName));
  }


  @override
  Future<void> delete(String deckId) async {
    await HiveBoxes.decks.delete(deckId);
// xoá các card thuộc deck này
    final toDelete = HiveBoxes.cards.values.where((c) => c.deckId == deckId).toList();
    for (final c in toDelete) {
      await HiveBoxes.cards.delete(c.id);
    }
  }
}