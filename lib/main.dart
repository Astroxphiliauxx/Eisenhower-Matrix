import 'package:flutter/material.dart';
import 'package:noteapp/view/note_list.dart';
import 'package:noteapp/viewmodels/note_list_state.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => NoteListState()),

      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'NoteApp',
        theme: ThemeData(
          primaryColor: Colors.black,
          textTheme: const TextTheme(),
          primarySwatch: Colors.blue,
        ),
        // home: const PasswordInputScreen1(),
        home: NoteList(),
      ),
    );
  }
}
