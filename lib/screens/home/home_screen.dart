import 'package:flutter/material.dart';
import 'package:time_tracker/models/project_model.dart';
import 'package:time_tracker/screens/home/widgets/new_project_dialog.dart';
import 'package:time_tracker/screens/spreed_sheet/spreed_sheet_screen.dart';
import 'package:time_tracker/services/project_services.dart';

class HomeScreen extends StatefulWidget {
  static void navigate(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (context) => const HomeScreen(),
      ),
      (route) => false,
    );
  }

  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final dialogController = TextEditingController();

  List<ProjectModel> projects = [];
  bool isLoading = true;

  getProjects() async {
    projects = await ProjectServices.getProjects();
    // projects = (await ProjectServices.getProjects())
    //     .where((element) => element != null)
    //     .map((e) => e as ProjectModel)
    //     .toList();
  }

  @override
  void initState() {
    super.initState();
    startRoutine(() => getProjects());
  }

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
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: () async {
              startRoutine(() => getProjects());
            },
            child: const Icon(Icons.refresh),
          ),
          const SizedBox(width: 10),
          FloatingActionButton(
            onPressed: () async {
              showDialog(
                context: context,
                builder: (context) => NewProjectDialog(
                  onAdd: (title) async {
                    startRoutine(() async {
                      final project = ProjectModel(id: "", title: title);
                      await project.create();
                      getProjects();
                    });
                    Navigator.of(context).pop();
                  },
                ),
              );
            },
            child: const Icon(Icons.add),
          ),
        ],
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : projects.isEmpty
              ? const Center(child: Text("No Projects"))
              : ListView.builder(
                  itemCount: projects.length,
                  itemBuilder: (context, index) => ListTile(
                    title: Text(projects[index].title),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    subtitle: Text(
                      "${projects[index].title} Entries",
                    ),
                    onLongPress: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text("Delete Project"),
                          content: const Text("Are you sure?"),
                          actions: [
                            TextButton(
                              onPressed: () {
                                startRoutine(() async {
                                  await projects[index].delete();
                                  getProjects();
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
                    onTap: () {
                      SpreedSheetScreen.navigate(context, projects[index]);
                    },
                  ),
                ),
    );
  }
}
