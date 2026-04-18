import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Alerts & Notifications'),
        actions: [
          TextButton(onPressed: () {}, child: const Text('Mark all read'))
        ],
      ),
      body: ListView(
        children: [
          _buildNotification(
            'New Critical Task Match!',
            'An emergency blood requirement matches your profile. Swipe to accept.',
            'Just now',
            true,
          ),
          _buildNotification(
            'Campaign Update',
            'Monsoon Preparedness Drive is now 45% fully staffed.',
            '2 hours ago',
            false,
          ),
          _buildNotification(
            'Task Approved',
            'NGO Coordinator approved your dispatch for Night Shelter Setup.',
            'Yesterday',
            false,
          ),
        ],
      ),
    );
  }

  Widget _buildNotification(String title, String body, String time, bool unread) {
    return ListTile(
      tileColor: unread ? Colors.white.withOpacity(0.05) : null,
      leading: CircleAvatar(
        backgroundColor: unread ? Colors.red.withOpacity(0.2) : Colors.white12,
        child: Icon(unread ? LucideIcons.bellRing : LucideIcons.bell, color: unread ? Colors.redAccent : Colors.white),
      ),
      title: Text(title, style: TextStyle(fontWeight: unread ? FontWeight.bold : FontWeight.normal)),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          Text(body),
          const SizedBox(height: 4),
          Text(time, style: const TextStyle(fontSize: 10, color: Colors.blueAccent)),
        ],
      ),
      onTap: () {},
    );
  }
}
