import 'package:flutter/material.dart';
import 'package:project1/app/data/enums.dart';
import 'package:project1/app/data/models/alarm_info.dart';
import 'package:project1/app/data/models/menu_info.dart';

List<MenuInfo> menuItems = [
  MenuInfo(MenuType.clock, title: 'Clock', icon: Icons.access_time),
  MenuInfo(MenuType.alarm, title: 'Alarm', icon: Icons.access_alarm),
];
