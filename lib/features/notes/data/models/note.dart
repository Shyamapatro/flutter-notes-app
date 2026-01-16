class Note {
  final String id;
  final String? userId; // Nullable for anonymous users
  final String title;
  final String content;
  final bool isPinned;
  final bool isArchived;
  final DateTime createdAt;
  final DateTime updatedAt;

  Note({
    required this.id,
    this.userId,
    required this.title,
    required this.content,
    required this.isPinned,
    required this.isArchived,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      id: json['id'] as String,
      userId: json['user_id'] as String?, // Nullable
      title: json['title'] as String? ?? '',
      content: json['content'] as String? ?? '',
      isPinned: json['is_pinned'] as bool? ?? false,
      isArchived: json['is_archived'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    final map = {
      'id': id,
      'title': title,
      'content': content,
      'is_pinned': isPinned,
      'is_archived': isArchived,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
    
    // Only add user_id if present (and ideally valid UUID, but let's just strip if null)
    if (userId != null && userId!.isNotEmpty) {
      map['user_id'] = userId!;
    }
    
    return map;
  }

  Note copyWith({
    String? title,
    String? content,
    bool? isPinned,
    bool? isArchived,
    DateTime? updatedAt,
  }) {
    return Note(
      id: id,
      userId: userId,
      title: title ?? this.title,
      content: content ?? this.content,
      isPinned: isPinned ?? this.isPinned,
      isArchived: isArchived ?? this.isArchived,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
