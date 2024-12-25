import 'package:flutter/material.dart';

import '../models/note.dart';

class NoteListState with ChangeNotifier {
  List<Note> _notes = [];
  List<bool> _noteLockedStates = [];

  List<Note> get notes => _notes;
  List<bool> get noteLockedStates => _noteLockedStates;

  void toggleNoteLock(int index) {
    _noteLockedStates[index] = !_noteLockedStates[index];
    notifyListeners();
  }

  bool isNoteLocked(int index) {
    return _noteLockedStates[index];
  }

}