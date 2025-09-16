// lib/features/deck/presentation/screens/deck_list_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/deck_bloc.dart';
import '../../bloc/deck_event.dart';
import '../../bloc/deck_state.dart';


class DeckListScreen extends StatefulWidget {
  const DeckListScreen({super.key});
  @override
  State<DeckListScreen> createState() => _DeckListScreenState();
}


class _DeckListScreenState extends State<DeckListScreen> {
  @override
  void initState() {
    super.initState();
    context.read<DeckBloc>().add(DeckFetched());
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('Your Decks')),
        body: BlocBuilder<DeckBloc, DeckState>(
        builder: (context, state) {
      switch (state.status) {
      case DeckStatus.loading:
      return const Center(child: CircularProgressIndicator());
      case DeckStatus.failure:
      return Center(child: Text(state.error ?? 'Error'));
      case DeckStatus.success:
      if (state.items.isEmpty) {
      return const Center(child: Text('No decks yet'));
      }
      return ListView.builder(
      itemCount: state.items.length,
      itemBuilder: (_, i) {
      final d = state.items[i];
      return ListTile(
      title: Text(d.name),
      subtitle: Text('${d.cardCount} cards'),
      onTap: () {/* push to deck detail */},
      trailing: PopupMenuButton(
      itemBuilder: (_) => [
      const PopupMenuItem(value: 'rename', child: Text('Rename')),
      }