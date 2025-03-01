// import 'dart:io';
// import 'dart:ui';
// import 'package:alarm/alarm.dart';
// import 'package:auto_route/auto_route.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:flutter_sound/flutter_sound.dart';
// import 'package:intl/intl.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:progressive_time_picker/progressive_time_picker.dart';
// import 'package:sleep/home/presentation/pages/CustomSliderThumbShape.dart';

// @RoutePage()
// class HomePage extends ConsumerStatefulWidget {
//   const HomePage({super.key});

//   @override
//   ConsumerState<HomePage> createState() => _HomePageState();
// }

// class _HomePageState extends ConsumerState<HomePage>
//     with TickerProviderStateMixin {
//   // // Core functionality variables
//   final String _fileExtension = '.aac';
//   final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
//   final FlutterSoundPlayer _player = FlutterSoundPlayer();
//   bool _isRecording = false;
//   String? _filePath;
//   bool _isSetAlarm = false;

//   // Time picker configuration
//   ClockTimeFormat clockTimeFormat = ClockTimeFormat.twentyFourHours;
//   ClockIncrementTimeFormat clockIncrementTimeFormat =
//       ClockIncrementTimeFormat.fiveMin;

//   // Sleep time variables
//   PickedTime inBedTime = PickedTime(h: 23, m: 0);
//   PickedTime outBedTime = PickedTime(h: 7, m: 0);
//   PickedTime intervalBedTime = PickedTime(h: 8, m: 0);
//   double sleepGoal = 8;
//   bool isSleepGoal = false;
//   bool? validRange = true;

//   // Sleep quality tracking
//   int _sleepQuality = 5; // 1-10 scale
//   List<String> _sleepNotes = [];

//   // UI colors - Enhanced modern color palette
//   final Color _primaryColor = const Color(0xFF6366F1); // Modern indigo
//   final Color _darkBackgroundColor =
//       const Color(0xFF0F1120); // Near black with a hint of blue
//   final Color _cardColor = const Color(0xFF1A1D2E); // Dark blue-gray
//   final Color _accentColor = const Color(0xFF22C55E); // Vibrant green
//   final Color _secondaryAccent = const Color(0xFFEF4444); // Vibrant red
//   final Color _tertiaryAccent = const Color(0xFFF59E0B); // Vibrant amber
//   final Color _quaternaryAccent = const Color(0xFF3B82F6); // Bright blue

//   // Animation controllers
//   late AnimationController _qualityAnimationController;
//   late AnimationController _cardAnimationController;
//   late TabController _tabController;

//   // @override
//   // void initState() {
//   //   super.initState();

//   //   // Properly initialize recorder first
//   //   _initializeRecorder();
//   //   _initializePlayer();
//   //   _initializeAlarm();

//   //   // Create animation controllers with proper initialization
//   //   _qualityAnimationController = AnimationController(
//   //     vsync: this,
//   //     duration: const Duration(milliseconds: 300),
//   //   );

//   //   _cardAnimationController = AnimationController(
//   //     vsync: this,
//   //     duration: const Duration(milliseconds: 600),
//   //   );

//   //   _tabController = TabController(length: 3, vsync: this);

//   //   // Initialize default interval time
//   //   intervalBedTime = formatIntervalTime(
//   //     init: inBedTime,
//   //     end: outBedTime,
//   //     clockTimeFormat: clockTimeFormat,
//   //     clockIncrementTimeFormat: clockIncrementTimeFormat,
//   //   );

//   //   // Start animation after build completed
//   //   WidgetsBinding.instance.addPostFrameCallback((_) {
//   //     if (mounted) {
//   //       _cardAnimationController.forward();
//   //     }
//   //   });
//   // }

//   // // Your existing functionality methods
//   // Future<void> _initializeAlarm() async {
//   //   await Alarm.init();
//   // }

//   // Future<bool> _fileExists(String filePath) async {
//   //   final file = File(filePath);
//   //   return file.exists();
//   // }

//   // Future<void> _initializeRecorder() async {
//   //   try {
//   //     final status = await Permission.microphone.request();
//   //     if (status.isGranted) {
//   //       await _recorder.openRecorder();
//   //     } else {
//   //       throw Exception('Microphone permission not granted');
//   //     }
//   //   } catch (e) {
//   //     debugPrint('Recorder initialization failed: $e');
//   //   }
//   // }

//   // Future<void> _initializePlayer() async {
//   //   try {
//   //     await _player.openPlayer();
//   //   } catch (e) {
//   //     debugPrint('Player initialization failed: $e');
//   //   }
//   // }

//   // Future<void> _startRecording() async {
//   //   try {
//   //     _filePath =
//   //         '${Directory.systemTemp.path}/sleep_recording_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.aac';
//   //     await _recorder.startRecorder(
//   //       toFile: _filePath,
//   //       codec: Codec.aacADTS,
//   //       sampleRate: 44100,
//   //       bitRate: 128000,
//   //     );
//   //     setState(() {
//   //       _isRecording = true;
//   //     });

//   //     // Show recording indicator
//   //     _showSnackBar('Recording sleep sounds...', _secondaryAccent);
//   //   } catch (e) {
//   //     debugPrint('Error starting recording: $e');
//   //   }
//   // }

//   // Future<void> _stopRecording() async {
//   //   try {
//   //     await _recorder.stopRecorder();
//   //     setState(() {
//   //       _isRecording = false;
//   //     });

//   //     if (_filePath != null) {
//   //       final exists = await _fileExists(_filePath!);
//   //       if (exists) {
//   //         final directory = await getApplicationDocumentsDirectory();
//   //         final newFileName =
//   //             '${directory.path}/sleep_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}$_fileExtension';
//   //         final newFile = await File(_filePath!).copy(newFileName);

//   //         setState(() {
//   //           _sleepNotes.add(
//   //               'Recording saved: ${DateFormat('MMM dd, HH:mm').format(DateTime.now())}');
//   //         });

//   //         _showSnackBar('Recording saved successfully', _accentColor);
//   //         debugPrint('Recording saved successfully at ${newFile.path}');
//   //       } else {
//   //         debugPrint('Recording file not found at $_filePath');
//   //       }
//   //     }
//   //   } catch (e) {
//   //     debugPrint('Error stopping recording: $e');
//   //   }
//   // }

//   // void _setAlarm() {
//   //   final now = DateTime.now();
//   //   var alarmTime = DateTime(
//   //     now.year,
//   //     now.month,
//   //     now.day,
//   //     outBedTime.h,
//   //     outBedTime.m,
//   //   );
//   //   final bedTime = DateTime(
//   //     now.year,
//   //     now.month,
//   //     now.day,
//   //     inBedTime.h,
//   //     inBedTime.m,
//   //   );

//   //   // If the alarm time is in the past, set it for the next day
//   //   if (alarmTime.isBefore(now) || bedTime.isAtSameMomentAs(now)) {
//   //     alarmTime = alarmTime.add(const Duration(days: 1));
//   //   }

//   //   final alarmSettings = AlarmSettings(
//   //     id: 42,
//   //     dateTime: alarmTime,
//   //     assetAudioPath: 'assets/alarm.mp3',
//   //     volume: 1,
//   //     fadeDuration: 3,
//   //     warningNotificationOnKill: Platform.isIOS,
//   //     notificationSettings: NotificationSettings(
//   //       title: 'Time to Wake Up',
//   //       body: 'Rise and shine! It\'s ${DateFormat('HH:mm').format(alarmTime)}',
//   //       stopButton: 'Stop Alarm',
//   //       icon: 'notification_icon',
//   //     ),
//   //   );

//   //   Alarm.set(alarmSettings: alarmSettings).then((_) {
//   //     setState(() {
//   //       _isSetAlarm = true;
//   //     });

//   //     _showSnackBar('Alarm set for ${DateFormat('HH:mm').format(alarmTime)}',
//   //         _accentColor);
//   //     debugPrint('Alarm set successfully');
//   //   });
//   // }

//   // Future<void> _cancelAlarm() async {
//   //   await Alarm.stop(42);
//   //   setState(() {
//   //     _isSetAlarm = false;
//   //   });

//   //   _showSnackBar('Alarm canceled', _secondaryAccent);
//   //   debugPrint('Alarm canceled');
//   // }

//   // void _showSnackBar(String message, Color backgroundColor) {
//   //   ScaffoldMessenger.of(context).showSnackBar(
//   //     SnackBar(
//   //       content:
//   //           Text(message, style: const TextStyle(fontWeight: FontWeight.w500)),
//   //       backgroundColor: backgroundColor,
//   //       behavior: SnackBarBehavior.floating,
//   //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//   //       margin: const EdgeInsets.all(8),
//   //       duration: const Duration(seconds: 3),
//   //       elevation: 8,
//   //     ),
//   //   );
//   // }

//   // @override
//   // void dispose() {
//   //   _recorder.closeRecorder();
//   //   _player.closePlayer();
//   //   _qualityAnimationController.dispose();
//   //   _cardAnimationController.dispose();
//   //   _tabController.dispose();
//   //   super.dispose();
//   // }

//   @override
//   Widget build(BuildContext context) {
//     return SafeArea(
//       child: Scaffold(
//         backgroundColor: _darkBackgroundColor,
//         // body: CustomScrollView(
//         //   physics: const BouncingScrollPhysics(),
//         //   slivers: [
//         //     // SliverToBoxAdapter(
//         //     //   child: _buildContent(),
//         //     // ),
//         //   ],
//         // ),
//         // floatingActionButton: _buildFloatingActionButton(),
//         // floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
//       ),
//     );
//   }

//   // Widget _buildFloatingActionButton() {
//   //   return FloatingActionButton.extended(
//   //     onPressed: _isSetAlarm ? _cancelAlarm : _setAlarm,
//   //     backgroundColor: _isSetAlarm ? _secondaryAccent : _accentColor,
//   //     foregroundColor: Colors.white,
//   //     elevation: 8,
//   //     icon: Icon(_isSetAlarm ? Icons.alarm_off : Icons.alarm),
//   //     label: Text(_isSetAlarm ? 'Cancel Alarm' : 'Set Alarm'),
//   //   );
//   // }

//   Widget _buildAppBar() {
//     return SliverAppBar(
//       expandedHeight: 140.0,
//       floating: false,
//       pinned: true,
//       backgroundColor: _darkBackgroundColor,
//       elevation: 0,
//       flexibleSpace: FlexibleSpaceBar(
//         titlePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
//         title: Row(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Icon(
//               Icons.nights_stay,
//               color: _primaryColor,
//               size: 20,
//             ),
//             const SizedBox(width: 8),
//             const Text(
//               'Sleep Tracker',
//               style: TextStyle(
//                 color: Colors.white,
//                 fontSize: 18,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ],
//         ),
//         background: Stack(
//           fit: StackFit.expand,
//           children: [
//             // Gradient background
//             Container(
//               decoration: BoxDecoration(
//                 gradient: LinearGradient(
//                   begin: Alignment.topLeft,
//                   end: Alignment.bottomRight,
//                   colors: [
//                     _primaryColor.withOpacity(0.3),
//                     _darkBackgroundColor,
//                   ],
//                 ),
//               ),
//             ),

//             // Decorative elements
//             Positioned(
//               right: -40,
//               top: -20,
//               child: Container(
//                 width: 150,
//                 height: 150,
//                 decoration: BoxDecoration(
//                   shape: BoxShape.circle,
//                   color: _primaryColor.withOpacity(0.1),
//                 ),
//               ),
//             ),

//             Positioned(
//               left: -30,
//               bottom: 20,
//               child: Container(
//                 width: 100,
//                 height: 100,
//                 decoration: BoxDecoration(
//                   shape: BoxShape.circle,
//                   color: _accentColor.withOpacity(0.05),
//                 ),
//               ),
//             ),

//             // Moon and stars decoration
//             Positioned(
//               right: 40,
//               top: 60,
//               child: Icon(
//                 Icons.star,
//                 color: Colors.white.withOpacity(0.2),
//                 size: 16,
//               ),
//             ),

//             Positioned(
//               right: 80,
//               top: 40,
//               child: Icon(
//                 Icons.star,
//                 color: Colors.white.withOpacity(0.15),
//                 size: 12,
//               ),
//             ),

//             Positioned(
//               right: 120,
//               top: 70,
//               child: Icon(
//                 Icons.star,
//                 color: Colors.white.withOpacity(0.1),
//                 size: 14,
//               ),
//             ),

//             // Date display
//             Positioned(
//               bottom: 60,
//               left: 20,
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     DateFormat('EEEE').format(DateTime.now()),
//                     style: TextStyle(
//                       color: Colors.white.withOpacity(0.6),
//                       fontSize: 14,
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ),
//                   Text(
//                     DateFormat('MMMM d, yyyy').format(DateTime.now()),
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontSize: 16,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//       actions: [
//         IconButton(
//           icon: Icon(Icons.calendar_month, color: Colors.white),
//           onPressed: () {},
//         ),
//         IconButton(
//           icon: Icon(Icons.settings, color: Colors.white),
//           onPressed: () {},
//         ),
//       ],
//     );
//   }

//   Widget _buildContent() {
//     return SingleChildScrollView(
//       physics: const BouncingScrollPhysics(),
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           children: [
//             // _buildAnimatedCard(_buildSleepSummaryCard(), 0),
//             // const SizedBox(height: 20),
//             // _buildAnimatedCard(_buildSleepScheduleCard(), 1),
//             // const SizedBox(height: 20),
//             // _buildAnimatedCard(_buildQuickActionsCard(), 2),
//             // const SizedBox(height: 20),
//             // _buildAnimatedCard(_buildSleepQualityCard(), 3),
//             // const SizedBox(height: 80), // Extra space for fab
//           ],
//         ),
//       ),
//     );
//   }

//   // Widget _buildAnimatedCard(Widget child, int index) {
//   //   final delay = index * 0.15;
//   //   final animation = CurvedAnimation(
//   //     parent: _cardAnimationController,
//   //     curve: Interval(
//   //       delay,
//   //       delay + 0.5,
//   //       curve: Curves.easeOutCubic,
//   //     ),
//   //   );

//   //   return FadeTransition(
//   //     opacity: animation,
//   //     child: SlideTransition(
//   //       position: Tween<Offset>(
//   //         begin: const Offset(0, 0.05),
//   //         end: Offset.zero,
//   //       ).animate(animation),
//   //       child: child,
//   //     ),
//   //   );
//   // }

//   Widget _buildSleepSummaryCard() {
//     return Container(
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//           colors: [
//             _primaryColor.withOpacity(0.8),
//             _primaryColor.withOpacity(0.6),
//           ],
//         ),
//         borderRadius: BorderRadius.circular(24),
//         boxShadow: [
//           BoxShadow(
//             color: _primaryColor.withOpacity(0.25),
//             blurRadius: 16,
//             offset: const Offset(0, 8),
//           ),
//         ],
//       ),
//       child: ClipRRect(
//         borderRadius: BorderRadius.circular(24),
//         child: BackdropFilter(
//           filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
//           child: Padding(
//             padding: const EdgeInsets.all(24.0),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           'Tonight\'s Sleep',
//                           style: TextStyle(
//                             color: Colors.white,
//                             fontSize: 22,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                         const SizedBox(height: 4),
//                         Text(
//                           DateFormat('EEEE, dd MMMM').format(DateTime.now()),
//                           style: TextStyle(
//                             color: Colors.white.withOpacity(0.8),
//                             fontSize: 14,
//                           ),
//                         ),
//                       ],
//                     ),
//                     // GestureDetector(
//                     //   onTap: _isSetAlarm ? _cancelAlarm : _setAlarm,
//                     //   child: Container(
//                     //     padding: const EdgeInsets.symmetric(
//                     //         horizontal: 16, vertical: 8),
//                     //     decoration: BoxDecoration(
//                     //       color: _isSetAlarm
//                     //           ? Colors.white.withOpacity(0.25)
//                     //           : Colors.white.withOpacity(0.15),
//                     //       borderRadius: BorderRadius.circular(20),
//                     //     ),
//                     //     child: Row(
//                     //       children: [
//                     //         Icon(
//                     //           _isSetAlarm ? Icons.alarm : Icons.alarm_off,
//                     //           color: Colors.white,
//                     //           size: 18,
//                     //         ),
//                     //         const SizedBox(width: 6),
//                     //         Text(
//                     //           _isSetAlarm
//                     //               ? '${NumberFormat('00').format(outBedTime.h)}:${NumberFormat('00').format(outBedTime.m)}'
//                     //               : 'No Alarm',
//                     //           style: TextStyle(
//                     //             color: Colors.white,
//                     //             fontSize: 14,
//                     //             fontWeight: FontWeight.w500,
//                     //           ),
//                     //         ),
//                     //       ],
//                     //     ),
//                     //   ),
//                     // ),
//                   ],
//                 ),
//                 const SizedBox(height: 24),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                   children: [
//                     _buildSummaryItem(
//                       "Bedtime",
//                       "${NumberFormat('00').format(inBedTime.h)}:${NumberFormat('00').format(inBedTime.m)}",
//                       Icons.nightlight_outlined,
//                     ),
//                     Container(
//                       height: 50,
//                       width: 1,
//                       color: Colors.white.withOpacity(0.2),
//                     ),
//                     _buildSummaryItem(
//                       "Wake Up",
//                       "${NumberFormat('00').format(outBedTime.h)}:${NumberFormat('00').format(outBedTime.m)}",
//                       Icons.wb_sunny_outlined,
//                     ),
//                     Container(
//                       height: 50,
//                       width: 1,
//                       color: Colors.white.withOpacity(0.2),
//                     ),
//                     _buildSummaryItem(
//                       "Duration",
//                       "${NumberFormat('00').format(intervalBedTime.h)}h ${NumberFormat('00').format(intervalBedTime.m)}m",
//                       Icons.timelapse_outlined,
//                       highlight: isSleepGoal,
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildSummaryItem(String title, String value, IconData icon,
//       {bool highlight = false}) {
//     return Column(
//       children: [
//         Container(
//           padding: const EdgeInsets.all(10),
//           decoration: BoxDecoration(
//             color: highlight
//                 ? Colors.white.withOpacity(0.25)
//                 : Colors.white.withOpacity(0.15),
//             shape: BoxShape.circle,
//           ),
//           child: Icon(icon, color: Colors.white, size: 22),
//         ),
//         const SizedBox(height: 10),
//         Text(
//           value,
//           style: TextStyle(
//             color: Colors.white,
//             fontSize: 18,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         const SizedBox(height: 4),
//         Text(
//           title,
//           style: TextStyle(
//             color: Colors.white.withOpacity(0.8),
//             fontSize: 12,
//           ),
//         ),
//         if (highlight && title == "Duration")
//           Container(
//             margin: const EdgeInsets.only(top: 6),
//             padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
//             decoration: BoxDecoration(
//               color: Colors.white.withOpacity(0.3),
//               borderRadius: BorderRadius.circular(10),
//             ),
//             child: Text(
//               "Goal ✓",
//               style: TextStyle(
//                 color: Colors.white,
//                 fontSize: 10,
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//           ),
//       ],
//     );
//   }

//   Widget _buildSleepScheduleCard() {
//     return Card(
//       color: _cardColor,
//       elevation: 10,
//       shadowColor: Colors.black26,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
//       child: Padding(
//         padding: const EdgeInsets.all(20.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Row(
//                   children: [
//                     Container(
//                       padding: const EdgeInsets.all(8),
//                       decoration: BoxDecoration(
//                         color: _quaternaryAccent.withOpacity(0.1),
//                         shape: BoxShape.circle,
//                       ),
//                       child: Icon(
//                         Icons.schedule,
//                         color: _quaternaryAccent,
//                         size: 20,
//                       ),
//                     ),
//                     const SizedBox(width: 12),
//                     Text(
//                       'Sleep Schedule',
//                       style: TextStyle(
//                         color: Colors.white,
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ],
//                 ),
//                 IconButton(
//                   icon: Icon(Icons.edit_outlined, color: Colors.white70),
//                   onPressed: () {},
//                 ),
//               ],
//             ),
//             const SizedBox(height: 20),
//             SizedBox(
//               height: MediaQuery.of(context).size.height * 0.28,
//               child: Stack(
//                 children: [
//                   // Decorated background for the clock
//                   Positioned.fill(
//                     child: Container(
//                       margin: const EdgeInsets.all(15),
//                       decoration: BoxDecoration(
//                         shape: BoxShape.circle,
//                         gradient: LinearGradient(
//                           begin: Alignment.topLeft,
//                           end: Alignment.bottomRight,
//                           colors: [
//                             _darkBackgroundColor.withOpacity(0.8),
//                             _darkBackgroundColor,
//                           ],
//                         ),
//                         boxShadow: [
//                           BoxShadow(
//                             color: _primaryColor.withOpacity(0.05),
//                             blurRadius: 20,
//                             spreadRadius: 5,
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),

//                   // The time picker
//                   // TimePicker(
//                   //   initTime: inBedTime,
//                   //   endTime: outBedTime,
//                   //   disabledRanges: const [],
//                   //   height: MediaQuery.of(context).size.height * 0.28,
//                   //   width: MediaQuery.of(context).size.height * 0.28,
//                   //   onSelectionChange: _updateLabels,
//                   //   primarySectors: clockTimeFormat.value,
//                   //   secondarySectors: clockTimeFormat.value * 2,
//                   //   decoration: TimePickerDecoration(
//                   //     baseColor: Colors.transparent,
//                   //     pickerBaseCirclePadding: 15,
//                   //     sweepDecoration: TimePickerSweepDecoration(
//                   //       pickerStrokeWidth: 30,
//                   //       pickerColor: isSleepGoal ? _accentColor : _primaryColor,
//                   //       showConnector: true,
//                   //       connectorColor:
//                   //           isSleepGoal ? _accentColor : _primaryColor,
//                   //     ),
//                   //     initHandlerDecoration: TimePickerHandlerDecoration(
//                   //       radius: 14,
//                   //       color: _darkBackgroundColor,
//                   //       icon: Icon(
//                   //         Icons.nightlight_outlined,
//                   //         size: 16,
//                   //         color: isSleepGoal ? _accentColor : _primaryColor,
//                   //       ),
//                   //     ),
//                   //     endHandlerDecoration: TimePickerHandlerDecoration(
//                   //       color: _darkBackgroundColor,
//                   //       radius: 14,
//                   //       icon: Icon(
//                   //         Icons.wb_sunny_outlined,
//                   //         size: 16,
//                   //         color: isSleepGoal ? _accentColor : _primaryColor,
//                   //       ),
//                   //     ),
//                   //     primarySectorsDecoration: TimePickerSectorDecoration(
//                   //       color: Colors.white38,
//                   //       width: 1,
//                   //       size: 4,
//                   //       radiusPadding: 25,
//                   //     ),
//                   //     secondarySectorsDecoration: TimePickerSectorDecoration(
//                   //       color: Colors.white24,
//                   //       width: 1,
//                   //       size: 2,
//                   //       radiusPadding: 25,
//                   //     ),
//                   //     clockNumberDecoration: TimePickerClockNumberDecoration(
//                   //       defaultTextColor: Colors.white70,
//                   //       defaultFontSize: 12,
//                   //       scaleFactor: 2,
//                   //       clockTimeFormat: clockTimeFormat,
//                   //       clockIncrementTimeFormat: clockIncrementTimeFormat,
//                   //     ),
//                   //   ),
//                   //   onSelectionEnd: (PickedTime a, PickedTime b, bool? valid) {
//                   //     setState(() {
//                   //       inBedTime = a;
//                   //       outBedTime = b;
//                   //       intervalBedTime = formatIntervalTime(
//                   //         init: inBedTime,
//                   //         end: outBedTime,
//                   //         clockTimeFormat: clockTimeFormat,
//                   //         clockIncrementTimeFormat: clockIncrementTimeFormat,
//                   //       );
//                   //       isSleepGoal = validateSleepGoal(
//                   //         inTime: inBedTime,
//                   //         outTime: outBedTime,
//                   //         sleepGoal: sleepGoal,
//                   //         clockTimeFormat: clockTimeFormat,
//                   //         clockIncrementTimeFormat: clockIncrementTimeFormat,
//                   //       );
//                   //     });
//                   //   },
//                   //   child: Center(
//                   //     child: Container(
//                   //       padding: const EdgeInsets.all(16),
//                   //       decoration: BoxDecoration(
//                   //         color: _cardColor,
//                   //         shape: BoxShape.circle,
//                   //         boxShadow: [
//                   //           BoxShadow(
//                   //             color: Colors.black12,
//                   //             blurRadius: 8,
//                   //             offset: const Offset(0, 2),
//                   //           ),
//                   //         ],
//                   //       ),
//                   //       child: Column(
//                   //         mainAxisSize: MainAxisSize.min,
//                   //         mainAxisAlignment: MainAxisAlignment.center,
//                   //         children: [
//                   //           Text(
//                   //             '${NumberFormat('00').format(intervalBedTime.h)}h ${NumberFormat('00').format(intervalBedTime.m)}m',
//                   //             style: TextStyle(
//                   //               fontSize: 20,
//                   //               color:
//                   //                   isSleepGoal ? _accentColor : Colors.white,
//                   //               fontWeight: FontWeight.bold,
//                   //             ),
//                   //           ),
//                   //           if (isSleepGoal)
//                   //             Container(
//                   //               margin: const EdgeInsets.only(top: 4),
//                   //               padding: const EdgeInsets.symmetric(
//                   //                   horizontal: 6, vertical: 2),
//                   //               decoration: BoxDecoration(
//                   //                 color: _accentColor.withOpacity(0.1),
//                   //                 borderRadius: BorderRadius.circular(8),
//                   //               ),
//                   //               child: Text(
//                   //                 'Goal Reached',
//                   //                 style: TextStyle(
//                   //                   fontSize: 10,
//                   //                   color: _accentColor,
//                   //                   fontWeight: FontWeight.w500,
//                   //                 ),
//                   //               ),
//                   //             ),
//                   //         ],
//                   //       ),
//                   //     ),
//                   //   ),
//                   // ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildQuickActionsCard() {
//     return Container(
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//           colors: [
//             _cardColor,
//             Color.lerp(_cardColor, Colors.black, 0.1)!,
//           ],
//         ),
//         borderRadius: BorderRadius.circular(24),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.2),
//             blurRadius: 15,
//             offset: const Offset(0, 8),
//           ),
//         ],
//       ),
//       child: ClipRRect(
//         borderRadius: BorderRadius.circular(24),
//         child: BackdropFilter(
//           filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
//           child: Padding(
//             padding: const EdgeInsets.all(24.0),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Row(
//                       children: [
//                         // Title with animated icon
//                         Container(
//                           padding: const EdgeInsets.all(10),
//                           decoration: BoxDecoration(
//                             color: _tertiaryAccent.withOpacity(0.15),
//                             borderRadius: BorderRadius.circular(16),
//                             boxShadow: [
//                               BoxShadow(
//                                 color: _tertiaryAccent.withOpacity(0.2),
//                                 blurRadius: 8,
//                                 offset: const Offset(0, 2),
//                               ),
//                             ],
//                           ),
//                           child: Icon(
//                             Icons.flash_on,
//                             color: _tertiaryAccent,
//                             size: 20,
//                           ),
//                         ),
//                         const SizedBox(width: 16),
//                         Text(
//                           'Quick Actions',
//                           style: TextStyle(
//                             color: Colors.white,
//                             fontSize: 20,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ],
//                     ),
//                     // Help icon with tooltip
//                     IconButton(
//                       icon: Icon(Icons.help_outline,
//                           color: Colors.white.withOpacity(0.6), size: 20),
//                       onPressed: () {
//                         // Show tooltip or help dialog
//                       },
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 24),

//                 // Grid of action buttons
//                 // GridView.count(
//                 //   crossAxisCount: 2,
//                 //   shrinkWrap: true,
//                 //   physics: const NeverScrollableScrollPhysics(),
//                 //   mainAxisSpacing: 16,
//                 //   crossAxisSpacing: 16,
//                 //   childAspectRatio: 1.5,
//                 //   children: [
//                 //     _buildModernActionItem(
//                 //       label: _isRecording ? 'Stop Recording' : 'Record Sleep',
//                 //       icon: _isRecording ? Icons.stop_circle : Icons.mic,
//                 //       color: _isRecording ? _secondaryAccent : _primaryColor,
//                 //       description: 'Capture sleep sounds',
//                 //       onTap: _isRecording ? _stopRecording : _startRecording,
//                 //     ),
//                 //     _buildModernActionItem(
//                 //       label: 'Start Sleep Now',
//                 //       icon: Icons.bedtime,
//                 //       color: _accentColor,
//                 //       description: 'Begin tracking now',
//                 //       onTap: () {
//                 //         setState(() {
//                 //           inBedTime = PickedTime(
//                 //             h: DateTime.now().hour,
//                 //             m: DateTime.now().minute,
//                 //           );
//                 //           intervalBedTime = formatIntervalTime(
//                 //             init: inBedTime,
//                 //             end: outBedTime,
//                 //             clockTimeFormat: clockTimeFormat,
//                 //             clockIncrementTimeFormat: clockIncrementTimeFormat,
//                 //           );
//                 //         });
//                 //         _showSnackBar('Sleep time set to now', _accentColor);
//                 //       },
//                 //     ),
//                 //     _buildModernActionItem(
//                 //       label: 'Relaxing Sounds',
//                 //       icon: Icons.spa,
//                 //       color: _quaternaryAccent,
//                 //       description: 'Play sleep music',
//                 //       onTap: () {
//                 //         // Play relaxing sounds
//                 //       },
//                 //     ),
//                 //     _buildModernActionItem(
//                 //       label: 'Sleep Notes',
//                 //       icon: Icons.note_add,
//                 //       color: _tertiaryAccent,
//                 //       description: 'Add observations',
//                 //       onTap: () {
//                 //         // Add notes
//                 //       },
//                 //     ),
//                 //   ],
//                 // ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildModernActionItem({
//     required String label,
//     required IconData icon,
//     required Color color,
//     required String description,
//     required VoidCallback onTap,
//   }) {
//     return InkWell(
//       onTap: onTap,
//       borderRadius: BorderRadius.circular(20),
//       child: Container(
//         decoration: BoxDecoration(
//           color: color.withOpacity(0.1),
//           borderRadius: BorderRadius.circular(20),
//           border: Border.all(color: color.withOpacity(0.3), width: 1),
//           boxShadow: [
//             BoxShadow(
//               color: color.withOpacity(0.1),
//               blurRadius: 10,
//               offset: const Offset(0, 4),
//             ),
//           ],
//         ),
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Row(
//               children: [
//                 Container(
//                   padding: const EdgeInsets.all(8),
//                   decoration: BoxDecoration(
//                     color: color.withOpacity(0.2),
//                     shape: BoxShape.circle,
//                   ),
//                   child: Icon(
//                     icon,
//                     color: color,
//                     size: 20,
//                   ),
//                 ),
//                 const Spacer(),
//                 Icon(
//                   Icons.arrow_forward_ios,
//                   color: color.withOpacity(0.5),
//                   size: 14,
//                 ),
//               ],
//             ),
//             const SizedBox(height: 12),
//             Text(
//               label,
//               style: const TextStyle(
//                 color: Colors.white,
//                 fontSize: 14,
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//             const SizedBox(height: 4),
//             Text(
//               description,
//               style: TextStyle(
//                 color: Colors.white.withOpacity(0.5),
//                 fontSize: 12,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   void _updateLabels(PickedTime init, PickedTime end, bool? isValid) {
//     // Don't update state during dragging to avoid excessive rebuilds
//     // Just update the temporary values
//     inBedTime = init;
//     outBedTime = end;
//     validRange = isValid;

//     // Calculate the time interval between bed time and wake time
//     intervalBedTime = formatIntervalTime(
//       init: init,
//       end: end,
//       clockTimeFormat: clockTimeFormat,
//       clockIncrementTimeFormat: clockIncrementTimeFormat,
//     );

//     // Check if the sleep duration meets the goal
//     isSleepGoal = validateSleepGoal(
//       inTime: init,
//       outTime: end,
//       sleepGoal: sleepGoal,
//       clockTimeFormat: clockTimeFormat,
//       clockIncrementTimeFormat: clockIncrementTimeFormat,
//     );
//   }

//   Widget _buildSleepQualityCard() {
//     return Card(
//       color: _cardColor,
//       elevation: 8,
//       shadowColor: Colors.black.withOpacity(0.3),
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
//       child: Padding(
//         padding: const EdgeInsets.all(24.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               children: [
//                 Container(
//                   padding: const EdgeInsets.all(10),
//                   decoration: BoxDecoration(
//                     color: _primaryColor.withOpacity(0.1),
//                     borderRadius: BorderRadius.circular(14),
//                   ),
//                   child: Icon(
//                     Icons.sentiment_satisfied_alt,
//                     color: _primaryColor,
//                     size: 22,
//                   ),
//                 ),
//                 const SizedBox(width: 12),
//                 Text(
//                   'Sleep Quality',
//                   style: TextStyle(
//                     color: Colors.white,
//                     fontSize: 20,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 const Spacer(),
//                 Container(
//                   padding:
//                       const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                   decoration: BoxDecoration(
//                     color: _getQualityColor().withOpacity(0.1),
//                     borderRadius: BorderRadius.circular(20),
//                   ),
//                   child: Text(
//                     _getQualityText(),
//                     style: TextStyle(
//                       color: _getQualityColor(),
//                       fontSize: 12,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 24),

//             // Quality slider with animated icons
//             SliderTheme(
//               data: SliderThemeData(
//                 trackHeight: 8,
//                 activeTrackColor: _getQualityColor(),
//                 inactiveTrackColor: Colors.grey.shade800,
//                 thumbColor: _getQualityColor(),
//                 thumbShape: CustomSliderThumbShape(
//                   thumbRadius: 16,
//                   quality: _sleepQuality,
//                 ),
//                 overlayColor: _getQualityColor().withOpacity(0.2),
//                 overlayShape: RoundSliderOverlayShape(overlayRadius: 24),
//               ),
//               child: AnimatedBuilder(
//                 animation: _qualityAnimationController,
//                 builder: (context, child) {
//                   return Slider(
//                     value: _sleepQuality.toDouble(),
//                     min: 1,
//                     max: 10,
//                     divisions: 9,
//                     onChanged: (value) {
//                       setState(() {
//                         _sleepQuality = value.toInt();
//                       });
//                       _qualityAnimationController.forward(from: 0.0);
//                     },
//                   );
//                 },
//               ),
//             ),

//             // Quality levels indicators
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 12),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Text(
//                     'Poor',
//                     style: TextStyle(
//                       color: Colors.white.withOpacity(0.5),
//                       fontSize: 12,
//                     ),
//                   ),
//                   Text(
//                     'Good',
//                     style: TextStyle(
//                       color: Colors.white.withOpacity(0.5),
//                       fontSize: 12,
//                     ),
//                   ),
//                   Text(
//                     'Excellent',
//                     style: TextStyle(
//                       color: Colors.white.withOpacity(0.5),
//                       fontSize: 12,
//                     ),
//                   ),
//                 ],
//               ),
//             ),

//             const SizedBox(height: 24),

//             // Quality categories
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//               children: [
//                 _buildQualityCategory(
//                   'Deep Sleep',
//                   '${(_sleepQuality * 0.1).toStringAsFixed(1)}h',
//                   Icons.nights_stay,
//                   _primaryColor,
//                   _sleepQuality >= 5,
//                 ),
//                 _buildQualityCategory(
//                   'REM Sleep',
//                   '${(_sleepQuality * 0.2).toStringAsFixed(1)}h',
//                   Icons.remove_red_eye,
//                   _quaternaryAccent,
//                   _sleepQuality >= 7,
//                 ),
//                 _buildQualityCategory(
//                   'Awake Time',
//                   '${(11 - _sleepQuality) * 10}min',
//                   Icons.access_time,
//                   _tertiaryAccent,
//                   _sleepQuality >= 6,
//                 ),
//               ],
//             ),

//             const SizedBox(height: 20),

//             // Improvement suggestions based on quality
//             if (_sleepQuality < 5)
//               _buildSleepTip(
//                 'Try to maintain a consistent sleep schedule',
//                 _secondaryAccent,
//               )
//             else if (_sleepQuality < 8)
//               _buildSleepTip(
//                 'Consider avoiding screens one hour before bed',
//                 _tertiaryAccent,
//               )
//             else
//               _buildSleepTip(
//                 'Great sleep! Keep maintaining this routine',
//                 _accentColor,
//               ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildQualityCategory(
//     String title,
//     String value,
//     IconData icon,
//     Color color,
//     bool isGood,
//   ) {
//     return Column(
//       children: [
//         Container(
//           padding: const EdgeInsets.all(10),
//           decoration: BoxDecoration(
//             color: color.withOpacity(isGood ? 0.2 : 0.1),
//             shape: BoxShape.circle,
//             border: Border.all(
//               color: isGood ? color.withOpacity(0.5) : color.withOpacity(0.2),
//               width: 2,
//             ),
//           ),
//           child: Icon(icon, color: color, size: 20),
//         ),
//         const SizedBox(height: 8),
//         Text(
//           value,
//           style: TextStyle(
//             color: Colors.white,
//             fontSize: 16,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         const SizedBox(height: 4),
//         Text(
//           title,
//           style: TextStyle(
//             color: Colors.white.withOpacity(0.7),
//             fontSize: 12,
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildSleepTip(String tip, Color color) {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: color.withOpacity(0.05),
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(color: color.withOpacity(0.2)),
//       ),
//       child: Row(
//         children: [
//           Icon(Icons.tips_and_updates, color: color),
//           const SizedBox(width: 12),
//           Expanded(
//             child: Text(
//               tip,
//               style: TextStyle(
//                 color: Colors.white.withOpacity(0.9),
//                 fontSize: 13,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

// // Get color based on quality level
//   Color _getQualityColor() {
//     if (_sleepQuality <= 3) return _secondaryAccent;
//     if (_sleepQuality <= 6) return _tertiaryAccent;
//     return _accentColor;
//   }

// // Get quality description text
//   String _getQualityText() {
//     if (_sleepQuality <= 3) return 'Poor';
//     if (_sleepQuality <= 5) return 'Fair';
//     if (_sleepQuality <= 7) return 'Good';
//     if (_sleepQuality <= 9) return 'Very Good';
//     return 'Excellent';
//   }
// }
