import 'package:flutter/material.dart';
import '../../core/api_client.dart';
import '../../core/models/task.dart';
import '../../core/ws_client.dart';

class SyncProvider extends ChangeNotifier {
  final List<Task> _tasks = [];
  WsClient? _wsClient;
  String status = 'Disconnected';
  bool syncing = false;

  List<Task> get tasks => List.unmodifiable(_tasks);
  bool get hasTasks => _tasks.isNotEmpty;

  Future<void> loadTasks() async {
    try {
      syncing = true;
      notifyListeners();
      final response = await ApiClient.list('tasks');
      _tasks.clear();
      for (final item in response) {
        _tasks.add(Task.fromJson(item as Map<String, dynamic>));
      }
    } finally {
      syncing = false;
      notifyListeners();
    }
  }

  void connect(String authToken) {
    if (_wsClient != null) return;
    _wsClient = WsClient.connect(authToken);
    _wsClient?.onEvent = _onWebSocketEvent;
    _wsClient?.listen();
    status = 'Realtime sync active';
    notifyListeners();
  }

  void _onWebSocketEvent(String type, Map<String, dynamic> payload) {
    switch (type) {
      case 'task_update':
      case 'task_created':
        _applyTask(payload['task'] as Map<String, dynamic>);
        break;
      case 'connected':
        status = payload['message'] as String? ?? 'Connected';
        break;
      default:
        break;
    }
    notifyListeners();
  }

  void _applyTask(Map<String, dynamic> taskJson) {
    final updated = Task.fromJson(taskJson);
    final index = _tasks.indexWhere((task) => task.id == updated.id);
    if (index >= 0) {
      _tasks[index] = updated;
    } else {
      _tasks.insert(0, updated);
    }
  }

  Future<void> toggleTaskCompletion(Task task) async {
    final nextState = !task.completed;
    await ApiClient.post('tasks/update', {
      'id': task.id,
      'completed': nextState,
    });
    _applyTask(task.copyWith(completed: nextState).toJson());
    notifyListeners();
  }

  Future<void> addTask(String title) async {
    final response = await ApiClient.post('tasks/update', {
      'title': title,
      'completed': false,
    });
    _applyTask(response['task'] as Map<String, dynamic>);
    notifyListeners();
  }

  @override
  void dispose() {
    _wsClient?.dispose();
    super.dispose();
  }
}
