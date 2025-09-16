// lib/domain/entities/deck.dart
import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';
part 'deck.g.dart';


@HiveType(typeId: 1)
class Deck extends Equatable {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String name;
  @HiveField(2)
  final int cardCount; // có thể tính động ở repo nếu muốn


  const Deck({required this.id, required this.name, this.cardCount = 0});


  Deck copyWith({String? id, String? name, int? cardCount}) => Deck(
    id: id ?? this.id,
    name: name ?? this.name,
    cardCount: cardCount ?? this.cardCount,
  );


  @override
  List<Object?> get props => [id, name, cardCount];
}