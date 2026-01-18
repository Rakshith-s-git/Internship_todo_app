import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/todo_model.dart';
import '../services/todo_service.dart';
import '../services/notification_service.dart';

class TodoPage extends StatefulWidget {
  final String userId;
  const TodoPage({super.key, required this.userId});

  @override
  State<TodoPage> createState() => _TodoPageState();
}

class _TodoPageState extends State<TodoPage>
    with SingleTickerProviderStateMixin {
  final TodoService _todoService = TodoService();

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _searchController = TextEditingController();

  DateTime? _selectedDueDate;
  String _selectedPriority = 'medium';
  String _filterPriority = 'all';

  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _searchController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  // ================= ADD TODO =================
  void _addTodo() async {
    if (_titleController.text.trim().isEmpty) return;

    final title = _titleController.text.trim();
    final priority = _selectedPriority;

    await _todoService.addTodo(
      userId: widget.userId,
      title: title,
      description: _descriptionController.text.trim(),
      dueDate: _selectedDueDate,
      priority: priority,
    );

    // 🔔 PRIORITY NOTIFICATION
    if (priority == 'high' || priority == 'medium') {
      NotificationService.showPriorityNotification(
        title: 'New ${priority.toUpperCase()} Priority Task',
        body: title,
        priority: priority,
      );
    }

    _titleController.clear();
    _descriptionController.clear();
    _selectedDueDate = null;
    _selectedPriority = 'medium';

    if (mounted) Navigator.pop(context);
  }

  // ================= ADD / EDIT DIALOG =================
  void _showAddTodoDialog({Todo? todo}) {
    if (todo != null) {
      _titleController.text = todo.title;
      _descriptionController.text = todo.description;
      _selectedPriority = todo.priority;
      _selectedDueDate = todo.dueDate;
    }

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Todo Dialog',
      barrierColor: Colors.black.withOpacity(0.35),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (_, __, ___) {
        return Center(
          child: Material(
            type: MaterialType.transparency,
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
              child: Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(20),
                decoration: _glassDecoration(),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _glassTextField(_titleController, 'Title'),
                    const SizedBox(height: 12),
                    _glassTextField(
                      _descriptionController,
                      'Description',
                      maxLines: 3,
                    ),
                    const SizedBox(height: 12),
                    _prioritySelector(),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _addTodo,
                      child: const Text('Save'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.grey[100],
      appBar: AppBar(title: const Text('My TODOs'), centerTitle: true),
      body: StreamBuilder<List<Todo>>(
        stream: _todoService.getTodos(widget.userId),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          var todos = snapshot.data!;

          // 🔍 SEARCH
          todos = todos
              .where(
                (t) => t.title.toLowerCase().contains(
                  _searchController.text.toLowerCase(),
                ),
              )
              .toList();

          // 🎯 FILTER
          if (_filterPriority != 'all') {
            todos = todos.where((t) => t.priority == _filterPriority).toList();
          }

          return Column(
            children: [
              _searchBar(),
              _filterChips(),
              _progressDashboard(todos),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: todos.length,
                  itemBuilder: (context, index) {
                    final animation = CurvedAnimation(
                      parent: _animationController,
                      curve: Interval(
                        index / todos.length,
                        1,
                        curve: Curves.easeOut,
                      ),
                    );
                    _animationController.forward();

                    return FadeTransition(
                      opacity: animation,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, 0.3),
                          end: Offset.zero,
                        ).animate(animation),
                        child: _todoCard(todos[index]),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTodoDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }

  // ================= TODO CARD =================
  Widget _todoCard(Todo todo) {
    final color = _priorityColor(todo.priority);

    return Dismissible(
      key: ValueKey(todo.id),
      background: _swipeBg(Icons.edit, Colors.blue),
      secondaryBackground: _swipeBg(Icons.delete, Colors.red),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.endToStart) {
          _todoService.deleteTodo(todo.id);
        } else {
          _showAddTodoDialog(todo: todo);
        }
        return false;
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: _glassDecoration(borderColor: color),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    todo.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                _animatedPriorityBadge(todo.priority),
              ],
            ),
            if (todo.description.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(todo.description),
              ),
            const SizedBox(height: 8),
            Row(
              children: [
                if (todo.dueDate != null)
                  Text(DateFormat('MMM dd').format(todo.dueDate!)),
                const Spacer(),
                Checkbox(
                  value: todo.isCompleted,
                  onChanged: (_) =>
                      _todoService.toggleTodoStatus(todo.id, todo.isCompleted),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ================= DASHBOARD =================
  Widget _progressDashboard(List<Todo> todos) {
    final completed = todos.where((t) => t.isCompleted).length;
    final percent = todos.isEmpty ? 0.0 : completed / todos.length;

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Progress: ${(percent * 100).toInt()}%'),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(value: percent, minHeight: 10),
          ),
        ],
      ),
    );
  }

  // ================= UI PARTS =================
  Widget _searchBar() => Padding(
    padding: const EdgeInsets.all(12),
    child: TextField(
      controller: _searchController,
      decoration: const InputDecoration(
        prefixIcon: Icon(Icons.search),
        hintText: 'Search todos...',
      ),
      onChanged: (_) => setState(() {}),
    ),
  );

  Widget _filterChips() => Wrap(
    spacing: 8,
    children: ['all', 'high', 'medium', 'low'].map((p) {
      return ChoiceChip(
        label: Text(p.toUpperCase()),
        selected: _filterPriority == p,
        onSelected: (_) => setState(() => _filterPriority = p),
      );
    }).toList(),
  );

  Widget _prioritySelector() => Wrap(
    spacing: 8,
    children: ['high', 'medium', 'low'].map((p) {
      return ChoiceChip(
        label: Text(p.toUpperCase()),
        selected: _selectedPriority == p,
        onSelected: (_) => setState(() => _selectedPriority = p),
      );
    }).toList(),
  );

  Widget _animatedPriorityBadge(String p) {
    final color = _priorityColor(p);
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: Container(
        key: ValueKey(p),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: color.withOpacity(0.25),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(p.toUpperCase(), style: TextStyle(color: color)),
      ),
    );
  }

  Color _priorityColor(String p) => p == 'high'
      ? Colors.red
      : p == 'medium'
      ? Colors.orange
      : Colors.green;

  Widget _swipeBg(IconData icon, Color color) => Container(
    color: color.withOpacity(0.2),
    alignment: icon == Icons.delete
        ? Alignment.centerRight
        : Alignment.centerLeft,
    padding: const EdgeInsets.symmetric(horizontal: 20),
    child: Icon(icon, color: color),
  );

  BoxDecoration _glassDecoration({Color? borderColor}) => BoxDecoration(
    color: Colors.white.withOpacity(0.35),
    borderRadius: BorderRadius.circular(18),
    border: Border.all(color: (borderColor ?? Colors.white).withOpacity(0.4)),
  );

  Widget _glassTextField(
    TextEditingController c,
    String label, {
    int maxLines = 1,
  }) => TextField(
    controller: c,
    maxLines: maxLines,
    decoration: InputDecoration(labelText: label),
  );
}
