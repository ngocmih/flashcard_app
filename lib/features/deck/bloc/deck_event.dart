// lib/features/deck/bloc/deck_event.dart
import 'package:equatable/equatable.dart';


abstract class DeckEvent extends Equatable {
  const DeckEvent();
  @override
  List<Object?> get props => [];
}


class DeckFetched extends DeckEvent {}
class DeckCreated extends DeckEvent { final String name; const DeckCreated(this.name); }
class DeckRenamed extends DeckEvent { final String id; final String name; const DeckRenamed(this.id, this.name); }
class DeckDeleted extends DeckEvent { final String id; const DeckDeleted(this.id); }