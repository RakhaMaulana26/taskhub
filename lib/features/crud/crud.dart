import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:taskhub/data/models/todo.dart';
import 'package:taskhub/data/models/subtask.dart';
import 'package:taskhub/data/models/notification.dart';
import 'package:taskhub/data/db/todo_database.dart';


class TodoFormPage extends StatefulWidget {
  const TodoFormPage({Key? key}) : super(key: key);

  @override
  State<TodoFormPage> createState() => _TodoFormPageState();
}

class _TodoFormPageState extends State<TodoFormPage> {
  final formatter = DateFormat('yyyy-MM-dd');
  final _titleController = TextEditingController();
  final _categoryController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _deadlineController = TextEditingController();
  List<TextEditingController> _subtaskControllers = [];

  int? _currentId;

  String _statusMessage = '';

  Future<void> _createTodo() async {
    final todo = Todo(
      title: _titleController.text,
      category: _categoryController.text,
      deadline: _deadlineController.text.isNotEmpty
          ? DateFormat('yyyy-MM-dd HH:mm').parse(_deadlineController.text)
          : null,
      notification: null,
      description: _descriptionController.text,
      isDone: false,
    );

    final created = await TodoDatabase.instance.createTodo(todo);

    // Simpan subtask
    for (final controller in _subtaskControllers) {
      if (controller.text.trim().isEmpty) continue;
      final subtask = Subtask(
        todoId: created.id!,
        title: controller.text,
      );
      await TodoDatabase.instance.createSubtask(subtask);
    }

    setState(() {
      _currentId = created.id;
      _statusMessage = "Todo berhasil dibuat (id: ${created.id})";
    });
  }

  Future<void> _readTodo() async {
    if (_currentId == null) return;
    final todo = await TodoDatabase.instance.readTodo(_currentId!);
    if (todo != null) {
      setState(() {
        _titleController.text = todo.title;
        _categoryController.text = todo.category;
        _deadlineController.text = todo.deadline != null ? formatter.format(todo.deadline!) : '';
        _descriptionController.text = todo.description ?? '';
        _statusMessage = "Todo berhasil dibaca (id: ${todo.id})";
      });
    } else {
      setState(() {
        _statusMessage = "Todo tidak ditemukan.";
      });
    }
  }

  Future<void> _updateTodo() async {
    if (_currentId == null) return;

    final updatedTodo = Todo(
      id: _currentId,
      title: _titleController.text,
      category: _categoryController.text,
      deadline: _deadlineController.text.isNotEmpty
          ? DateFormat('yyyy-MM-dd HH:mm').parse(_deadlineController.text)
          : null,
      notification: null, // ganti dengan waktu jika ada fitur notifikasi
      description: _descriptionController.text,
      isDone: false, // atau ubah sesuai input
    );

    final rowsAffected = await TodoDatabase.instance.updateTodo(updatedTodo);
    setState(() {
      _statusMessage = "Todo berhasil diupdate ($rowsAffected row(s))";
    });
  }

  Future<void> _deleteTodo() async {
    if (_currentId == null) return;

    final rowsDeleted = await TodoDatabase.instance.deleteTodo(_currentId!);
    setState(() {
      _currentId = null;
      _titleController.clear();
      _categoryController.clear();
      _deadlineController.clear();
      _descriptionController.clear();
      _statusMessage = "Todo berhasil dihapus ($rowsDeleted row(s))";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("CRUD Todo Test")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: _titleController, decoration: InputDecoration(labelText: 'Title')),
            TextField(controller: _categoryController, decoration: InputDecoration(labelText: 'Category')),
            TextField(
              controller: _deadlineController,
              decoration: InputDecoration(labelText: 'Deadline'),
              readOnly: true,
              onTap: _selectDeadline,
            ),

            TextField(controller: _descriptionController, decoration: InputDecoration(labelText: 'Description')),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Subtasks', style: TextStyle(fontWeight: FontWeight.bold)),
                ElevatedButton.icon(
                  onPressed: _addSubtaskField,
                  icon: Icon(Icons.add),
                  label: Text('Tambah Subtask'),
                ),
              ],
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: _subtaskControllers.length,
              itemBuilder: (context, index) {
                return Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _subtaskControllers[index],
                        decoration: InputDecoration(labelText: 'Subtask ${index + 1}'),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _removeSubtaskField(index),
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              children: [
                ElevatedButton(onPressed: _createTodo, child: Text('Create')),
                ElevatedButton(onPressed: _readTodo, child: Text('Read')),
                ElevatedButton(onPressed: _updateTodo, child: Text('Update')),
                ElevatedButton(onPressed: _deleteTodo, child: Text('Delete')),
              ],
            ),
            const SizedBox(height: 16),
            Text(_statusMessage, style: TextStyle(color: Colors.blue)),
          ],
        ),
      ),
    );
  }

  void _addSubtaskField() {
    setState(() {
      _subtaskControllers.add(TextEditingController());
    });
  }

  void _removeSubtaskField(int index) {
    setState(() {
      _subtaskControllers[index].dispose();
      _subtaskControllers.removeAt(index);
    });
  }

  Future<void> _selectDeadline() async {
    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (date == null) return;

    final TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (time == null) return;

    final DateTime deadline = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );

    setState(() {
      _deadlineController.text = DateFormat('yyyy-MM-dd HH:mm').format(deadline);
    });
  }

}
