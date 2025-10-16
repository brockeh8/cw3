import 'package:flutter/material.dart';

void main() => runApp(const MaterialApp(home: TaskApp()));

class Task {
  String name;
  bool done;
  int pr; // 0=Low, 1=Med, 2=High
  Task(this.name, {this.done = false, this.pr = 1});
}

class TaskApp extends StatefulWidget {
  const TaskApp({super.key});
  @override
  State<TaskApp> createState() => _TaskAppState();
}

class _TaskAppState extends State<TaskApp> {
  final _c = TextEditingController();
  final _labels = const ['Low', 'Med', 'High'];
  final _tasks = <Task>[];
  int _selPr = 1;
  bool _highFirst = true;

  void _add() {
    final t = _c.text.trim();
    if (t.isEmpty) return;
    setState(() {
      _tasks.add(Task(t, pr: _selPr));
      _c.clear();
    });
  }

  void _toggle(int i, bool? v) => setState(() => _tasks[i].done = v ?? false);

  void _delete(int i) => setState(() => _tasks.removeAt(i));

  void _sort() {
    setState(() {
      _tasks.sort((a, b) {
        final cmp = b.pr.compareTo(a.pr); // high --> low
        return _highFirst ? cmp : -cmp;
      });
      _highFirst = !_highFirst;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Manager'),
        actions: [IconButton(onPressed: _sort, icon: const Icon(Icons.sort))],
      ),
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
              DropdownButton<int>(
                value: _selPr,
                items: List.generate(3, (i) => DropdownMenuItem(value: i, child: Text(_labels[i]))),
                onChanged: (v) => setState(() => _selPr = v ?? 1),
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
                    '${t.name}  [${_labels[t.pr]}]',
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
