import 'dart:convert';

import 'package:notelens_app/src/model/qna.dart';

class CategoryFields {
  static const String id = 'id';
  static const String title = 'title';
  static const String description = 'description';
  static const String createdAt = 'createdAt';
  static const String deletedAt = 'deletedAt';
  static const String isDeleted = 'isDeleted';
}

class Category {
  static const String tableName = 'category';
  final int? id;
  final String title;
  final String? description;
  final DateTime createdAt;
  final DateTime? deletedAt;
  final bool isDeleted;
  final List<QnA> qnas;

  const Category({
    this.id,
    required this.title,
    this.description,
    required this.createdAt,
    this.deletedAt,
    required this.isDeleted,
    this.qnas = const [],
  });

  Category copyWith({
    int? id,
    String? title,
    String? description,
    DateTime? createdAt,
    DateTime? deletedAt,
    bool? isDeleted,
    List<QnA>? qnas,
  }) {
    return Category(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      deletedAt: deletedAt ?? this.deletedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      qnas: qnas ?? this.qnas,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      CategoryFields.id: id,
      CategoryFields.title: title,
      CategoryFields.description: description,
      CategoryFields.createdAt: createdAt.toIso8601String(),
      CategoryFields.deletedAt: deletedAt?.toIso8601String(),
      CategoryFields.isDeleted: isDeleted ? 1 : 0,
      'qnas': qnas.map((qna) => qna.toMap()).toList(),
    };
  }

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map[CategoryFields.id] != null ? map[CategoryFields.id] as int : null,
      title: map[CategoryFields.title] as String,
      description: map[CategoryFields.description] != null
          ? map[CategoryFields.description] as String
          : null,
      createdAt: DateTime.parse(map[CategoryFields.createdAt] as String),
      deletedAt: map[CategoryFields.deletedAt] != null
          ? DateTime.parse(map[CategoryFields.deletedAt] as String)
          : null,
      isDeleted: map[CategoryFields.isDeleted] == 1,
      qnas: map['qnas'] != null
          ? List<QnA>.from((map['qnas'] as List<dynamic>)
              .map((e) => QnA.fromMap(e as Map<String, dynamic>)))
          : [],
    );
  }

  String toJson() => json.encode(toMap());

  factory Category.fromJson(String source) =>
      Category.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Category(id: $id, title: $title, description: $description, createdAt: $createdAt, deletedAt: $deletedAt, isDeleted: $isDeleted, qnas: $qnas)';
  }

  @override
  bool operator ==(covariant Category other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.title == title &&
        other.description == description &&
        other.createdAt == createdAt &&
        other.deletedAt == deletedAt &&
        other.isDeleted == isDeleted &&
        other.qnas == qnas;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        title.hashCode ^
        description.hashCode ^
        createdAt.hashCode ^
        deletedAt.hashCode ^
        isDeleted.hashCode ^
        qnas.hashCode;
  }
}
