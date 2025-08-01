import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:flashcard_app/data/models/deck_model.dart';
import 'package:flashcard_app/features/flashcard/screens/flashcard_screen.dart';
import 'package:flashcard_app/features/daily/screens/daily_flashcard_screen.dart';

class DeckListScreen extends StatefulWidget {
  const DeckListScreen({super.key});

  @override
  State<DeckListScreen> createState() => _DeckListScreenState();
}

class _DeckListScreenState extends State<DeckListScreen> {
  late Box<Deck> deckBox;

  final List<String> iconOptions = [
    'book', 'star', 'lightbulb', 'memory',
    'science', 'translate', 'brush', 'code', 'travel', 'folder'
  ];

  @override
  void initState() {
    super.initState();
    deckBox = Hive.box<Deck>('decksBox');
  }

  IconData _getIconFromName(String? iconName) {
    switch (iconName) {
      case 'book': return Icons.book;
      case 'star': return Icons.star;
      case 'lightbulb': return Icons.lightbulb;
      case 'memory': return Icons.memory;
      case 'science': return Icons.science;
      case 'translate': return Icons.translate;
      case 'brush': return Icons.brush;
      case 'code': return Icons.code;
      case 'travel': return Icons.flight;
      case 'folder':
      default: return Icons.folder;
    }
  }

  Color _getIconColorFromName(String? iconName) {
    switch (iconName) {
      case 'book': return Colors.brown;
      case 'star': return Colors.amber;
      case 'lightbulb': return Colors.yellow.shade700;
      case 'memory': return Colors.deepPurple;
      case 'science': return Colors.teal;
      case 'translate': return Colors.blue;
      case 'brush': return Colors.pink;
      case 'code': return Colors.green;
      case 'travel': return Colors.indigo;
      case 'folder':
      default: return Colors.grey;
    }
  }

  void _addDeck(String name, String iconName) {
    final newDeck = Deck(title: name, iconName: iconName, flashcards: []);
    deckBox.put(name, newDeck);
    setState(() {});
  }

  void _editDeck(String oldName, String newName, String newIcon) {
    final oldDeck = deckBox.get(oldName);
    if (oldDeck != null) {
      final updatedDeck = Deck(
        title: newName,
        iconName: newIcon,
        flashcards: oldDeck.flashcards,
      );
      deckBox.delete(oldName);
      deckBox.put(newName, updatedDeck);
      setState(() {});
    }
  }

  void _deleteDeck(String name) {
    deckBox.delete(name);
    setState(() {});
  }

  void _showAddDeckDialog() {
    String newDeckName = '';
    String selectedIcon = 'folder';

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Tạo bộ thẻ mới'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                onChanged: (value) => newDeckName = value,
                decoration: const InputDecoration(labelText: 'Tên bộ thẻ'),
              ),
              const SizedBox(height: 16),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Chọn icon cho bộ thẻ:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 10,
                children: iconOptions.map((iconName) {
                  return GestureDetector(
                    onTap: () => setState(() => selectedIcon = iconName),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: selectedIcon == iconName
                              ? Colors.blue
                              : Colors.grey.shade300,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        _getIconFromName(iconName),
                        size: 30,
                        color: _getIconColorFromName(iconName),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (newDeckName.trim().isNotEmpty) {
                  _addDeck(newDeckName.trim(), selectedIcon);
                }
                Navigator.pop(context);
              },
              child: const Text('Thêm'),
            )
          ],
        ),
      ),
    );
  }

  void _showEditDeckDialog(String oldName, String oldIcon) {
    String newName = oldName;
    String selectedIcon = oldIcon;

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Sửa bộ thẻ'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(hintText: 'Tên mới'),
                controller: TextEditingController(text: oldName),
                onChanged: (value) => newName = value,
              ),
              const SizedBox(height: 12),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text('Chọn icon mới:', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: iconOptions.map((iconName) {
                  return GestureDetector(
                    onTap: () => setState(() => selectedIcon = iconName),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: selectedIcon == iconName
                              ? Colors.blue
                              : Colors.grey.shade300,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        _getIconFromName(iconName),
                        size: 28,
                        color: _getIconColorFromName(iconName),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Huỷ'),
            ),
            TextButton(
              onPressed: () {
                _editDeck(oldName, newName, selectedIcon);
                Navigator.pop(context);
              },
              child: const Text('Lưu'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final deckNames = deckBox.keys.cast<String>().toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Your Decks')),
      body: ListView.builder(
        itemCount: deckNames.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return ListTile(
              leading: const Icon(Icons.today),
              title: const Text('Flashcard ngẫu nhiên hôm nay'),
              subtitle: const Text('Ôn luyện 1 câu bất kỳ mỗi ngày'),
              tileColor: Colors.lightBlue.shade50,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const DailyFlashcardScreen(),
                  ),
                );
              },
            );
          }

          final deckName = deckNames[index - 1];
          final deck = deckBox.get(deckName);

          if (deck == null) return const SizedBox();

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
              leading: Icon(
                _getIconFromName(deck.iconName),
                color: _getIconColorFromName(deck.iconName),
              ),
              title: Text('${deck.title} (${deck.flashcards.length} thẻ)'),
              trailing: IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => _showEditDeckDialog(deck.title, deck.iconName),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => FlashcardScreen(deckName: deck.title),
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
