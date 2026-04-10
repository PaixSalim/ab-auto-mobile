import 'package:auto/app_database.dart';
import 'package:auto/notifications/data/models/notification_model.dart';
import 'package:auto/notifications/data/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';

class NotificationCenterPage extends StatefulWidget {
  const NotificationCenterPage({super.key});

  @override
  State<NotificationCenterPage> createState() => _NotificationCenterPageState();
}

class _NotificationCenterPageState extends State<NotificationCenterPage> {
  late List<NotificationObjectBox> _notifications;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
    NotificationService.markAllAsRead();
  }

  void _loadNotifications() {
    final box = ObjectBoxService().box<NotificationObjectBox>();
    setState(() {
      _notifications = box.getAll().reversed.toList();
    });
  }

  void _deleteNotification(int id) {
    final box = ObjectBoxService().box<NotificationObjectBox>();
    box.remove(id);
    _loadNotifications();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.trash2),
            onPressed: () {
              final box = ObjectBoxService().box<NotificationObjectBox>();
              box.removeAll();
              _loadNotifications();
            },
          ),
        ],
      ),
      body: _notifications.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(LucideIcons.bellOff, size: 64, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  const Text(
                    'Aucune notification pour le moment',
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                ],
              ),
            )
          : ListView.separated(
              itemCount: _notifications.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final notification = _notifications[index];
                return Dismissible(
                  key: Key(notification.id.toString()),
                  onDismissed: (direction) => _deleteNotification(notification.id),
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                      child: Icon(
                        LucideIcons.megaphone,
                        color: Theme.of(context).primaryColor,
                        size: 20,
                      ),
                    ),
                    title: Text(
                      notification.title ?? 'Sans titre',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(notification.body ?? ''),
                        const SizedBox(height: 4),
                        Text(
                          notification.receivedAt != null
                              ? DateFormat('dd/MM HH:mm').format(notification.receivedAt!)
                              : '',
                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                    isThreeLine: true,
                  ),
                );
              },
            ),
    );
  }
}
