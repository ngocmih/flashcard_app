// lib/features/deck/bloc/deck_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'deck_event.dart';
import 'deck_state.dart';
import '../../../domain/repositories/deck_repository.dart';


class DeckBloc extends Bloc<DeckEvent, DeckState> {
  final DeckRepository repo;
  DeckBloc(this.repo) : super(const DeckState()) {
    on<DeckFetched>(_onFetched);
    on<DeckCreated>(_onCreated);
    on<DeckRenamed>(_onRenamed);
    on<DeckDeleted>(_onDeleted);
  }


  Future<void> _onFetched(DeckFetched e, Emitter<DeckState> emit) async {
    emit(state.copyWith(status: DeckStatus.loading));
    try {
      final items = await repo.getAll();
      emit(state.copyWith(status: DeckStatus.success, items: items));
    } catch (err) {
      emit(state.copyWith(status: DeckStatus.failure, error: err.toString()));
    }
  }


  Future<void> _onCreated(DeckCreated e, Emitter<DeckState> emit) async {
    await repo.create(e.name);
    add(DeckFetched());
  }


  Future<void> _onRenamed(DeckRenamed e, Emitter<DeckState> emit) async {
    await repo.rename(e.id, e.name);
    add(DeckFetched());
  }


  Future<void> _onDeleted(DeckDeleted e, Emitter<DeckState> emit) async {
    await repo.delete(e.id);
    add(DeckFetched());
  }
}