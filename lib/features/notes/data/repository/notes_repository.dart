import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/note.dart';

class NotesRepository {
  final SupabaseClient _supabase;

  NotesRepository() : _supabase = Supabase.instance.client;

  // Notes Stream (Realtime)
  Stream<List<Note>> watchAllNotes() {
    return _supabase
        .from('notes')
        .stream(primaryKey: ['id'])
        .order('is_pinned', ascending: false)
        .order('updated_at', ascending: false)
        .map((data) => data.map((json) => Note.fromJson(json)).toList());
  }

  Future<Note> getNoteById(String id) async {
    final response = await _supabase.from('notes').select().eq('id', id).single();
    return Note.fromJson(response);
  }

  Future<void> createNote(Note note) async {
    await _supabase.from('notes').insert(note.toJson());
  }

  Future<void> updateNote(Note note) async {
    await _supabase.from('notes').update(note.toJson()).match({'id': note.id});
  }

  Future<void> deleteNote(String id) async {
    await _supabase.from('notes').delete().match({'id': id});
  }
}
