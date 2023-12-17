import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:permission_handler/permission_handler.dart';

class PushNotificationSystem
{
  FirebaseMessaging firebaseCloudMessaging = FirebaseMessaging.instance;


  Future<void> initNotification() async {
    if (await isNotificationPermissionGranted()) {
      final FCMToken = await firebaseCloudMessaging.getToken();
      print('Token: $FCMToken');

    } else {
      // Izin notifikasi ditolak atau belum diberikan
      print('Izin notifikasi ditolak atau belum diberikan');

      // Meminta izin notifikasi
      requestNotificationPermission();
    }
  }

  Future<bool> isNotificationPermissionGranted() async {
    final status = await Permission.notification.status;
    return status == PermissionStatus.granted;
  }

  Future<void> requestNotificationPermission() async {
    await Permission.notification.request();
  }

  Future<String?> generateDeviceRegistrationToken() async
  {
    String? deviceRecognitionToken = await firebaseCloudMessaging.getToken();
    
    DatabaseReference referenceOnlineDriver = FirebaseDatabase.instance.ref()
        .child("drivers")
        .child(FirebaseAuth.instance.currentUser!.uid)
        .child("deviceToken");

    referenceOnlineDriver.set(deviceRecognitionToken);

    firebaseCloudMessaging.subscribeToTopic("drivers");
    firebaseCloudMessaging.subscribeToTopic("users");
  }

  startListeningForNewNotification() async
  {
    ///1. Terminated
    //When the app is completely closed and it receives a push notification
    FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? messageRemote)
    {
      if(messageRemote != null)
      {
        String tripID = messageRemote.data["tripID"];
      }
    });

    ///2. Foreground
    //When the app is open and it receives a push notification
    FirebaseMessaging.onMessage.listen((RemoteMessage? messageRemote)
    {
      if(messageRemote != null)
      {
        String tripID = messageRemote.data["tripID"];
      }
    });

    ///3. Background
    //When the app is in the background and it receives a push notification
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage? messageRemote)
    {
      if(messageRemote != null)
      {
        String tripID = messageRemote.data["tripID"];
      }
    });
  }
}