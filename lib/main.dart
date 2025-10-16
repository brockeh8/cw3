import 'package:flutter/material.dart';
void main() => runApp(const MaterialApp(home: TaskList()));

class Task { String name; bool done; Task(this.name,{this.done=false}); }

class TaskList extends StatefulWidget { const TaskList({super.key}); @override State<TaskList> createState()=>_TaskListState(); }
class _TaskListState extends State<TaskList>{
  final _c=TextEditingController(); final _tasks=<Task>[];
  void _add(){final t=_c.text.trim(); if(t.isEmpty) return; setState(()=>_tasks.add(Task(t))); _c.clear();}
  @override Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(title: const Text('Tasks (Part 1)')),
      body: Column(children:[
        Padding(padding: const EdgeInsets.all(12),child: Row(children:[
          Expanded(child: TextField(controller:_c,decoration: const InputDecoration(labelText:'New task',border: OutlineInputBorder()),onSubmitted:(_)=>_add())),
          const SizedBox(width:8), FilledButton(onPressed:_add, child: const Text('Add')),
        ])),
        const Divider(height:0),
        Expanded(child: ListView.builder(itemCount:_tasks.length,itemBuilder:(_,i)=>ListTile(title: Text(_tasks[i].name)))),
      ]),
    );
  }
}
