import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'data/models/flashcard_model.dart';
import 'data/models/deck_model.dart';
import 'features/deck/screens/deck_list_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _initHive();

  runApp(const FlashcardApp());
}

Future<void> _initHive() async {
  await Hive.initFlutter();
  Hive.registerAdapter(FlashcardAdapter());
  Hive.registerAdapter(DeckAdapter());
  await Hive.openBox<Deck>('decksBox');
}

class FlashcardApp extends StatelessWidget {
  const FlashcardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flashcard App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.teal,
        useMaterial3: true,
      ),
      home: const DeckListScreen(),
    );
  }
}
