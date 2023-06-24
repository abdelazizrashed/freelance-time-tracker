// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:equatable/equatable.dart';

class EntryModel extends Equatable {
  final String id;
  final String projectId;
  final String date;
  final String time;
  final String description;
  final DateTime dateTime;

  List<String> toRow() => [date, time, description];

  const EntryModel({
    required this.id,
    required this.projectId,
    required this.date,
    required this.time,
    required this.description,
    required this.dateTime,
  });

  EntryModel copyWith({
    String? id,
    String? projectId,
    String? date,
    String? time,
    String? description,
    DateTime? dateTime,
  }) {
    return EntryModel(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      date: date ?? this.date,
      time: time ?? this.time,
      description: description ?? this.description,
      dateTime: dateTime ?? this.dateTime,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'projectId': projectId,
      'date': date,
      'time': time,
      'description': description,
      'dateTime': dateTime.millisecondsSinceEpoch,
    };
  }

  factory EntryModel.fromMap(Map<String, dynamic> map) {
    return EntryModel(
      id: map['id'] as String,
      projectId: map['projectId'] as String,
      date: map['date'] as String,
      time: map['time'] as String,
      description: map['description'] as String,
      dateTime: DateTime.fromMillisecondsSinceEpoch(map['dateTime'] as int),
    );
  }

  String toJson() => json.encode(toMap());

  factory EntryModel.fromJson(String source) =>
      EntryModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  bool get stringify => true;

  @override
  List<Object> get props {
    return [
      id,
      projectId,
      date,
      time,
      description,
      dateTime,
    ];
  }
}
