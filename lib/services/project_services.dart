import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:csv/csv.dart';
// import 'package:FirebaseFirestore/FirebaseFirestore.dart';
import 'package:path_provider/path_provider.dart';
import 'package:time_tracker/models/entry_model.dart';
import 'package:time_tracker/models/project_model.dart';

extension ProjectServices on ProjectModel {
  Future<void> create() async {
    final ref = FirebaseFirestore.instance.collection("projects").doc();
    final model = copyWith(id: ref.id);
    await ref.set(model.toMap());
  }

  Future<void> update() async {
    final ref = FirebaseFirestore.instance.collection("projects").doc(id);
    await ref.set(toMap());
  }

  Future<void> delete() async {
    final ref = FirebaseFirestore.instance.collection("projects").doc(id);
    await ref.delete();
  }

  static Future<List<ProjectModel>> getProjects() async {
    final projects =
        await FirebaseFirestore.instance.collection("projects").get();

    return projects.docs.map((e) {
      return ProjectModel.fromMap(e.data());
    }).toList();
  }

  static Future<ProjectModel?> getProjectById(String id) async {
    final ref = FirebaseFirestore.instance.collection("projects").doc(id);
    final project = await ref.get();
    if (!project.exists) return null;
    return ProjectModel.fromMap(project.data()!);
  }

  Future<void> addEntry(EntryModel entry) async {
    final ref = FirebaseFirestore.instance
        .collection("projects")
        .doc(id)
        .collection("entries")
        .doc();
    final model = entry.copyWith(id: ref.id);
    await ref.set(model.toMap());
  }

  Future<List<EntryModel>> getEntries() async {
    final docs = await FirebaseFirestore.instance
        .collection("projects")
        .doc(id)
        .collection("entries")
        .get();
    final entries = docs.docs.map((e) => EntryModel.fromMap(e.data())).toList();
    entries.sort((a, b) => a.dateTime.compareTo(b.dateTime));
    return entries;
  }

  Future<void> toCSV([String? fileName]) async {
    final entries = await getEntries();
    entries.sort((a, b) => a.dateTime.compareTo(b.dateTime));
    var rows = [
      ["date", "time", "description"]
    ];
    rows.addAll(entries.map((e) => e.toRow()).toList());
    String csv = const ListToCsvConverter().convert(rows);
    saveCSV(csv, entries.length.toString(), fileName);
  }

  Future<void> saveCSV(String csv, [String? nameExt, String? fileName]) async {
    final dir = await getDownloadsDirectory();
    final temp = dir?.path.split('/');
    final path = temp?.sublist(0, temp.indexOf("Users") + 2).join('/');
    final date = DateTime.now().toString().split(" ").first;
    var name = "$title-$date";
    if (fileName != null) {
      name = fileName;
    } else if (nameExt != null) {
      name += "-$nameExt";
    }
    name += ".csv";
    final file = File("$path/Downloads/$name");
    if (!file.existsSync()) {
      await file.create(recursive: true);
    }
    await file.writeAsString(csv);
  }
}

extension EntryServices on EntryModel {
  Future<void> update() async {
    final ref = FirebaseFirestore.instance
        .collection("projects")
        .doc(projectId)
        .collection("entries")
        .doc(id);
    await ref.set(toMap());
  }

  Future<void> delete() async {
    final ref = FirebaseFirestore.instance
        .collection("projects")
        .doc(projectId)
        .collection("entries")
        .doc(id);
    await ref.delete();
  }
}
