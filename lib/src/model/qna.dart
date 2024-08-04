import 'dart:convert';

class QnAFields {
  static const String id = 'id';
  static const String title = 'title';
  static const String qContent = 'qContent';
  static const String aContent = 'aContent';
  static const String memo = 'memo';
  static const String createdAt = 'createdAt';
  static const String deletedAt = 'deletedAt';
  static const String isDeleted = 'isDeleted';
}

class QnA {
  static const String tableName = 'qna';
  final int? id;
  final String title;
  final String qContent;
  final String aContent;
  final String? memo;
  final DateTime createdAt;
  final DateTime? deletedAt;
  final bool isDeleted;

  const QnA({
    this.id,
    required this.title,
    required this.qContent,
    required this.aContent,
    this.memo,
    required this.createdAt,
    this.deletedAt,
    required this.isDeleted,
  });

  QnA copyWith({
    int? id,
    String? title,
    String? qContent,
    String? aContent,
    String? memo,
    DateTime? createdAt,
    DateTime? deletedAt,
    bool? isDeleted,
  }) {
    return QnA(
      id: id ?? this.id,
      title: title ?? this.title,
      qContent: qContent ?? this.qContent,
      aContent: aContent ?? this.aContent,
      memo: memo ?? this.memo,
      createdAt: createdAt ?? this.createdAt,
      deletedAt: deletedAt ?? this.deletedAt,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      QnAFields.id: id,
      QnAFields.title: title,
      QnAFields.qContent: qContent,
      QnAFields.aContent: aContent,
      QnAFields.memo: memo,
      QnAFields.createdAt: createdAt.toIso8601String(),
      QnAFields.deletedAt: deletedAt?.toIso8601String(),
      QnAFields.isDeleted: isDeleted ? 1 : 0,
    };
  }

  factory QnA.fromMap(Map<String, dynamic> map) {
    return QnA(
      id: map[QnAFields.id] != null ? map[QnAFields.id] as int : null,
      title: map[QnAFields.title] as String,
      qContent: map[QnAFields.qContent] as String,
      aContent: map[QnAFields.aContent] as String,
      memo: map[QnAFields.memo] != null ? map[QnAFields.memo] as String : null,
      createdAt: DateTime.parse(map[QnAFields.createdAt] as String),
      deletedAt: map[QnAFields.deletedAt] != null
          ? DateTime.parse(map[QnAFields.deletedAt] as String)
          : null,
      isDeleted: map[QnAFields.isDeleted] == 1,
    );
  }

  String toJson() => json.encode(toMap());

  factory QnA.fromJson(String source) =>
      QnA.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'QnA(id: $id, title: $title, qContent: $qContent, aContent: $aContent, memo: $memo, createdAt: $createdAt, deletedAt: $deletedAt, isDeleted: $isDeleted)';
  }

  @override
  bool operator ==(covariant QnA other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.title == title &&
        other.qContent == qContent &&
        other.aContent == aContent &&
        other.memo == memo &&
        other.createdAt == createdAt &&
        other.deletedAt == deletedAt &&
        other.isDeleted == isDeleted;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        title.hashCode ^
        qContent.hashCode ^
        aContent.hashCode ^
        memo.hashCode ^
        createdAt.hashCode ^
        deletedAt.hashCode ^
        isDeleted.hashCode;
  }
}
