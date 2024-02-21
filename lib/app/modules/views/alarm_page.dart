import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:project1/alarm_helper.dart';
import 'package:project1/app/data/models/alarm_info.dart';
import 'package:project1/app/data/theme_data.dart';
import 'package:project1/app/modules/views/homepage.dart';
import 'package:project1/main.dart';
import 'package:timezone/timezone.dart' as tz;

import '../../../notification/local_notification.dart';

class AlarmPage extends StatefulWidget {
  ValueNotifier<List<AlarmInfo>> listAlarm;
  AlarmPage({required this.listAlarm});
  @override
  _AlarmPageState createState() => _AlarmPageState();
}

class _AlarmPageState extends State<AlarmPage> {
  DateTime? _alarmTime;
  late String _alarmTimeString;
  bool _isRepeatSelected = false;
  AlarmHelper _alarmHelper = AlarmHelper();
  // Future<List<AlarmInfo>>? _alarms;
  List<AlarmInfo>? _currentAlarms;

  @override
  void initState() {
    _alarmTime = DateTime.now();
    // _alarmHelper.initializeDatabase().then((value) {
    //   print('------database intialized');
    //   loadAlarms();
    // });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 64),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Alarm',
            style: TextStyle(
                fontFamily: 'avenir',
                fontWeight: FontWeight.w700,
                color: CustomColors.primaryTextColor,
                fontSize: 24),
          ),
          Expanded(
            child: ValueListenableBuilder<List<AlarmInfo>>(
              valueListenable: widget.listAlarm,
              builder: (context, value, child) {
                _currentAlarms = value;
                return SingleChildScrollView(
                  child: Column(
                    children: List.generate(value.length, (index) {
                      var alarmTime = DateFormat('HH:mm aa')
                          .format(value[index].alarmDateTime!);
                      // var gradientColor =
                      //     GradientTemplate.gradientTemplate[index].colors;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 32),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              // color: gradientColor.last.withOpacity(0.4),
                              blurRadius: 8,
                              spreadRadius: 2,
                              offset: Offset(4, 4),
                            ),
                          ],
                          borderRadius: BorderRadius.all(Radius.circular(24)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Row(
                                  children: <Widget>[
                                    const Icon(
                                      Icons.label,
                                      color: Colors.white,
                                      size: 24,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      value[index].title!,
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontFamily: 'avenir'),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text(
                                  alarmTime,
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontFamily: 'avenir',
                                      fontSize: 24,
                                      fontWeight: FontWeight.w700),
                                ),
                                IconButton(
                                    icon: Icon(Icons.delete),
                                    color: Colors.white,
                                    onPressed: () {
                                      deleteAlarm(value[index].id);
                                    }),
                              ],
                            ),
                          ],
                        ),
                      );
                    })
                      ..addAll([
                        DottedBorder(
                          strokeWidth: 2,
                          color: CustomColors.clockOutline,
                          borderType: BorderType.RRect,
                          radius: Radius.circular(24),
                          dashPattern: [5, 4],
                          child: Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: CustomColors.clockBG,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(24)),
                            ),
                            child: MaterialButton(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 32, vertical: 16),
                              onPressed: () {
                                _alarmTimeString =
                                    DateFormat('HH:mm').format(DateTime.now());
                                showModalBottomSheet(
                                  useRootNavigator: true,
                                  context: context,
                                  clipBehavior: Clip.antiAlias,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(24),
                                    ),
                                  ),
                                  builder: (context) {
                                    _alarmTime = DateTime.now();
                                    return _buildBottonSheet();
                                  },
                                );
                                // scheduleAlarm();
                              },
                              child: Column(
                                children: <Widget>[
                                  Image.asset('assets/add_alarm.png',
                                      scale: 1.5),
                                  const SizedBox(height: 8),
                                  const Text(
                                    'Add Alarm',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontFamily: 'avenir'),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                        // else
                        //   const Center(
                        //       child: Text(
                        //     'Only 5 alarms allowed!',
                        //     style: TextStyle(color: Colors.white),
                        //   )),
                      ]),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottonSheet() {
    return StatefulBuilder(
      builder: (context, setModalState) {
        return Container(
          width: MediaQuery.of(context).size.width,
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              TextButton(
                onPressed: () async {
                  var selectedTime = await showTimePicker(
                      context: context, initialTime: TimeOfDay.now());

                  if (selectedTime != null) {
                    final now = DateTime.now();
                    var selectedDateTime = DateTime(now.year, now.month,
                        now.day, selectedTime.hour, selectedTime.minute);
                    _alarmTime = selectedDateTime;
                    setModalState(() {
                      _alarmTimeString =
                          DateFormat('HH:mm').format(selectedDateTime);
                      print(DateFormat('HH:mm').format(selectedDateTime));
                    });
                  }
                },
                child: Text(
                  _alarmTimeString,
                  style: TextStyle(fontSize: 32),
                ),
              ),
              const Expanded(child: SizedBox()),
              FloatingActionButton.extended(
                onPressed: () {
                  onSaveAlarm(_isRepeatSelected);
                },
                icon: Icon(Icons.alarm),
                label: Text('Save'),
              ),
            ],
          ),
        );
      },
    );
  }

  void scheduleAlarm(
      DateTime scheduledNotificationDateTime, AlarmInfo alarmInfo,
      {required bool isRepeating}) async {
    var iOSPlatformChannelSpecifics = const DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    var platformChannelSpecifics = NotificationDetails(
      macOS: iOSPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    if (isRepeating)
      await LocalNotification.showNotification('Thông báo', 'Báo thức', '');
  }

  void onSaveAlarm(bool _isRepeating) async {
    DateTime? scheduleAlarmDateTime;
    if (_alarmTime!.isAfter(DateTime.now())) {
      scheduleAlarmDateTime = _alarmTime;
      var alarmInfo = AlarmInfo(
        alarmDateTime: scheduleAlarmDateTime,
        gradientColorIndex: _currentAlarms!.length,
        title: 'alarm',
      );
      _alarmHelper.insertAlarm(alarmInfo);
      if (scheduleAlarmDateTime != null) {
        scheduleAlarm(scheduleAlarmDateTime, alarmInfo,
            isRepeating: _isRepeating);
      }
      widget.listAlarm.value = [];
      widget.listAlarm.value = await _alarmHelper.getAlarms();
      Navigator.pop(context);
      // loadAlarms();
    } else {
      Navigator.pop(context);
    }

    // else
    //   scheduleAlarmDateTime = _alarmTime!.add(Duration(days: 1));
  }

  void deleteAlarm(int? id) async {
    _alarmHelper.delete(id);
    widget.listAlarm.value = [];
    widget.listAlarm.value = await _alarmHelper.getAlarms();
    //unsubscribe for notification
    // loadAlarms();
  }
}
