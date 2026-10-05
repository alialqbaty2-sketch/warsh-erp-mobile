// lib/screens/task_detail_screen.dart
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:warsh_erp_mobile/services/db_service.dart';

class TaskDetailScreen extends StatefulWidget {
  final int taskId;
  const TaskDetailScreen({Key? key, required this.taskId}) : super(key: key);

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  Map<String, dynamic>? _task;
  List<Map<String, dynamic>> _attachments = [];
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _noteCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final t = await DBService.getTaskById(widget.taskId);
    final at = await DBService.getAttachments(widget.taskId);
    setState(() {
      _task = t;
      _attachments = at;
    });
  }

  Future<void> _takePhoto() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.camera, imageQuality: 70);
    if (image == null) return;
    await DBService.insertAttachment(widget.taskId, image.path);
    await DBService.markTaskForSync(widget.taskId);
    await _load();
  }

  Future<void> _saveNote() async {
    await DBService.updateTask(widget.taskId, {'notes': _noteCtrl.text, 'sync': 0});
    await DBService.markTaskForSync(widget.taskId);
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    if (_task == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: Text('تفاصيل المهمة #${_task!['id']}')),
        body: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('العنوان: ${_task!['title']}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text('الوصف: ${_task!['description']}'),
              const SizedBox(height: 12),
              const Text('الملاحظات:'),
              TextField(controller: _noteCtrl, maxLines: 3, decoration: const InputDecoration(border: OutlineInputBorder())),
              const SizedBox(height: 8),
              ElevatedButton(onPressed: _saveNote, child: const Text('حفظ الملاحظة')),
              const SizedBox(height: 12),
              const Text('المستندات المرفقة:'),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.builder(
                  itemCount: _attachments.length,
                  itemBuilder: (context, index) {
                    final a = _attachments[index];
                    return ListTile(
                      leading: const Icon(Icons.image),
                      title: Text(a['path'].split('/').last),
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(builder: (_) => ImagePreview(path: a['path'])));
                      },
                    );
                  },
                ),
              ),
              ElevatedButton.icon(onPressed: _takePhoto, icon: const Icon(Icons.camera_alt), label: const Text('التقاط صورة')),
            ],
          ),
        ),
      ),
    );
  }
}

class ImagePreview extends StatelessWidget {
  final String path;
  const ImagePreview({Key? key, required this.path}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('معاينة الصورة')),
        body: Center(child: Image.file(File(path))),
      ),
    );
  }
}
