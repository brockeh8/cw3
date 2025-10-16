import 'package:flutter/material.dart';

void main() => runApp(const MaterialApp(home: TaskApp()));

class Task {
  String name;
  bool done;
  Task(this.name, {this.done = false});
}

class TaskApp extends StatefulWidget {
  const TaskApp({super.key});
  @override
  State<TaskApp> createState() => _TaskAppState();
}

class _TaskAppState extends State<TaskApp> {
  final _c = TextEditingController();
  final _tasks = <Task>[];

  void _add() {
    final t = _c.text.trim();
    if (t.isEmpty) return;
    setState(() {
      _tasks.add(Task(t));
      _c.clear();
    });
  }

  void _toggle(int i, bool? v) => setState(() => _tasks[i].done = v ?? false);

  void _delete(int i) => setState(() => _tasks.removeAt(i));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Task Manager — Part 2')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(children: [
              Expanded(
                child: TextField(
                  controller: _c,
                  onSubmitted: (_) => _add(),
                  decoration: const InputDecoration(
                    labelText: 'New task',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              FilledButton(onPressed: _add, child: const Text('Add')),
            ]),
          ),
          const Divider(height: 0),
          Expanded(
            child: ListView.builder(
              itemCount: _tasks.length,
              itemBuilder: (_, i) {
                final t = _tasks[i];
                return ListTile(
                  leading: Checkbox(value: t.done, onChanged: (v) => _toggle(i, v)),
                  title: Text(
                    t.name,
                    style: TextStyle(decoration: t.done ? TextDecoration.lineThrough : null),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () => _delete(i),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
