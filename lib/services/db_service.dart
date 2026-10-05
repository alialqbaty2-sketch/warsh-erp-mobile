// lib/services/db_service.dart
import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DBService {
  static Database? _db;

  static Future<void> init() async {
    if (_db != null) return;
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, "warsh_erp.db");
    _db = await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  static Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE tasks (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT,
        description TEXT,
        status TEXT,
        notes TEXT,
        created_at TEXT,
        sync INTEGER DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE attachments (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        task_id INTEGER,
        path TEXT,
        created_at TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE sync_queue (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        entity TEXT,
        entity_id INTEGER,
        operation TEXT,
        payload TEXT,
        created_at TEXT,
        status TEXT
      )
    ''');
  }

  // Tasks
  static Future<int> insertTask(Map<String, dynamic> data) async {
    return await _db!.insert('tasks', data);
  }

  static Future<List<Map<String, dynamic>>> getTasks() async {
    return await _db!.query('tasks', orderBy: 'id DESC');
  }

  static Future<Map<String, dynamic>?> getTaskById(int id) async {
    final res = await _db!.query('tasks', where: 'id = ?', whereArgs: [id]);
    if (res.isNotEmpty) return res.first;
    return null;
  }

  static Future<int> updateTask(int id, Map<String, dynamic> data) async {
    return await _db!.update('tasks', data, where: 'id = ?', whereArgs: [id]);
  }

  static Future<void> markTaskForSync(int id) async {
    await _db!.update('tasks', {'sync': 0}, where: 'id = ?', whereArgs: [id]);
    // add to queue (simple)
    await _db!.insert('sync_queue', {
      'entity': 'task',
      'entity_id': id,
      'operation': 'update',
      'payload': '{}',
      'created_at': DateTime.now().toIso8601String(),
      'status': 'pending'
    });
  }

  // Attachments
  static Future<int> insertAttachment(int taskId, String path) async {
    return await _db!.insert('attachments', {
      'task_id': taskId,
      'path': path,
      'created_at': DateTime.now().toIso8601String()
    });
  }

  static Future<List<Map<String, dynamic>>> getAttachments(int taskId) async {
    return await _db!.query('attachments', where: 'task_id = ?', whereArgs: [taskId], orderBy: 'id DESC');
  }

  // Sync queue
  static Future<List<Map<String, dynamic>>> getPendingSync() async {
    return await _db!.query('sync_queue', where: "status = 'pending'", orderBy: 'id ASC');
  }

  static Future<void> markSynced(int queueId) async {
    await _db!.update('sync_queue', {'status': 'synced'}, where: 'id = ?', whereArgs: [queueId]);
    // for simplicity, mark tasks sync = 1
  }
}
