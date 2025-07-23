import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flashcard_app/features/flashcard/screens/flashcard_screen.dart';
import 'package:flashcard_app/features/daily/screens/daily_flashcard_screen.dart';

class DeckListScreen extends StatefulWidget {
  const DeckListScreen({super.key});

  @override
  State<DeckListScreen> createState() => _DeckListScreenState();
}

class _DeckListScreenState extends State<DeckListScreen> {
  Map<String, int> deckCounts = {};
  Map<String, String> deckIcons = {};

  final List<String> iconOptions = [
    'book', 'star', 'lightbulb', 'memory',
    'science', 'translate', 'brush', 'code', 'travel', 'folder'
  ];

  @override
  void initState() {
    super.initState();
    _loadDecks();
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

  Future<void> _loadDecks() async {
    final prefs = await SharedPreferences.getInstance();
    final String? decksJson = prefs.getString('allDecks');
    if (decksJson != null) {
      final Map<String, dynamic> decoded = jsonDecode(decksJson);
      setState(() {
        deckCounts = {
          for (final entry in decoded.entries)
            entry.key: (entry.value['cards'] as List).length
        };
        deckIcons = {
          for (final entry in decoded.entries)
            entry.key: entry.value['icon'] ?? 'folder'
        };
      });
    }
  }

  Future<void> _saveNewDeck(String name, String iconName) async {
    final prefs = await SharedPreferences.getInstance();
    final String? decksJson = prefs.getString('allDecks');
    final Map<String, dynamic> decoded =
    decksJson != null ? jsonDecode(decksJson) : {};

    decoded[name] = {
      'cards': [],
      'icon': iconName,
    };

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
                  _saveNewDeck(newDeckName.trim(), selectedIcon);
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
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();
                final String? decksJson = prefs.getString('allDecks');
                if (decksJson == null) return;

                final decoded = jsonDecode(decksJson) as Map<String, dynamic>;
                if (!decoded.containsKey(oldName)) return;

                final deckData = decoded[oldName];

                if (newName != oldName) {
                  decoded.remove(oldName);
                }

                decoded[newName] = {
                  'cards': deckData['cards'],
                  'icon': selectedIcon,
                };

                await prefs.setString('allDecks', jsonEncode(decoded));
                Navigator.pop(context);
                _loadDecks();
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
    final deckNames = deckCounts.keys.toList();

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

          final deckIndex = index - 1;
          final deckName = deckNames[deckIndex];
          final cardCount = deckCounts[deckName] ?? 0;
          final iconName = deckIcons[deckName] ?? 'folder';

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
                _getIconFromName(iconName),
                color: _getIconColorFromName(iconName),
              ),
              title: Text('$deckName ($cardCount thẻ)'),
              trailing: IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => _showEditDeckDialog(deckName, iconName),
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
