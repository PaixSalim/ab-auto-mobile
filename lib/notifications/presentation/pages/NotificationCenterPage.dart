import 'dart:ui';
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
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.white.withValues(alpha: 0.7),
        elevation: 0,
        flexibleSpace: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(color: Colors.transparent),
          ),
        ),
        iconTheme: IconThemeData(color: Theme.of(context).primaryColor),
        title: Text(
          'Notifications',
          style: TextStyle(
            color: Theme.of(context).primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
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
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFFF0F0), Color(0xFFFDFBFB), Color(0xFFF4F7FB)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: _notifications.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.6),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Theme.of(context).primaryColor.withValues(alpha: 0.05),
                            blurRadius: 20,
                            spreadRadius: 5,
                          )
                        ],
                      ),
                      child: Icon(
                        LucideIcons.bellOff,
                        size: 48,
                        color: Theme.of(context).primaryColor.withValues(alpha: 0.4),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Aucune notification',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Vous êtes à jour !',
                      style: TextStyle(color: Colors.grey[600], fontSize: 16),
                    ),
                  ],
                ),
              )
            : ListView.builder(
                padding: EdgeInsets.only(
                  top: kToolbarHeight + MediaQuery.of(context).padding.top + 16,
                  bottom: MediaQuery.of(context).padding.bottom + 16,
                ),
                itemCount: _notifications.length,
                itemBuilder: (context, index) {
                  final notification = _notifications[index];
                  return Dismissible(
                    key: Key(notification.id.toString()),
                    onDismissed: (direction) => _deleteNotification(notification.id),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.redAccent,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 24),
                      child: const Icon(LucideIcons.trash2, color: Colors.white),
                    ),
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.8), width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: Theme.of(context).primaryColor.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CircleAvatar(
                                  backgroundColor: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                                  radius: 24,
                                  child: Icon(
                                    LucideIcons.megaphone,
                                    color: Theme.of(context).primaryColor,
                                    size: 22,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        notification.title ?? 'Sans titre',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w800,
                                          fontSize: 15,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        notification.body ?? '',
                                        style: const TextStyle(
                                          color: Colors.black87,
                                          height: 1.4,
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      Text(
                                        notification.receivedAt != null
                                            ? DateFormat('dd/MM à HH:mm').format(notification.receivedAt!)
                                            : '',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                          color: Theme.of(context).primaryColor.withValues(alpha: 0.6),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
