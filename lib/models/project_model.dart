// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:equatable/equatable.dart';

class ProjectModel extends Equatable {
  final String title;
  final String id;
  const ProjectModel({
    required this.title,
    required this.id,
  });

  ProjectModel copyWith({
    String? title,
    String? id,
  }) {
    return ProjectModel(
      title: title ?? this.title,
      id: id ?? this.id,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'title': title,
      'id': id,
    };
  }

  factory ProjectModel.fromMap(Map<String, dynamic> map) {
    return ProjectModel(
      title: map['title'] as String,
      id: map['id'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory ProjectModel.fromJson(String source) =>
      ProjectModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  bool get stringify => true;

  @override
  List<Object> get props => [title, id];
}
