import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For HapticFeedback
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../data/models/note.dart';
import '../providers/notes_provider.dart';

class NoteEditorScreen extends ConsumerStatefulWidget {
  final String noteId;
  const NoteEditorScreen({super.key, required this.noteId});

  @override
  ConsumerState<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends ConsumerState<NoteEditorScreen> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  String? _originalNoteId;
  bool _isNew = false;
  bool _isDirty = false;
  bool _isDeleted = false; 

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _contentController = TextEditingController();
    
    if (widget.noteId == 'new') {
      _isNew = true;
      _originalNoteId = const Uuid().v4();
    } else {
      _originalNoteId = widget.noteId;
      // Fetch existing data
      WidgetsBinding.instance.addPostFrameCallback((_) async {
         final note = await ref.read(notesRepositoryProvider).getNoteById(widget.noteId);
         _titleController.text = note.title;
         _contentController.text = note.content;
         if (mounted) setState(() {});
      });
    }

    _titleController.addListener(_markDirty);
    _contentController.addListener(_markDirty);
  }

  void _markDirty() {
    if (!_isDirty) {
      setState(() {
        _isDirty = true;
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _saveNote({bool showToast = false}) async {
    // Dismiss Keybaord
    FocusManager.instance.primaryFocus?.unfocus();

    if (_isDeleted) return; 
    
    // Safety: If nothing changed and not new, just return (unless forced).
    if (!_isDirty && !_isNew) {
       if (showToast && mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Note Saved! ☁️'), 
            duration: Duration(milliseconds: 1000),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return;
    }
    
    if (_titleController.text.trim().isEmpty && _contentController.text.trim().isEmpty) return; 

    try {
      final repository = ref.read(notesRepositoryProvider);
      final now = DateTime.now();

      final note = Note(
        id: _originalNoteId!,
        title: _titleController.text,
        content: _contentController.text,
        isPinned: false, 
        isArchived: false,
        createdAt: now, 
        updatedAt: now,
      );

      if (_isNew) {
        await repository.createNote(note);
        _isNew = false; 
      } else {
        final current = await repository.getNoteById(_originalNoteId!);
        final updated = current.copyWith(
          title: _titleController.text,
          content: _contentController.text,
          updatedAt: now,
        );
        await repository.updateNote(updated);
      }
      
      _isDirty = false;
      
      if (showToast && mounted) {
        HapticFeedback.mediumImpact();
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Note Saved! ☁️'), 
            duration: Duration(milliseconds: 1000),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving note: $e'), backgroundColor: Colors.red),
        );
      }
      debugPrint('Note Save Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final backgroundColor = theme.colorScheme.surface;

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) {
          await _saveNote(showToast: false);
        }
      },
      child: Scaffold(
        backgroundColor: backgroundColor,
        body: SafeArea(
          child: Column(
            children: [
              // Custom Header
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: theme.colorScheme.onSurface.withOpacity(0.05), width: 1),
                  ),
                ),
                child: Row(
                  children: [
                    // BACK BUTTON
                    _EditorActionButton(
                      label: 'BACK',
                      icon: Icons.arrow_back_ios_new_rounded,
                      onPressed: () async {
                         await _saveNote(showToast: false);
                         if (mounted) {
                           if (context.canPop()) {
                             context.pop();
                           } else {
                             context.go('/'); // Fallback
                           }
                         }
                      },
                    ),
                    const Spacer(),
                    
                    // DELETE BUTTON
                    if (!_isNew)
                      _EditorActionButton(
                        label: 'DELETE',
                        icon: Icons.delete_outline_rounded,
                        color: Colors.redAccent,
                        onPressed: () async {
                           FocusManager.instance.primaryFocus?.unfocus();
                           final confirm = await showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text('Delete Note?'),
                              content: const Text('This action cannot be undone.'),
                              actions: [
                                TextButton(onPressed: () => ctx.pop(false), child: const Text('CANCEL')),
                                TextButton(onPressed: () => ctx.pop(true), child: const Text('DELETE', style: TextStyle(color: Colors.red))),
                              ],
                            ),
                          );
                          
                          if (confirm == true) {
                             _isDeleted = true; 
                             await ref.read(notesRepositoryProvider).deleteNote(_originalNoteId!);
                             if (mounted) {
                               if (context.canPop()) context.pop();
                               else context.go('/');
                             }
                          }
                        },
                      ),
                      
                    const SizedBox(width: 8),

                    // SAVE BUTTON
                    _EditorActionButton(
                      label: 'SAVE',
                      icon: Icons.check_circle_outline_rounded,
                      isPrimary: true,
                      onPressed: () async {
                        await _saveNote(showToast: true);
                        if (mounted) {
                           if (context.canPop()) context.pop();
                           else context.go('/');
                        }
                      },
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 16),

              // Title Field
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: TextField(
                  controller: _titleController,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: theme.colorScheme.onSurface,
                    letterSpacing: -0.5,
                  ),
                  decoration: InputDecoration(
                    hintText: 'TITLE',
                    hintStyle: theme.textTheme.headlineMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.3),
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
              
              // Divider
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                child: Divider(color: theme.colorScheme.onSurface.withOpacity(0.1), thickness: 1),
              ),

              // Content Field
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: TextField(
                    controller: _contentController,
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      height: 1.6,
                      fontSize: 18,
                      color: theme.colorScheme.onSurface.withOpacity(0.9),
                    ),
                    decoration: InputDecoration(
                      hintText: 'Start writing your thoughts...',
                      hintStyle: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.3),
                        height: 1.6,
                        fontSize: 18,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EditorActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  final bool isPrimary;
  final Color? color;

  const _EditorActionButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onPressed,
    this.isPrimary = false,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final finalColor = color ?? (isPrimary ? theme.colorScheme.onSurface : theme.colorScheme.onSurface.withOpacity(0.6));
    
    return Material(
      color: isPrimary ? theme.colorScheme.onSurface : Colors.transparent,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onPressed();
        },
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: isPrimary ? null : BoxDecoration(
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon, 
                size: 18, 
                color: isPrimary ? theme.colorScheme.surface : finalColor,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                  color: isPrimary ? theme.colorScheme.surface : finalColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
