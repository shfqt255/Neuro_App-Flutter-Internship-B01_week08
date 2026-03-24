import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'main.dart';
import 'detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<RemoteMessage> messages = []; // store received messages for display

  @override
  void initState() {
    super.initState();
    setupFCM();
  }

  void setupFCM() async {
    await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
          alert: true,
          badge: true,
          sound: true,
        );

    // Get token
    String? token = await FirebaseMessaging.instance.getToken();
    print("FCM Token: $token");
    FirebaseFirestore.instance.collection('Tokens').doc(token).set({
      'token':token,
      'createdAt': FieldValue.serverTimestamp(),
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      showNotification(message);
      setState(() {
        messages.add(message);
      });
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      if (message.data['screen'] == 'detail') {
        navigatorKey.currentState?.push(
          MaterialPageRoute(
            builder: (_) =>
                const DetailScreen(info: 'Opened from Notification'),
          ),
        );
      }
    });
  }

  void showNotification(RemoteMessage message) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'channel_id',
          'Default Channel',
          channelDescription: 'Notification channel',
          importance: Importance.max,
          priority: Priority.high,
        );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
    );

    await flutterLocalNotificationsPlugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      message.notification?.title ?? 'No Title',
      message.notification?.body ?? 'No Body',
      notificationDetails,
      payload: message.data['screen'],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('FCM Notifications'), backgroundColor: Colors.teal, foregroundColor: Colors.white,),
      body: ListView.builder(
        itemCount: messages.length,
        itemBuilder: (context, index) {
          final msg = messages[index];
          return Card(
            margin: const EdgeInsets.all(8),
            child: ListTile(
              title: Text(msg.notification?.title ?? 'No Title'),
              trailing: ElevatedButton(
                child: Text('View Details'),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DetailScreen(
                        info: msg.notification?.body ?? 'No details available',
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.teal, foregroundColor: Colors.white)
              ),
            ),
          );
        },
      ),
    );
  }
}
