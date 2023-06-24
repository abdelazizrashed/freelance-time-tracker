import 'package:flutter/material.dart';
import 'package:time_tracker/models/entry_model.dart';
import 'package:time_tracker/models/project_model.dart';
import 'package:time_tracker/services/project_services.dart';

class SpreedSheetScreen extends StatefulWidget {
  static void navigate(BuildContext context, ProjectModel project) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => SpreedSheetScreen(
          project: project,
        ),
      ),
    );
  }

  const SpreedSheetScreen({
    super.key,
    required this.project,
  });
  final ProjectModel project;

  @override
  State<SpreedSheetScreen> createState() => _SpreedSheetScreenState();
}

class _SpreedSheetScreenState extends State<SpreedSheetScreen> {
  List<EntryModel> entries = [];
  List<DateTime?> dates = [];
  DateTime? selectedDate;

  final controller = TextEditingController();
  final focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    startRoutine(() => getData());
  }

  getData() async {
    entries = await widget.project.getEntries();
    dates = [null];
    dates.addAll(entries.map((e) => e.dateTime).toSet().toList());
  }

  bool isLoading = false;

  startRoutine(Future Function() routine) async {
    setState(() {
      isLoading = true;
    });
    await routine();
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          IconButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            icon: const Icon(Icons.arrow_back_ios),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            widget.project.title,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          IconButton(
                            onPressed: () {
                              startRoutine(() async {
                                getData();
                              });
                            },
                            icon: const Icon(Icons.refresh),
                          ),
                          IconButton(
                            onPressed: () {
                              startRoutine(() async {
                                await widget.project.toCSV().then((value) =>
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text("Saved to Downloads"),
                                      ),
                                    ));
                              });
                            },
                            icon: const Icon(Icons.save),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  if (dates.isNotEmpty)
                    DropdownButton<DateTime?>(
                      value: selectedDate,
                      items: dates
                          .map(
                            (e) => DropdownMenuItem<DateTime?>(
                              value: e,
                              child: Text(e == null
                                  ? "All"
                                  : e.toString().split(" ").first),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedDate = value;
                        });
                      },
                    ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: Builder(builder: (context) {
                      final items = selectedDate == null
                          ? entries
                          : entries
                              .where(
                                  (element) => element.dateTime == selectedDate)
                              .toList();
                      return ListView.builder(
                        itemCount: items.length,
                        itemBuilder: (context, index) {
                          final data = items[index];
                          return ListTile(
                            title: Text(data.description),
                            subtitle: Text(data.dateTime.toString()),
                            onLongPress: () {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text("Delete Entry"),
                                  content: const Text("Are you sure?"),
                                  actions: [
                                    TextButton(
                                      onPressed: () async {
                                        startRoutine(() async {
                                          await data.delete();
                                          getData();
                                        });
                                        Navigator.of(context).pop();
                                      },
                                      child: const Text("Yes"),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: const Text("No"),
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                      );
                    }),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          autofocus: true,
                          focusNode: focusNode,
                          controller: controller,
                          onSubmitted: (value) => _onSubmit(),
                          decoration: const InputDecoration(
                            hintText: "Description",
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: _onSubmit,
                        icon: const Icon(Icons.send),
                      ),
                    ],
                  )
                ],
              ),
            ),
    );
  }

  Future<void> _onSubmit() async {
    startRoutine(() async {
      if (controller.text.isEmpty) return;
      final now = DateTime.now();
      final String date = "${now.day}/${now.month}/${now.year}";
      final String time = "${now.hour}:${now.minute}";
      final entry = EntryModel(
        id: "",
        description: controller.text,
        date: date,
        time: time,
        projectId: widget.project.id,
        dateTime: now,
      );
      await widget.project.addEntry(entry);
      controller.clear();
      getData();
    });
  }
}
