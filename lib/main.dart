// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/router/app_router.dart';
import 'data/datasources/local/hive_boxes.dart';
import 'data/repositories/deck_repository_impl.dart';
import 'domain/repositories/deck_repository.dart';
import 'features/deck/bloc/deck_bloc.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveBoxes.init();


  final DeckRepository deckRepo = DeckRepositoryImpl();


  runApp(MyApp(deckRepo: deckRepo));
}


class MyApp extends StatelessWidget {
  final DeckRepository deckRepo;
  const MyApp({super.key, required this.deckRepo});


  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => DeckBloc(deckRepo)),
// BlocProvider(create: (_) => FlashcardBloc(flashRepo)),
// BlocProvider(create: (_) => PracticeBloc(flashRepo)),
      ],
      child: MaterialApp(
        title: 'Flashcard App',
        home: const DeckListScreen(),
        onGenerateRoute: AppRouter.onGenerateRoute,
      ),
    );
  }
}