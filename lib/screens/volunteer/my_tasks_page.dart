import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_resource_alloc/providers/app_state.dart';
import 'package:smart_resource_alloc/services/auth_service.dart';
import 'package:smart_resource_alloc/theme/app_theme.dart';
import 'package:smart_resource_alloc/models/task.dart';

class MyTasksPage extends StatefulWidget {
  const MyTasksPage({super.key});

  @override
  State<MyTasksPage> createState() => _MyTasksPageState();
}

class _MyTasksPageState extends State<MyTasksPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
         final uid = context.read<AuthService>().uid;
         context.read<AppState>().fetchTasks(volunteerId: uid);
      }
    });
  }

  Widget _buildTaskList(List<Task> tasks, String emptyMessage) {
    if (tasks.isEmpty) {
      return Center(child: Text(emptyMessage));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            title: Text(task.needTitle ?? 'Task ${task.id}', style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('Status: ${task.status}'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
               // navigate to task detail or check-in depending on status
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('My Assignments'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Active'),
              Tab(text: 'Completed'),
            ],
          ),
        ),
        body: state.isLoadingTasks
            ? const Center(child: CircularProgressIndicator())
            : TabBarView(
                children: [
                  _buildTaskList(state.activeTasks, 'No active assignments. Grab one from the feed!'),
                  _buildTaskList(state.completedTasks, 'You have not completed any assignments yet.'),
                ],
              ),
      ),
    );
  }
}
