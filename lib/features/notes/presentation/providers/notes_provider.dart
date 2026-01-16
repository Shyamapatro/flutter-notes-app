import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repository/notes_repository.dart';
import '../../data/models/note.dart';

// Repository Provider
final notesRepositoryProvider = Provider<NotesRepository>((ref) {
  return NotesRepository();
});

// Notes List Stream Provider
final notesListProvider = StreamProvider<List<Note>>((ref) {
  final repository = ref.watch(notesRepositoryProvider);
  return repository.watchAllNotes();
});

// Current Note Provider (Family)
final noteDetailProvider = FutureProvider.family<Note, String>((ref, id) {
  final repository = ref.watch(notesRepositoryProvider);
  return repository.getNoteById(id);
});
