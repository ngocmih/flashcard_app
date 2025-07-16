import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'flashcard_screen.dart';

class DeckListScreen extends StatefulWidget {
  const DeckListScreen({super.key});

  @override
  State<DeckListScreen> createState() => _DeckListScreenState();
}

class _DeckListScreenState extends State<DeckListScreen> {
  Map<String, int> deckCounts = {};

  @override
  void initState() {
    super.initState();
    _loadDecks();
  }

  Future<void> _loadDecks() async {
    final prefs = await SharedPreferences.getInstance();
    final String? decksJson = prefs.getString('allDecks');
    if (decksJson != null) {
      final Map<String, dynamic> decoded = jsonDecode(decksJson);
      setState(() {
        deckCounts = {
          for (final entry in decoded.entries)
            entry.key: (entry.value as List).length
        };
      });
    }
  }

  Future<void> _saveNewDeck(String name) async {
    final prefs = await SharedPreferences.getInstance();
    final String? decksJson = prefs.getString('allDecks');
    final Map<String, dynamic> decoded =
    decksJson != null ? jsonDecode(decksJson) : {};

    decoded[name] = []; // tạo bộ thẻ mới
    await prefs.setString('allDecks', jsonEncode(decoded));
    _loadDecks();
  }

  Future<void> _deleteDeck(String name) async {
    final prefs = await SharedPreferences.getInstance();
    final String? decksJson = prefs.getString('allDecks');
    if (decksJson != null) {
      final Map<String, dynamic> decoded = jsonDecode(decksJson);
      decoded.remove(name);
      await prefs.setString('allDecks', jsonEncode(decoded));
      _loadDecks();
    }
  }

  void _showAddDeckDialog() {
    String newDeckName = '';
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('New Deck'),
        content: TextField(
          onChanged: (value) => newDeckName = value,
          decoration: const InputDecoration(labelText: 'Deck name'),
        ),
        actions: [
          TextButton(
            onPressed: () {
              if (newDeckName.trim().isNotEmpty) {
                _saveNewDeck(newDeckName.trim());
              }
              Navigator.pop(context);
            },
            child: const Text('Add'),
          )
        ],
      ),
    );
  }

  void _showRenameDialog(String oldName) {
    String newName = '';
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Đổi tên bộ thẻ'),
        content: TextField(
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Tên mới'),
          onChanged: (value) => newName = value,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Huỷ'),
          ),
          TextButton(
            onPressed: () async {
              if (newName.trim().isEmpty || newName == oldName) {
                Navigator.pop(context);
                return;
              }

              final prefs = await SharedPreferences.getInstance();
              final data = prefs.getString('allDecks');
              if (data != null) {
                final decoded = jsonDecode(data) as Map<String, dynamic>;
                if (decoded.containsKey(oldName)) {
                  decoded[newName] = decoded[oldName];
                  decoded.remove(oldName);
                  await prefs.setString('allDecks', jsonEncode(decoded));
                }
              }

              Navigator.pop(context);
              _loadDecks();
            },
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final deckNames = deckCounts.keys.toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Your Decks')),
      body: ListView.builder(
        itemCount: deckNames.length,
        itemBuilder: (context, index) {
          final deckName = deckNames[index];
          final cardCount = deckCounts[deckName] ?? 0;

          return Dismissible(
            key: Key(deckName),
            background: Container(
              color: Colors.red,
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            direction: DismissDirection.endToStart,
            confirmDismiss: (_) async {
              return await showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('Xác nhận xoá'),
                  content: Text('Bạn có chắc muốn xoá bộ "$deckName"?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('Huỷ'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: const Text('Xoá'),
                    ),
                  ],
                ),
              );
            },
            onDismissed: (_) => _deleteDeck(deckName),
            child: ListTile(
              title: Text('$deckName ($cardCount thẻ)'),
              trailing: IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => _showRenameDialog(deckName),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => FlashcardScreen(deckName: deckName),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDeckDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
