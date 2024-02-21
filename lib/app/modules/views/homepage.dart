import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:project1/app/data/data.dart';
import 'package:project1/app/data/enums.dart';
import 'package:project1/app/data/models/alarm_info.dart';
import 'package:project1/app/data/models/menu_info.dart';
import 'package:project1/app/data/theme_data.dart';
import 'package:project1/app/modules/views/alarm_page.dart';
import 'package:project1/app/modules/views/clock_page.dart';
import 'package:project1/notification/local_notification.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../alarm_helper.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Timer _timer;
  bool isFirst = true;
  List<TimeOfDay> b = [];
  AlarmHelper _alarmHelper = AlarmHelper();
  ValueNotifier<List<AlarmInfo>> listAlarmTotal = ValueNotifier([]);

  @override
  void initState() {
    checkAlarm();
    super.initState();
  }

  checkAlarm() async {
    listAlarmTotal.addListener(() {
      print('bắt đầu lắng nghe a12');
      _timer = Timer.periodic(Duration(seconds: 2), (Timer timer) async {
        print('bắt đầu đang lắng nghe');
        final currentTime = TimeOfDay.now();
        if (listAlarmTotal.value.isNotEmpty) {
          timer.cancel();
          List<DateTime> ListDatetime = [];
          listAlarmTotal.value.forEach((element) {
            ListDatetime.add(element.alarmDateTime!);
          });
          DateTime? result = findClosestTime(ListDatetime);
          if (result == null) {
            print('không tìm thấy');
            timer.cancel();
          } else {
            timer.cancel();
            Duration difference = result.difference(DateTime.now());
            Future.delayed(difference).then((value) async {
              await Future.delayed(Duration(seconds: 1))
                  .then((value) => notification());
            });
          }
        } else {
          print('danh sách rỗng');
          timer.cancel();
        }
      });
    });
  }

  DateTime? findClosestTime(List<DateTime> futureTimes) {
    DateTime now = DateTime.now();
    DateTime closestTime = futureTimes[0];
    Duration closestDifference = (futureTimes[0].difference(now)).abs();

    for (int i = 1; i < futureTimes.length; i++) {
      Duration difference = (futureTimes[i].difference(now)).abs();
      if (difference < closestDifference) {
        closestTime = futureTimes[i];
        closestDifference = difference;
      }
    }
    print(closestTime);
    Duration difference = closestTime.difference(now);
    print('thời gian cách nhau bao giây: ${difference.inSeconds}');
    if (difference.inMinutes < 0) {
      return null;
    } else {
      return closestTime;
    }
  }

  notification() async {
    LocalNotification.showNotification('Notification', 'Alarm', '');
    Future.delayed(Duration(seconds: 59)).then(
        (value) async => listAlarmTotal.value = await _alarmHelper.getAlarms());
  }

  getListAlarm() async {
    listAlarmTotal.value = await AlarmHelper().getAlarms();
    b = List.generate(listAlarmTotal.value.length, (index) {
      return TimeOfDay(
          hour: listAlarmTotal.value[index].alarmDateTime!.hour,
          minute: listAlarmTotal.value[index].alarmDateTime!.minute);
    });
  }

  @override
  void dispose() {
    listAlarmTotal.dispose();
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    getListAlarm();

    return ChangeNotifierProvider<MenuInfo>(
      create: (context) => MenuInfo(MenuType.clock),
      child: Scaffold(
        backgroundColor: CustomColors.clockBG,
        body: Row(
          children: <Widget>[
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: menuItems
                  .map((currentMenuInfo) => buildMenuButton(currentMenuInfo))
                  .toList(),
            ),
            VerticalDivider(
              color: CustomColors.dividerColor,
              width: 1,
            ),
            Expanded(
              child: Consumer<MenuInfo>(
                builder: (BuildContext context, MenuInfo value, Widget? child) {
                  if (value.menuType == MenuType.clock)
                    return ClockPage();
                  else if (value.menuType == MenuType.alarm)
                    return AlarmPage(listAlarm: listAlarmTotal);
                  else
                    return SizedBox();
                  // else
                  //   return Container(
                  //     child: RichText(
                  //       text: TextSpan(
                  //         style: TextStyle(fontSize: 20),
                  //         children: <TextSpan>[
                  //           TextSpan(text: 'Upcoming Tutorial\n'),
                  //           TextSpan(
                  //             text: value.title,
                  //             style: TextStyle(fontSize: 48),
                  //           ),
                  //         ],
                  //       ),
                  //     ),
                  //   );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildMenuButton(MenuInfo currentMenuInfo) {
    return Consumer<MenuInfo>(
      builder: (BuildContext context, MenuInfo value, Widget? child) {
        return MaterialButton(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                  topRight: Radius.circular(32),
                  bottomRight: Radius.circular(32))),
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 0),
          color: currentMenuInfo.menuType == value.menuType
              ? CustomColors.menuBackgroundColor
              : CustomColors.clockBG,
          onPressed: () {
            var menuInfo = Provider.of<MenuInfo>(context, listen: false);
            menuInfo.updateMenu(currentMenuInfo);
          },
          child: Column(
            children: <Widget>[
              Icon(
                currentMenuInfo.icon,
                color: Colors.white,
                size: 50,
              ),
              SizedBox(height: 16),
              Text(
                currentMenuInfo.title ?? '',
                style: TextStyle(
                    fontFamily: 'avenir',
                    color: CustomColors.primaryTextColor,
                    fontSize: 14),
              ),
            ],
          ),
        );
      },
    );
  }
}
