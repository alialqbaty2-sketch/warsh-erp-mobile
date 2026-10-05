// lib/screens/tasks_screen.dart
import 'package:flutter/material.dart';
import 'package:warsh_erp_mobile/services/db_service.dart';
import 'task_detail_screen.dart';

class TasksScreen extends StatefulWidget {
  final String userName;
  const TasksScreen({Key? key, required this.userName}) : super(key: key);

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  List<Map<String, dynamic>> _tasks = [];

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    final tasks = await DBService.getTasks();
    setState(() {
      _tasks = tasks;
    });
  }

  Future<void> _addTask() async {
    final now = DateTime.now().toIso8601String();
    final id = await DBService.insertTask({
      'title': 'مهمة جديدة',
      'description': 'وصف المهمة',
      'status': 'جديدة',
      'created_at': now,
      'sync': 0,
    });
    await _loadTasks();
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => TaskDetailScreen(taskId: id))).then((_) => _loadTasks());
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: Text('مهامي - ${widget.userName}')),
        body: RefreshIndicator(
          onRefresh: _loadTasks,
          child: ListView.builder(
            itemCount: _tasks.length,
            itemBuilder: (context, index) {
              final t = _tasks[index];
              return ListTile(
                title: Text(t['title'] ?? ''),
                subtitle: Text('الحالة: ${t['status'] ?? ''}'),
                trailing: t['sync'] == 0 ? const Icon(Icons.cloud_off, color: Colors.red) : const Icon(Icons.cloud_done, color: Colors.green),
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(builder: (_) => TaskDetailScreen(taskId: t['id']))).then((_) => _loadTasks());
                },
              );
            },
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _addTask,
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
