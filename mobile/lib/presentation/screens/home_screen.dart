
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/sync_provider.dart';
import '../widgets/primary_button.dart';
import '../widgets/section_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _taskController = TextEditingController();

  @override
  void dispose() {
    _taskController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final sync = Provider.of<SyncProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Project Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              auth.logout();
              Navigator.pushReplacementNamed(context, '/login');
            },
          )
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await sync.loadTasks();
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            SectionCard(
              title: 'Welcome back',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Email: ${auth.user?.email ?? 'Unknown'}'),
                  const SizedBox(height: 6),
                  Text('Role: ${auth.user?.role ?? 'Member'}'),
                  const SizedBox(height: 6),
                  Text('Realtime status: ${sync.status}'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SectionCard(
              title: 'Current tasks',
              child: sync.syncing
                  ? const Center(child: CircularProgressIndicator())
                  : sync.hasTasks
                      ? Column(
                          children: sync.tasks.map((task) {
                            return ListTile(
                              leading: Icon(
                                task.completed ? Icons.check_circle : Icons.circle_outlined,
                                color: task.completed ? Colors.green : Colors.grey,
                              ),
                              title: Text(task.title),
                              trailing: TextButton(
                                onPressed: () {
                                  sync.toggleTaskCompletion(task);
                                },
                                child: Text(task.completed ? 'Reopen' : 'Complete'),
                              ),
                            );
                          }).toList(),
                        )
                      : const Text('No tasks yet. Pull to refresh or add a new item.'),
            ),
            const SizedBox(height: 16),
            SectionCard(
              title: 'Add project task',
              child: Column(
                children: [
                  TextField(
                    controller: _taskController,
                    decoration: const InputDecoration(
                      labelText: 'Task title',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  PrimaryButton(
                    text: 'Create task',
                    onPressed: () async {
                      final title = _taskController.text.trim();
                      if (title.isEmpty) return;
                      await sync.addTask(title);
                      _taskController.clear();
                      FocusScope.of(context).unfocus();
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await sync.loadTasks();
        },
        child: const Icon(Icons.sync),
      ),
    );
  }
}
