import 'dart:async';
import 'dart:io';
import 'package:alarm/alarm.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:flutter_time_picker_spinner/flutter_time_picker_spinner.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:progressive_time_picker/progressive_time_picker.dart';
import 'package:sleep/home/presentation/pages/widgets/base_navigation_bar.dart';

@RoutePage()
class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage>
    with TickerProviderStateMixin {
  final String _fileExtension = '.aac';
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  final FlutterSoundPlayer _player = FlutterSoundPlayer();
  bool _isRecording = false;
  String? _filePath;

  ClockTimeFormat clockTimeFormat = ClockTimeFormat.twentyFourHours;
  ClockIncrementTimeFormat clockIncrementTimeFormat =
      ClockIncrementTimeFormat.fiveMin;

  PickedTime inBedTime = PickedTime(h: 0, m: 0);
  PickedTime outBedTime = PickedTime(h: 8, m: 0);
  PickedTime intervalBedTime = PickedTime(h: 0, m: 0);

  double sleepGoal = 8;
  bool isSleepGoal = false;
  bool? validRange = true;
  bool _isSetAlarm = false;

  @override
  void initState() {
    super.initState();
    _initializeRecorder();
    _initializePlayer();
    _initializeAlarm();
  }

  Future<void> _initializeAlarm() async {
    await Alarm.init();
  }

  Future<bool> _fileExists(String filePath) async {
    final file = File(filePath);
    return file.exists();
  }

  Future<void> _initializeRecorder() async {
    try {
      final status = await Permission.microphone.request();
      if (status.isGranted) {
        await _recorder.openRecorder();
      } else {
        throw Exception('Microphone permission not granted');
      }
    } catch (e) {
      debugPrint('Recorder initialization failed: $e');
    }
  }

  Future<void> _initializePlayer() async {
    try {
      await _player.openPlayer();
    } catch (e) {
      debugPrint('Player initialization failed: $e');
    }
  }

  Future<void> _startRecording() async {
    try {
      _filePath = '${Directory.systemTemp.path}/audio_example.aac';
      await _recorder.startRecorder(
        toFile: _filePath,
        codec: Codec.aacADTS,
        sampleRate: 44100,
        bitRate: 128000,
      );
      setState(() {
        _isRecording = true;
      });
    } catch (e) {
      debugPrint('Error starting recording: $e');
    }
  }

  Future<void> _stopRecording() async {
    try {
      await _recorder.stopRecorder();
      setState(() {
        _isRecording = false;
      });

      if (_filePath != null) {
        final exists = await _fileExists(_filePath!);
        if (exists) {
          final directory = await getApplicationDocumentsDirectory();
          final newFileName =
              '${directory.path}/recordedFile_${DateTime.now().millisecondsSinceEpoch}$_fileExtension';
          final newFile = await File(_filePath!).copy(newFileName);
          debugPrint('Recording saved successfully at ${newFile.path}');
        } else {
          debugPrint('Recording file not found at $_filePath');
        }
      }
    } catch (e) {
      debugPrint('Error stopping recording: $e');
    }
  }

  void _setAlarm() {
    final now = DateTime.now();
    var alarmTime = DateTime(
      now.year,
      now.month,
      now.day,
      outBedTime.h,
      outBedTime.m,
    );
    final bedTime = DateTime(
      now.year,
      now.month,
      now.day,
      inBedTime.h,
      inBedTime.m,
    );
    // If the alarm time is in the past, set it for the next day
    if (alarmTime.isBefore(now) || bedTime.isAtSameMomentAs(now)) {
      alarmTime = alarmTime.add(const Duration(days: 1));
    }

    final alarmSettings = AlarmSettings(
      id: 42,
      dateTime: alarmTime,
      assetAudioPath: 'assets/alarm.mp3',
      volume: 1,
      fadeDuration: 3,
      warningNotificationOnKill: Platform.isIOS,
      notificationSettings: const NotificationSettings(
        title: 'This is the title',
        body: 'This is the body',
        stopButton: 'Stop the alarm',
        icon: 'notification_icon',
      ),
    );

    // Đặt báo thức
    Alarm.set(alarmSettings: alarmSettings).then((_) {
      setState(() {
        _isSetAlarm = true;
      });
      debugPrint('Alarm set successfully');
    });
  }

  Future<void> _cancelAlarm() async {
    await Alarm.stop(42);
    setState(() {
      _isSetAlarm = false;
    });
    debugPrint('Alarm canceled');
  }

  @override
  void dispose() {
    _recorder.closeRecorder();
    _player.closePlayer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xFF141925),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            width: double.infinity,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildTimePicker(),
                const SizedBox(height: 16),
                _buildSleepInfo(),
                const SizedBox(height: 16),
                _buildButtons(),
              ],
            ),
          ),
        ),
        bottomNavigationBar: const BaseNavigationBar(),
      ),
    );
  }

  Widget _buildTimePicker() {
    return Column(
      children: [
        TimePicker(
          initTime: inBedTime,
          endTime: outBedTime,
          disabledRanges: const [],
          height: 260,
          width: 260,
          onSelectionChange: _updateLabels,
          onSelectionEnd: (start, end, isDisableRange) => debugPrint(
            'onSelectionEnd => init : ${start.h}:${start.m}, end : ${end.h}:${end.m}, isDisableRange: $isDisableRange',
          ),
          primarySectors: clockTimeFormat.value,
          secondarySectors: clockTimeFormat.value * 2,
          decoration: TimePickerDecoration(
            baseColor: const Color(0xFF1F2633),
            pickerBaseCirclePadding: 15,
            sweepDecoration: TimePickerSweepDecoration(
              pickerStrokeWidth: 30,
              pickerColor: isSleepGoal ? const Color(0xFF3CDAF7) : Colors.white,
              showConnector: true,
            ),
            initHandlerDecoration: TimePickerHandlerDecoration(
              color: const Color(0xFF141925),
              radius: 12,
              icon: const Icon(
                Icons.power_settings_new_outlined,
                size: 20,
                color: Color(0xFF3CDAF7),
              ),
            ),
            endHandlerDecoration: TimePickerHandlerDecoration(
              color: const Color(0xFF141925),
              radius: 12,
              icon: const Icon(
                Icons.notifications_active_outlined,
                size: 20,
                color: Color(0xFF3CDAF7),
              ),
            ),
            primarySectorsDecoration: TimePickerSectorDecoration(
              color: Colors.white,
              width: 1,
              size: 4,
              radiusPadding: 25,
            ),
            secondarySectorsDecoration: TimePickerSectorDecoration(
              color: const Color(0xFF3CDAF7),
              width: 1,
              size: 2,
              radiusPadding: 25,
            ),
            clockNumberDecoration: TimePickerClockNumberDecoration(
              defaultTextColor: Colors.white,
              defaultFontSize: 12,
              scaleFactor: 2,
              clockTimeFormat: clockTimeFormat,
              clockIncrementTimeFormat: clockIncrementTimeFormat,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(62),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${NumberFormat('00').format(intervalBedTime.h)}Hr ${NumberFormat('00').format(intervalBedTime.m)}Min',
                  style: TextStyle(
                    fontSize: 12,
                    color: isSleepGoal ? const Color(0xFF3CDAF7) : Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSleepInfo() {
    return Column(
      children: [
        const Text(
          'Thời gian ngủ',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          '${NumberFormat('00').format(inBedTime.h)}:${NumberFormat('00').format(inBedTime.m)} - ${NumberFormat('00').format(outBedTime.h)}:${NumberFormat('00').format(outBedTime.m)}',
          style: const TextStyle(
            color: Color(0xFF3CDAF7),
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildButtons() {
    return Column(
      children: [
        ElevatedButton(
          onPressed: () {
            setState(() {
              inBedTime = PickedTime(
                h: DateTime.now().hour,
                m: DateTime.now().minute,
              );
              outBedTime = PickedTime(
                h: DateTime.now().hour + 8,
                m: DateTime.now().minute,
              );
              intervalBedTime = formatIntervalTime(
                init: inBedTime,
                end: outBedTime,
                clockTimeFormat: clockTimeFormat,
                clockIncrementTimeFormat: clockIncrementTimeFormat,
              );
            });
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1F2633),
            fixedSize: const Size(200, 50),
          ),
          child: const Text(
            'Auto Sleep',
            style: TextStyle(
              color: Color(0xFF3CDAF7),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () {
            showDialog<void>(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  backgroundColor: const Color(0xFF1F2633),
                  title: const Text(
                    'Chọn thời gian thức dậy',
                    style: TextStyle(color: Colors.white),
                  ),
                  content: TimePickerSpinner(
                    normalTextStyle: const TextStyle(
                      fontSize: 24,
                      color: Color.fromARGB(87, 255, 255, 255),
                    ),
                    highlightedTextStyle: const TextStyle(
                      fontSize: 24,
                      color: Color.fromARGB(255, 255, 255, 255),
                    ),
                    spacing: 50,
                    itemHeight: 80,
                    isForce2Digits: true,
                    onTimeChange: (time) {
                      setState(() {
                        outBedTime = PickedTime(
                          h: time.hour,
                          m: time.minute,
                        );
                        inBedTime = PickedTime(
                          h: DateTime.now().hour,
                          m: DateTime.now().minute,
                        );
                        intervalBedTime = formatIntervalTime(
                          init: inBedTime,
                          end: outBedTime,
                          clockTimeFormat: clockTimeFormat,
                          clockIncrementTimeFormat: clockIncrementTimeFormat,
                        );
                      });
                    },
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text(
                        'Cancel',
                        style: TextStyle(color: Color(0xFF3CDAF7)),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text(
                        'OK',
                        style: TextStyle(color: Color(0xFF3CDAF7)),
                      ),
                    ),
                  ],
                );
              },
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1F2633),
            fixedSize: const Size(200, 50),
          ),
          child: const Text(
            'Manual Sleep',
            style: TextStyle(
              color: Color(0xFF3CDAF7),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: _isRecording ? _stopRecording : _startRecording,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1F2633),
            fixedSize: const Size(200, 50),
          ),
          child: Text(
            _isRecording ? 'Stop Recording' : 'Start Recording',
            style: const TextStyle(
              color: Color(0xFF3CDAF7),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: _isSetAlarm ? _cancelAlarm : _setAlarm,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1F2633),
            fixedSize: const Size(200, 50),
          ),
          child: Text(
            _isSetAlarm ? 'Stop Alarm' : 'Set Alarm',
            style: const TextStyle(
              color: Color(0xFF3CDAF7),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  void _updateLabels(PickedTime init, PickedTime end, bool? isDisableRange) {
    inBedTime = init;
    outBedTime = end;
    intervalBedTime = formatIntervalTime(
      init: inBedTime,
      end: outBedTime,
      clockTimeFormat: clockTimeFormat,
      clockIncrementTimeFormat: clockIncrementTimeFormat,
    );
    isSleepGoal = validateSleepGoal(
      inTime: init,
      outTime: end,
      sleepGoal: sleepGoal,
      clockTimeFormat: clockTimeFormat,
      clockIncrementTimeFormat: clockIncrementTimeFormat,
    );
    setState(() {
      validRange = isDisableRange;
    });
  }
}
