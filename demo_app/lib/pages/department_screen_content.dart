import 'package:demo_app/models/department_data.dart';
import 'package:flutter/material.dart';

class DepartmentScreenContent extends StatelessWidget {
  final String departmentName;

  const DepartmentScreenContent({super.key, required this.departmentName});

  @override
  Widget build(BuildContext context) {
    final courses = DepartmentContents.courses[departmentName] ?? [];
    final docs = DepartmentContents.documents[departmentName] ?? [];

    return Scaffold(
      appBar: AppBar(
        title: Text(departmentName),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Courses',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: courses.length,
                itemBuilder: (context, index) {
                  return Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 2,
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    child: ListTile(
                      leading: const Icon(Icons.book),
                      title: Text(courses[index]),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Documents',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: docs.length,
                itemBuilder: (context, index) {
                  return Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 2,
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    child: ListTile(
                      leading: const Icon(Icons.picture_as_pdf),
                      title: Text(docs[index]),
                      onTap: () {
                        // TODO: open document viewer
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
