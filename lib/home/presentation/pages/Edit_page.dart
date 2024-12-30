import 'package:alarm/alarm.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

@RoutePage()
class ExampleAlarmEditScreen extends StatefulWidget {
  const ExampleAlarmEditScreen({super.key, this.alarmSettings});
  final AlarmSettings? alarmSettings;

  @override
  State<ExampleAlarmEditScreen> createState() => _ExampleAlarmEditScreenState();
}

DateTime selectedDateTime = DateTime.now();

class _ExampleAlarmEditScreenState extends State<ExampleAlarmEditScreen> {
  bool loading = false;

  late bool creating;
  late bool loopAudio;
  late bool vibrate;
  late double? volume;
  late String assetAudio;
  int hour = 0;
  int minute = 0;
  String amPm = 'AM';

  FixedExtentScrollController _minuteController = FixedExtentScrollController();
  FixedExtentScrollController _hourController = FixedExtentScrollController();
  FixedExtentScrollController _ampmController = FixedExtentScrollController();

  final List<String> audioFiles = [
    'assets/alarm.mp3',
  ];

  @override
  void initState() {
    super.initState();
    creating = widget.alarmSettings == null;
    setState(() {
      assetAudio = audioFiles[0];
    });
    if (creating) {
      selectedDateTime = DateTime.now().add(const Duration(minutes: 1));
      selectedDateTime = selectedDateTime.copyWith(second: 0, millisecond: 0);
      loopAudio = true;
      vibrate = true;
      volume = null;
      assetAudio = audioFiles[0];
    } else {
      selectedDateTime = widget.alarmSettings!.dateTime;
      loopAudio = widget.alarmSettings!.loopAudio;
      vibrate = widget.alarmSettings!.vibrate;
      volume = widget.alarmSettings!.volume;
      assetAudio = widget.alarmSettings!.assetAudioPath;
    }
    _minuteController =
        FixedExtentScrollController(initialItem: selectedDateTime.minute);
    _hourController =
        FixedExtentScrollController(initialItem: selectedDateTime.hour % 12);
    _ampmController = FixedExtentScrollController(
      initialItem: selectedDateTime.hour >= 12 ? 1 : 0,
    );
  }

  String getDay() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final difference = selectedDateTime.difference(today).inDays;

    switch (difference) {
      case 0:
        return 'Today - ${DateFormat('EEE, d MMM').format(selectedDateTime)}';
      case 1:
        return 'Tomorrow - ${DateFormat('EEE, d MMM').format(selectedDateTime)}';
      default:
        return DateFormat('EEE, d MMM').format(selectedDateTime);
    }
  }

  Future<void> pickTime() async {
    final res = await showTimePicker(
      initialTime: TimeOfDay.fromDateTime(selectedDateTime),
      context: context,
    );

    if (res != null) {
      setState(() {
        final now = DateTime.now();
        selectedDateTime = now.copyWith(
          hour: res.hour,
          minute: res.minute,
          second: 0,
          millisecond: 0,
          microsecond: 0,
        );
        if (selectedDateTime.isBefore(now)) {
          selectedDateTime = selectedDateTime.add(const Duration(days: 1));
        }
      });
    }
  }

  AlarmSettings buildAlarmSettings() {
    final id = creating
        ? DateTime.now().millisecondsSinceEpoch % 10000
        : widget.alarmSettings!.id;

    final alarmSettings = AlarmSettings(
      id: id,
      dateTime: selectedDateTime,
      assetAudioPath: assetAudio,
      volume: volume ?? 0.8,
      fadeDuration: 3,
      loopAudio: loopAudio,
      vibrate: vibrate,
      notificationSettings: const NotificationSettings(
        title: 'Alarm',
        body: 'Your alarm is ringing',
        stopButton: 'Stop the alarm',
        icon: 'notification_icon',
      ),
    );
    return alarmSettings;
  }

  Future<void> saveAlarm() async {
    if (loading) return;
    setState(() => loading = true);
    final alarmSettings = buildAlarmSettings();
    final res = await Alarm.set(alarmSettings: alarmSettings);
    if (res) {
      Navigator.pop(context, true);
    } else {
      setState(() => loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to set alarm'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Alarm'),
        backgroundColor: const Color(0xFF1F2633),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Flexible(
              child: Row(
                children: [
                  Flexible(
                    child: CupertinoPicker(
                      squeeze: 0.8,
                      diameterRatio: 5,
                      useMagnifier: true,
                      looping: true,
                      itemExtent: 100,
                      scrollController: _hourController,
                      selectionOverlay:
                          const CupertinoPickerDefaultSelectionOverlay(
                        background: Colors.transparent,
                      ),
                      onSelectedItemChanged: (value) {
                        setState(() {
                          hour = value + 1;
                        });
                        _time();
                      },
                      children: [
                        for (int i = 1; i <= 12; i++) ...[
                          Center(
                            child: Text(
                              '$i',
                              style: const TextStyle(fontSize: 50),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const Text(
                    ':',
                    style: TextStyle(fontSize: 50),
                  ),
                  Flexible(
                    child: CupertinoPicker(
                      squeeze: 0.8,
                      diameterRatio: 5,
                      looping: true,
                      itemExtent: 100,
                      scrollController: _minuteController,
                      selectionOverlay:
                          const CupertinoPickerDefaultSelectionOverlay(
                        background: Colors.transparent,
                      ),
                      onSelectedItemChanged: (value) {
                        setState(() {
                          minute = value;
                          _time();
                        });
                      },
                      children: [
                        for (int i = 0; i <= 59; i++) ...[
                          Center(
                            child: Text(
                              i.toString().padLeft(2, '0'),
                              style: const TextStyle(fontSize: 50),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  Flexible(
                    child: CupertinoPicker(
                      squeeze: 1,
                      diameterRatio: 15,
                      useMagnifier: true,
                      itemExtent: 100,
                      scrollController: _ampmController,
                      selectionOverlay:
                          const CupertinoPickerDefaultSelectionOverlay(
                        background: Colors.transparent,
                      ),
                      onSelectedItemChanged: (value) {
                        setState(() {
                          amPm = value == 0 ? 'AM' : 'PM';
                        });
                        _time();
                      },
                      children: [
                        for (final i in ['AM', 'PM']) ...[
                          Center(
                            child: Text(
                              i,
                              style: const TextStyle(fontSize: 50),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      ListTile(
                        title: Text(getDay()),
                        trailing: IconButton(
                          onPressed: () => _selectDate(context),
                          icon: const Icon(Icons.calendar_month_outlined),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        child: Divider(),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        child: Divider(),
                      ),
                      ListTile(
                        title: const Text('Vibration'),
                        trailing: Switch(
                          value: vibrate,
                          onChanged: (value) => setState(() => vibrate = value),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        child: Divider(),
                      ),
                      ListTile(
                        title: const Text('Volume level'),
                        trailing: Switch(
                          value: volume != null,
                          onChanged: (value) =>
                              setState(() => volume = value ? 0.5 : null),
                        ),
                      ),
                      SizedBox(
                        height: 30,
                        child: volume != null
                            ? Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Icon(
                                      volume! > 0.7
                                          ? Icons.volume_up_rounded
                                          : volume! > 0.1
                                              ? Icons.volume_down_rounded
                                              : Icons.volume_mute_rounded,
                                    ),
                                    Expanded(
                                      child: Slider(
                                        value: volume!,
                                        onChanged: (value) {
                                          setState(() => volume = value);
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : const SizedBox(),
                      ),
                      const SizedBox(),
                    ],
                  ),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1F2633),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                  ),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: Colors.blue),
                  ),
                ),
                ElevatedButton(
                  onPressed: saveAlarm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1F2633),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                  ),
                  child: loading
                      ? const CircularProgressIndicator()
                      : const Text(
                          'Save',
                          style: TextStyle(color: Colors.blue),
                        ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _time() {
    final timeString = '$hour:$minute $amPm';
    final dateTime = convertStringToDateTime(timeString);
    setState(() {
      selectedDateTime = dateTime;
      if (selectedDateTime.isBefore(DateTime.now())) {
        selectedDateTime = selectedDateTime.add(const Duration(days: 1));
      }
      getDay();
    });
  }

  DateTime convertStringToDateTime(String timeString) {
    final format = DateFormat('hh:mm a');
    var dateTime = format.parse(timeString);

    final today = DateTime.now();
    dateTime = DateTime(
      today.year,
      today.month,
      today.day,
      dateTime.hour,
      dateTime.minute,
    );

    return dateTime;
  }

  Future<void> _selectDate(BuildContext context) async {
    final now = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      currentDate: selectedDateTime,
      lastDate: DateTime(2030, 12, 31),
    );

    if (now != null) {
      setState(() {
        selectedDateTime = now;
        if (selectedDateTime.isBefore(DateTime.now())) {
          selectedDateTime = selectedDateTime.add(const Duration(days: 1));
        }
        getDay();
      });
    }
  }
}
