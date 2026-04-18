import 'package:flutter/material.dart';

class MyTasksPage extends StatelessWidget {
  const MyTasksPage({super.key});

  @override
  Widget build(BuildContext context) {
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
        body: const TabBarView(
          children: [
            Center(child: Text('No active assignments. Grab one from the feed!')),
            Center(child: Text('You have not completed any assignments yet.')),
          ],
        ),
      ),
    );
  }
}
