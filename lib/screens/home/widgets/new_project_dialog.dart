import 'package:flutter/material.dart';

class NewProjectDialog extends StatelessWidget {
  NewProjectDialog({
    super.key,
    required this.onAdd,
  });

  final Function(String title) onAdd;

  final nameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        height: 200,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          children: [
            const Text('Add New Sheet'),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                hintText: "Title",
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    if (nameController.text.isNotEmpty) {
                      onAdd(nameController.text);
                    }
                  },
                  child: const Text('Add'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Close'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
