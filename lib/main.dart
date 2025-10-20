import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(const MyApp());

class Task {
  String name;
  bool done;
  int pr; 
  Task(this.name, {this.done = false, this.pr = 1});

  Map<String, dynamic> toMap() => {'name': name, 'done': done, 'pr': pr};
  factory Task.fromMap(Map<String, dynamic> m) =>
      Task(m['name'] as String, done: m['done'] as bool? ?? false, pr: (m['pr'] as int?)?.clamp(0, 2) ?? 1);
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  final _labels = const ['Low', 'Med', 'High'];
  final _tasks = <Task>[];
  final _c = TextEditingController();

  int _selPr = 1;
  bool _highFirst = true;
  bool _dark = false;

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<void> _loadAll() async {
    final p = await SharedPreferences.getInstance();
    _dark = p.getBool('dark') ?? false;

    final s = p.getString('tasks');
    if (s != null) {
      final list = (jsonDecode(s) as List).cast<Map<String, dynamic>>();
      _tasks
        ..clear()
        ..addAll(list.map(Task.fromMap));
    }
    setState(() {}); 
  }

  Future<void> _saveTasks() async {
    final p = await SharedPreferences.getInstance();
    await p.setString('tasks', jsonEncode(_tasks.map((t) => t.toMap()).toList()));
  }

  Future<void> _saveTheme() async {
    final p = await SharedPreferences.getInstance();
    await p.setBool('dark', _dark);
  }

  void _add() {
    final t = _c.text.trim();
    if (t.isEmpty) return;
    setState(() {
      _tasks.add(Task(t, pr: _selPr));
      _c.clear();
    });
    _saveTasks();
  }

  void _toggleDone(int i, bool? v) {
    setState(() => _tasks[i].done = v ?? false);
    _saveTasks();
  }

  void _delete(int i) {
    setState(() => _tasks.removeAt(i));
    _saveTasks();
  }

  void _sort() {
    setState(() {
      _tasks.sort((a, b) {
        final cmp = b.pr.compareTo(a.pr);
        return _highFirst ? cmp : -cmp;
      });
      _highFirst = !_highFirst;
    });
    _saveTasks();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      themeMode: _dark ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.blue),
      darkTheme: ThemeData(brightness: Brightness.dark, useMaterial3: true, colorSchemeSeed: Colors.blue),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Task Manager — Part 5'),
          actions: [
            IconButton(onPressed: _sort, icon: const Icon(Icons.sort)),
            Row(children: [
              const Text('Dark'),
              Switch(
                value: _dark,
                onChanged: (v) {
                  setState(() => _dark = v);
                  _saveTheme();
                },
              ),
              const SizedBox(width: 8),
            ]),
          ],
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
              child: _tasks.isEmpty
                  ? const Center(child: Text('No tasks yet'))
                  : ListView.builder(
                      itemCount: _tasks.length,
                      itemBuilder: (_, i) {
                        final t = _tasks[i];
                        return ListTile(
                          leading: Checkbox(value: t.done, onChanged: (v) => _toggleDone(i, v)),
                          title: Text(
                            '${t.name}  [${_labels[t.pr]}]',
                            style: TextStyle(decoration: t.done ? TextDecoration.lineThrough : null),
                          ),
                          trailing: IconButton(icon: const Icon(Icons.delete_outline), onPressed: () => _delete(i)),
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
