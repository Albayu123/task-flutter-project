import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/task_model.dart';
import '../../viewmodels/task_viewmodel.dart';

class TaskFormSheet extends StatefulWidget {
  final Task? task;

  const TaskFormSheet({super.key, this.task});

  @override
  State<TaskFormSheet> createState() => _TaskFormSheetState();
}

class _TaskFormSheetState extends State<TaskFormSheet> {
  late final TextEditingController _titleController;
  late final TextEditingController _detailController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task?.title ?? '');
    _detailController = TextEditingController(text: widget.task?.detail ?? '');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _detailController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    final title = _titleController.text.trim();
    final detail = _detailController.text.trim();

    if (title.isEmpty || detail.isEmpty) return;

    final viewModel = context.read<TaskViewModel>();
    if (widget.task == null) {
      await viewModel.addTask(title, detail);
    } else {
      await viewModel.updateTask(widget.task!.id, title, detail);
    }

    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: 20,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(labelText: 'Judul Tugas'),
          ),
          TextField(
            controller: _detailController,
            decoration: const InputDecoration(labelText: 'Detail Tugas'),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _submitForm,
            child: Text(widget.task == null ? 'Simpan' : 'Perbarui'),
          ),
        ],
      ),
    );
  }
}