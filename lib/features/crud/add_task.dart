import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:taskhub/data/models/todo.dart';
import 'package:taskhub/data/models/subtask.dart';
import 'package:taskhub/data/models/notification.dart';
import 'package:taskhub/data/db/todo_database.dart';
import 'package:taskhub/config/theme/app_theme.dart'; // Pastikan Anda mengimpor AppColors
import 'package:taskhub/features/jadwal/screens/schedule_page.dart';
import 'package:taskhub/features/notification/notification_service.dart';

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

  // Tambahkan field untuk notifikasi
  List<TextEditingController> _notificationControllers = [];

  Future<void> _createTodo() async {
    // Validasi input
    if (_titleController.text.trim().isEmpty ||
        _categoryController.text.trim().isEmpty ||
        _deadlineController.text.trim().isEmpty ||
        _descriptionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Tugas gagal disimpan. Semua kolom wajib diisi.',
          style: TextStyle(
            color: Colors.white
          ),),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final todo = Todo(
      title: _titleController.text,
      category: _categoryController.text,
      deadline: _deadlineController.text.isNotEmpty
          ? DateFormat('yyyy-MM-dd HH:mm').parse(_deadlineController.text)
          : null,
      description: _descriptionController.text,
      isDone: false,
    );

    final created = await TodoDatabase.instance.createTodo(todo);
    debugPrint('TODO CREATED: id=${created.id}, title=${created.title}, category=${created.category}, deadline=${created.deadline}, description=${created.description}, isDone=${created.isDone}');

    // Simpan subtask
    final List<Subtask> createdSubtasks = [];
    for (final controller in _subtaskControllers) {
      if (controller.text.trim().isEmpty) continue;
      final subtask = Subtask(
        todoId: created.id!,
        title: controller.text,
      );
      final subtaskCreated = await TodoDatabase.instance.createSubtask(subtask);
      createdSubtasks.add(subtaskCreated);
    }
    if (createdSubtasks.isNotEmpty) {
      for (final s in createdSubtasks) {
        debugPrint('SUBTASK CREATED: id=${s.id}, todoId=${s.todoId}, title=${s.title}, isDone=${s.isDone}');
      }
    }

    // Simpan notifikasi
    final notifFutures = <Future<NotificationModel>>[];
    final List<NotificationModel> createdNotifs = [];
    try {
      for (final notifController in _notificationControllers) {
        if (notifController.text.trim().isEmpty) continue;
        DateTime? notifTime;
        try {
          notifTime = DateFormat('yyyy-MM-dd HH:mm').parse(notifController.text);
        } catch (_) {
          notifTime = DateTime.tryParse(notifController.text);
        }
        if (notifTime == null) continue;
        final notif = NotificationModel(
          todoId: created.id!,
          scheduledTime: notifTime,
          isSent: false,
        );
        notifFutures.add(TodoDatabase.instance.createNotification(notif));
      }
      final notifResults = await Future.wait(notifFutures);
      createdNotifs.addAll(notifResults);
    } catch (e) {
      debugPrint('Gagal simpan notifikasi: $e');
    } finally {
      if (createdNotifs.isNotEmpty) {
        for (final n in createdNotifs) {
          debugPrint('NOTIF CREATED: id=${n.id}, todoId=${n.todoId}, scheduledTime=${n.scheduledTime}, isSent=${n.isSent}');
          // Jadwalkan notifikasi lokal langsung setelah berhasil dibuat
          await NotificationService.scheduleNotification(n, todo.title);
        }
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(
            SnackBar(
              content: const Text('Tugas berhasil disimpan',
              style: TextStyle(
                color: Colors.white,
              ),),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 1),
            ),
          );
      // Navigasi setelah snackbar muncul
      Future.delayed(const Duration(milliseconds: 1200), () {
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const SchedulePage()),
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Tambah Tugas")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: AppColors.widget,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    labelText: 'Title',
                    filled: true,
                    fillColor: AppColors.widget,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.widget,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: DropdownButtonFormField<String>(
                  value: _categoryController.text.isNotEmpty ? _categoryController.text : null,
                  items: [
                    'Akademik',
                    'Pekerjaan',
                    'Olahraga',
                    'Hiburan',
                  ].map((cat) => DropdownMenuItem(
                        value: cat,
                        child: Text(cat),
                      )).toList(),
                  onChanged: (val) {
                    setState(() {
                      _categoryController.text = val ?? '';
                    });
                  },
                  decoration: InputDecoration(
                    labelText: 'Category',
                    filled: true,
                    fillColor: AppColors.widget,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  dropdownColor: AppColors.widget,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.widget,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  controller: _deadlineController,
                  decoration: InputDecoration(
                    labelText: 'Deadline',
                    filled: true,
                    fillColor: AppColors.widget,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  readOnly: true,
                  onTap: _selectDeadline,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.widget,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    labelText: 'Description',
                    filled: true,
                    fillColor: AppColors.widget,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  ElevatedButton(
                    onPressed: _addSubtaskField,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                      minimumSize: const Size(44, 44), // persegi
                      padding: EdgeInsets.zero,
                      elevation: 0,
                    ),
                    child: const Icon(Icons.add, color: Colors.white, size: 28),
                  ),
                  const SizedBox(width: 8),
                  const Text('Tambah Subtask', style: TextStyle(fontWeight: FontWeight.bold)),
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
                          decoration: InputDecoration(labelText: 'Nama Subtask'),
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
              // Notifikasi
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  ElevatedButton(
                    onPressed: _addNotificationField,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                      minimumSize: const Size(44, 44), // persegi
                      padding: EdgeInsets.zero,
                      elevation: 0,
                    ),
                    child: const Icon(Icons.add, color: Colors.white, size: 28),
                  ),
                  const SizedBox(width: 8),
                  const Text('Tambah Notifikasi', style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: _notificationControllers.length,
                itemBuilder: (context, index) {
                  return Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _notificationControllers[index],
                          decoration: InputDecoration(labelText: 'Waktu Notifikasi'),
                          readOnly: true,
                          onTap: () => _selectNotificationTime(index),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _removeNotificationField(index),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _createTodo,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Tambah',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _addSubtaskField() {
    setState(() {
      _subtaskControllers.add(TextEditingController());
    });
  }

  void _addNotificationField() {
    setState(() {
      _notificationControllers.add(TextEditingController());
    });
  }

  void _removeSubtaskField(int index) {
    setState(() {
      _subtaskControllers[index].dispose();
      _subtaskControllers.removeAt(index);
    });
  }

  void _removeNotificationField(int index) {
    setState(() {
      _notificationControllers[index].dispose();
      _notificationControllers.removeAt(index);
    });
  }

  Future<void> _selectDeadline() async {
    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.white, // highlight/selected
              onPrimary: AppColors.widget, // text on selected
              surface: AppColors.widget, // background
              onSurface: Colors.white, // text/number
              background: AppColors.widget,
              onBackground: Colors.white,
              secondary: Colors.white,
              onSecondary: AppColors.widget,
              error: Colors.red,
              onError: Colors.white,
              brightness: Brightness.light,
            ),
            dialogBackgroundColor: AppColors.widget,
            textTheme: Theme.of(context).textTheme.apply(bodyColor: Colors.white, displayColor: Colors.white),
            iconTheme: IconThemeData(color: Colors.white),
            primaryColor: Colors.white,
            hintColor: Colors.white,
            inputDecorationTheme: InputDecorationTheme(
              hintStyle: TextStyle(color: Colors.white),
              labelStyle: TextStyle(color: Colors.white),
            ),
          ),
          child: child!,
        );
      },
    );

    if (date == null) return;

    final TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.white,
              onPrimary: AppColors.widget,
              surface: AppColors.widget,
              onSurface: Colors.white,
              background: AppColors.widget,
              onBackground: Colors.white,
              secondary: Colors.white,
              onSecondary: AppColors.widget,
              error: Colors.red,
              onError: Colors.white,
              brightness: Brightness.light,
            ),
            dialogBackgroundColor: AppColors.widget,
            textTheme: Theme.of(context).textTheme.apply(bodyColor: Colors.white, displayColor: Colors.white),
            iconTheme: IconThemeData(color: Colors.white),
            primaryColor: Colors.white,
            hintColor: Colors.white,
            inputDecorationTheme: InputDecorationTheme(
              hintStyle: TextStyle(color: Colors.white),
              labelStyle: TextStyle(color: Colors.white),
            ),
          ),
          child: child!,
        );
      },
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

  Future<void> _selectNotificationTime(int index) async {
    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.white,
              onPrimary: AppColors.widget,
              surface: AppColors.widget,
              onSurface: Colors.white,
              background: AppColors.widget,
              onBackground: Colors.white,
              secondary: Colors.white,
              onSecondary: AppColors.widget,
              error: Colors.red,
              onError: Colors.white,
              brightness: Brightness.light,
            ),
            dialogBackgroundColor: AppColors.widget,
            textTheme: Theme.of(context).textTheme.apply(bodyColor: Colors.white, displayColor: Colors.white),
            iconTheme: IconThemeData(color: Colors.white),
            primaryColor: Colors.white,
            hintColor: Colors.white,
            inputDecorationTheme: InputDecorationTheme(
              hintStyle: TextStyle(color: Colors.white),
              labelStyle: TextStyle(color: Colors.white),
            ),
          ),
          child: child!,
        );
      },
    );
    if (date == null) return;
    final TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.white,
              onPrimary: AppColors.widget,
              surface: AppColors.widget,
              onSurface: Colors.white,
              background: AppColors.widget,
              onBackground: Colors.white,
              secondary: Colors.white,
              onSecondary: AppColors.widget,
              error: Colors.red,
              onError: Colors.white,
              brightness: Brightness.light,
            ),
            dialogBackgroundColor: AppColors.widget,
            textTheme: Theme.of(context).textTheme.apply(bodyColor: Colors.white, displayColor: Colors.white),
            iconTheme: IconThemeData(color: Colors.white),
            primaryColor: Colors.white,
            hintColor: Colors.white,
            inputDecorationTheme: InputDecorationTheme(
              hintStyle: TextStyle(color: Colors.white),
              labelStyle: TextStyle(color: Colors.white),
            ),
          ),
          child: child!,
        );
      },
    );
    if (time == null) return;
    final DateTime notifTime = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );
    setState(() {
      _notificationControllers[index].text = DateFormat('yyyy-MM-dd HH:mm').format(notifTime);
    });
  }

}
