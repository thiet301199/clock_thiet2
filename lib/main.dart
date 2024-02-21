import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:project1/app/data/enums.dart';
import 'package:project1/notification/local_notification.dart';
import 'package:provider/provider.dart';
import 'app/data/models/menu_info.dart';
import 'app/modules/views/homepage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  LocalNotification.setup();

  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.amber,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      scrollBehavior: MyCustomScrollBehavior(),
      home: HomePage(),
    ),
  );
}

class MyCustomScrollBehavior extends MaterialScrollBehavior {
  // Override behavior methods and getters like dragDevices
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        // etc.
      };
}
