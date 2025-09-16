// lib/features/deck/bloc/deck_state.dart
import 'package:equatable/equatable.dart';
import '../../../domain/entities/deck.dart';


enum DeckStatus { initial, loading, success, failure }


class DeckState extends Equatable {
  final DeckStatus status;
  final List<Deck> items;
  final String? error;


  const DeckState({
    this.status = DeckStatus.initial,
    this.items = const [],
    this.error,
  });


  DeckState copyWith({DeckStatus? status, List<Deck>? items, String? error}) => DeckState(
    status: status ?? this.status,
    items: items ?? this.items,
    error: error,
  );


  @override
  List<Object?> get props => [status, items, error];
}