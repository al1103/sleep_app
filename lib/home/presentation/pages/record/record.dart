import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

@RoutePage()
class RecordPage extends StatefulWidget {
  const RecordPage({super.key});

  @override
  State<RecordPage> createState() => RecordPageState();
}

enum SoundCategory {
  light, // 30-40 dB
  medium, // 40-50 dB
  loud // 50-60 dB
}

class SoundRecord {
  SoundRecord({
    required this.filePath,
    required this.timestamp,
    required this.maxDecibel,
    required this.averageDecibel,
    required this.category,
    required this.description,
  });

  factory SoundRecord.fromJson(Map<String, dynamic> json) => SoundRecord(
        filePath: json['filePath'] as String,
        timestamp: json['timestamp'] as String,
        maxDecibel: json['maxDecibel'] as double,
        averageDecibel: json['averageDecibel'] as double,
        category: json['category'] as String,
        description: json['description'] as String,
      );
  final String filePath;
  final String timestamp;
  final double maxDecibel;
  final double averageDecibel;
  final String category;
  final String description;

  Map<String, dynamic> toJson() => {
        'filePath': filePath,
        'timestamp': timestamp,
        'maxDecibel': maxDecibel,
        'averageDecibel': averageDecibel,
        'category': category,
        'description': description,
      };
}

// Add new model class for periodic sound measurements
class SoundMeasurement {
  SoundMeasurement({
    required this.time,
    required this.db,
    required this.event,
  });

  factory SoundMeasurement.fromJson(Map<String, dynamic> json) =>
      SoundMeasurement(
        time: json['time'] as String,
        db: (json['db'] as num).toDouble(),
        event: json['event'] as String,
      );
  final String time;
  final double db;
  final String event;

  Map<String, dynamic> toJson() => {
        'time': time,
        'db': double.parse(db.toStringAsFixed(1)),
        'event': event,
      };
}

class RecordPageState extends State<RecordPage> with WidgetsBindingObserver {
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  final FlutterSoundPlayer _player = FlutterSoundPlayer();
  final Logger _logger = Logger();
  bool _isRecording = false;
  bool _isPlaying = false;
  String? _currentlyPlayingFile;
  final List<String> _abnormalSoundFiles = [];
  bool _isRecorderInitialized = false;
  bool _isPlayerInitialized = false;
  static const double LIGHT_SOUND_THRESHOLD =
      30; // Light sleep talking, movement
  static const double MEDIUM_SOUND_THRESHOLD = 40; // Clear talking, snoring
  static const double LOUD_SOUND_THRESHOLD = 50; // Coughing, laughing, shouting

  // Sound categories

  // Add this to store sound category with the file
  final Map<String, SoundCategory> _soundCategories = {};
  // Variables to monitor sound intensity
  StreamSubscription<RecordingDisposition>? _recorderSubscription;
  double _currentDecibel = 0;
  Timer? _analysisTimer;
  final List<double> _soundBuffer = [];
  static const double ABNORMAL_THRESHOLD = 65;
  static const int BUFFER_DURATION = 5;
  String? _currentRecordingPath;

  // Add new variables for audio visualization
  final List<double> _recentDecibels = [];
  static const int MAX_POINTS = 50; // Number of points to display on graph
  double _maxDecibel = 0;
  double _minDecibel = 160;

  // Add new variable to store metadata
  final List<SoundRecord> _recordMetadata = [];

  // Add new variables
  Timer? _periodicMeasurementTimer;
  final List<SoundMeasurement> _periodicMeasurements = [];
  static const int MEASUREMENT_INTERVAL = 5; // seconds

  // Add these variables to RecordPageState
  final List<SoundMeasurement> _currentSessionMeasurements = [];
  Timer? _measurementTimer;
  static const measurementInterval = Duration(seconds: 5);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeAll();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _recorderSubscription?.cancel();
    _analysisTimer?.cancel();
    _recorder.closeRecorder();
    _player.closePlayer();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      if (!_isRecorderInitialized) {
        _initRecorder();
      }
      if (!_isPlayerInitialized) {
        _initPlayer();
      }
    }
  }

  Future<void> _initializeAll() async {
    try {
      final statuses = await [
        Permission.microphone,
        Permission.storage,
      ].request();

      _logger.i('Permission statuses: $statuses');

      if (statuses[Permission.microphone]!.isGranted) {
        await _initRecorder();
        await _initPlayer();
      } else {
        _logger.e('Microphone permission denied');
        if (mounted) {
          await showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Quyền truy cập'),
              content:
                  const Text('Cần cấp quyền truy cập microphone để ghi âm'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    openAppSettings();
                  },
                  child: const Text('Mở cài đặt'),
                ),
              ],
            ),
          );
        }
      }
    } catch (e) {
      _logger.e('Error during initialization: $e');
    }
  }

  Future<void> _initRecorder() async {
    try {
      _logger.i('Initializing recorder...');

      // Always close and reinitialize when this method is called
      await _recorder.closeRecorder();
      _isRecorderInitialized = false;

      await _recorder.openRecorder();
      await _recorder.setSubscriptionDuration(const Duration(milliseconds: 50));

      _isRecorderInitialized = true;
      _logger.i(
        'Recorder initialized successfully. Status: ${_recorder.isRecording}',
      );
    } catch (e, stackTrace) {
      _logger.e(
        'Error initializing recorder: $e',
        error: e,
        stackTrace: stackTrace,
      );
      _isRecorderInitialized = false;
      rethrow;
    }
  }

  Future<void> _initPlayer() async {
    try {
      await _player.openPlayer();
      await _player.setSubscriptionDuration(const Duration(milliseconds: 100));
      _isPlayerInitialized = true;
    } catch (e) {
      _logger.e('Error initializing player: $e');
      _isPlayerInitialized = false;
    }
  }

  Future<String> _getFilePath() async {
    final directory = await getApplicationDocumentsDirectory();
    final filePath =
        '${directory.path}/record_${DateTime.now().millisecondsSinceEpoch}.wav';
    _logger.i('Generated file path: $filePath');
    return filePath;
  }

  Future<void> _startRecording() async {
    if (!_isRecorderInitialized) {
      _logger.e('Recorder not initialized');
      return;
    }

    try {
      _currentRecordingPath = await _getFilePath();
      _logger.i('Starting recording to: $_currentRecordingPath');

      if (_recorder.isRecording) {
        _logger.i('Recorder is already running, stopping current recording...');
        await _recorder.stopRecorder();
      }

      await _recorder.startRecorder(
        toFile: _currentRecordingPath,
        codec: Codec.pcm16WAV,
        sampleRate: 44100,
      );

      // Thêm delay nhỏ để đảm bảo recorder đã start
      await Future<void>.delayed(const Duration(milliseconds: 100));

      // Update the recorder subscription in _startRecording method
      _recorderSubscription?.cancel();
      _recorderSubscription = _recorder.onProgress!.listen(
        (event) {
          if (event.decibels != null) {
            // Raw decibel values are typically negative, from -160 to 0
            // Convert to positive range 0-100 for better visualization
            final rawDB = event.decibels!;
            // Normalize to 0-100 range
            final normalizedDB =
                ((rawDB + 160) * 100 / 160).clamp(0, 100).toDouble();

            setState(() {
              // Store raw dB value for display
              _currentDecibel = rawDB;

              // Add normalized value to recent decibels for visualization
              _recentDecibels.add(normalizedDB);
              if (_recentDecibels.length > MAX_POINTS) {
                _recentDecibels.removeAt(0);
              }

              // Track min/max of raw values
              if (_maxDecibel == 0 || rawDB > _maxDecibel) {
                _maxDecibel = rawDB;
              }
              if (_minDecibel == 160 || rawDB < _minDecibel) {
                _minDecibel = rawDB;
              }

              _soundBuffer.add(rawDB);
            });
          }
        },
        onError: (error) {
          _logger.e('Recorder subscription error: $error');
        },
        cancelOnError: false,
      );

      // Khởi động timer phân tích âm thanh
      _analysisTimer?.cancel();
      _analysisTimer = Timer.periodic(
        const Duration(seconds: BUFFER_DURATION),
        (timer) => _analyzeSound(),
      );

      // Start periodic measurements
      _startPeriodicMeasurements();

      setState(() {
        _isRecording = true;
        _soundBuffer.clear();
      });

      _logger.i('Recording started successfully');
    } catch (e, stackTrace) {
      _logger.e(
        'Error in startRecording: $e',
        error: e,
        stackTrace: stackTrace,
      );
      setState(() => _isRecording = false);
      rethrow;
    }
  }

  void _analyzeSound() {
    if (_soundBuffer.isEmpty) return;

    final averageDecibel =
        _soundBuffer.reduce((a, b) => a + b) / _soundBuffer.length;
    _logger.i('Average decibel over buffer: $averageDecibel dB');

    // Determine sound category and save if significant
    if (averageDecibel >= LIGHT_SOUND_THRESHOLD) {
      SoundCategory category;

      if (averageDecibel >= LOUD_SOUND_THRESHOLD) {
        category = SoundCategory.loud;
        _logger.i('Loud sound detected: $averageDecibel dB');
      } else if (averageDecibel >= MEDIUM_SOUND_THRESHOLD) {
        category = SoundCategory.medium;
        _logger.i('Medium sound detected: $averageDecibel dB');
      } else {
        category = SoundCategory.light;
        _logger.i('Light sound detected: $averageDecibel dB');
      }

      _saveSignificantSound(category);
    }

    _soundBuffer.clear();
  }

  Future<void> _saveSignificantSound(SoundCategory category) async {
    if (_currentRecordingPath != null) {
      final now = DateTime.now();

      // Create metadata record
      final record = SoundRecord(
        filePath: _currentRecordingPath!,
        timestamp: now.toIso8601String(),
        maxDecibel: _maxDecibel,
        averageDecibel: _soundBuffer.isEmpty
            ? 0.0
            : _soundBuffer.reduce((a, b) => a + b) / _soundBuffer.length,
        category: category.toString().split('.').last,
        description: _getCategoryDescription(category),
      );

      setState(() {
        _abnormalSoundFiles.add(_currentRecordingPath!);
        _soundCategories[_currentRecordingPath!] = category;
        _recordMetadata.add(record);
      });

      await _stopRecording();
      await _startRecording();
    }
  }

  Future<void> _stopRecording() async {
    if (!_isRecording) return;

    try {
      _logger.i('Stopping recording...');
      _recorderSubscription?.cancel();
      _analysisTimer?.cancel();
      _periodicMeasurementTimer?.cancel(); // Add this line

      // Take final measurement before stopping
      _recordMeasurement();

      final path = await _recorder.stopRecorder();
      _logger.i('Recording stopped, file saved at: $path');

      setState(() {
        _isRecording = false;
        _currentDecibel = 0.0;
        _soundBuffer.clear();
      });

      // Save final measurements
      await _saveMeasurements();
    } catch (e) {
      _logger.e('Error stopping recording: $e');
      setState(() {
        _isRecording = false;
      });
    }
  }

  Future<void> _playSound(String filePath) async {
    if (!_isPlayerInitialized) return;

    try {
      if (_isPlaying) {
        await _stopPlayback();
      }

      await _player.startPlayer(
        fromURI: filePath,
        codec: Codec.pcm16WAV,
        whenFinished: () {
          setState(() {
            _isPlaying = false;
            _currentlyPlayingFile = null;
          });
        },
      );

      setState(() {
        _isPlaying = true;
        _currentlyPlayingFile = filePath;
      });
    } catch (e) {
      _logger.e('Error playing sound: $e');
      setState(() {
        _isPlaying = false;
        _currentlyPlayingFile = null;
      });
    }
  }

  Future<void> _stopPlayback() async {
    try {
      await _player.stopPlayer();
      setState(() {
        _isPlaying = false;
        _currentlyPlayingFile = null;
      });
    } catch (e) {
      _logger.e('Error stopping playback: $e');
    }
  }

  String _getCategoryText(SoundCategory? category) {
    switch (category) {
      case SoundCategory.light:
        return 'nhẹ';
      case SoundCategory.medium:
        return 'vừa';
      case SoundCategory.loud:
        return 'to';
      default:
        return 'không xác định';
    }
  }

  String _getCategoryDescription(SoundCategory? category) {
    switch (category) {
      case SoundCategory.light:
        return 'Âm thanh nhẹ, có thể là tiếng nói chuyện nhẹ hoặc tiếng động nhỏ.';
      case SoundCategory.medium:
        return 'Âm thanh vừa, có thể là tiếng nói chuyện rõ ràng hoặc tiếng ngáy.';
      case SoundCategory.loud:
        return 'Âm thanh to, có thể là tiếng ho, cười hoặc la hét.';
      default:
        return 'Không xác định.';
    }
  }

  Color _getCategoryColor(SoundCategory? category) {
    switch (category) {
      case SoundCategory.light:
        return Colors.green;
      case SoundCategory.medium:
        return Colors.orange;
      case SoundCategory.loud:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  // Add this method to your RecordPageState class

  // Add method to get measurements file info
  Future<String?> getMeasurementsFileInfo() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/sound_measurements.json');

      if (await file.exists()) {
        final contents = await file.readAsString();
        final fileSize = await file.length();
        return '''
Measurements file:
Size: ${(fileSize / 1024).toStringAsFixed(2)} KB
Entries: ${_periodicMeasurements.length}
Last measurement: ${_periodicMeasurements.isNotEmpty ? _periodicMeasurements.last.time : 'N/A'}
''';
      }
      return 'No measurements file exists yet';
    } catch (e) {
      return 'Error reading measurements: $e';
    }
  }

  void _deleteRecording(int index) {
    setState(() {
      final filePath = _abnormalSoundFiles[index];
      _abnormalSoundFiles.removeAt(index);
      _soundCategories.remove(filePath);
      _recordMetadata.removeWhere((record) => record.filePath == filePath);
    });
  }

  // Add to startRecording method after starting the recorder
  void _startPeriodicMeasurements() {
    _currentSessionMeasurements.clear();
    _measurementTimer?.cancel();
    _measurementTimer = Timer.periodic(
      measurementInterval,
      (timer) => _recordMeasurement(),
    );

    // Take initial measurement
    _recordMeasurement();
  }

  void _recordMeasurement() {
    if (!_isRecording) return;

    final now = DateTime.now();
    final timeString =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    String event;
    if (_currentDecibel >= LOUD_SOUND_THRESHOLD) {
      event = 'talking';
    } else if (_currentDecibel >= MEDIUM_SOUND_THRESHOLD) {
      event = 'snore';
    } else {
      event = 'light';
    }

    final measurement = SoundMeasurement(
      time: timeString,
      db: _currentDecibel,
      event: event,
    );

    setState(() {
      _currentSessionMeasurements.add(measurement);
    });

    // Save measurements immediately
    _saveMeasurements();
  }

  // Add method to save measurements
  Future<void> _saveMeasurements() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/sound_measurements.json');

      final jsonList =
          _currentSessionMeasurements.map((m) => m.toJson()).toList();

      await file
          .writeAsString(const JsonEncoder.withIndent('  ').convert(jsonList));

      _logger.i('Saved ${jsonList.length} measurements');
    } catch (e) {
      _logger.e('Error saving measurements: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ghi âm trong giấc ngủ'),
        actions: [
          IconButton(
            icon: const Icon(Icons.analytics_outlined),
            onPressed: () async {
              final measurementsInfo = await getMeasurementsFileInfo();
              if (mounted) {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Thông tin đo lường'),
                    content: SingleChildScrollView(
                      child: Text(measurementsInfo ?? 'Không có thông tin'),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Đóng'),
                      ),
                    ],
                  ),
                );
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                ElevatedButton(
                  onPressed: _isRecorderInitialized
                      ? (_isRecording ? _stopRecording : _startRecording)
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isRecording ? Colors.red : Colors.blue,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                  ),
                  child: Text(
                    _isRecording ? 'Dừng ghi âm' : 'Bắt đầu ghi âm',
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
                if (_isRecording)
                  Column(
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(top: 16),
                        child: Text(
                          'Đang ghi âm...',
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                        height: 150,
                        padding: const EdgeInsets.all(8),
                        child: CustomPaint(
                          painter: AudioLevelPainter(
                            levels: _recentDecibels,
                            maxLevel: 160,
                          ),
                          size: Size.infinite,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Column(
                          children: [
                            Text(
                              'Cường độ hiện tại: ${_currentDecibel.toStringAsFixed(1)} dB',
                              style: const TextStyle(fontSize: 14),
                            ),
                            Text(
                              'Max: ${_maxDecibel.toStringAsFixed(1)} dB',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.blue,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _abnormalSoundFiles.length,
              itemBuilder: (context, index) {
                final filePath = _abnormalSoundFiles[index];
                final isPlaying =
                    _currentlyPlayingFile == filePath && _isPlaying;

                return ListTile(
                  title: Text(
                    'Âm thanh ${_getCategoryText(_soundCategories[filePath])} ${index + 1}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Thời gian: ${DateTime.parse(_recordMetadata[index].timestamp)}',
                        style: const TextStyle(fontSize: 12),
                      ),
                      Text(
                        'Cường độ TB: ${_recordMetadata[index].averageDecibel.toStringAsFixed(1)} dB',
                        style: const TextStyle(fontSize: 12),
                      ),
                      Text(
                        'Cường độ Max: ${_recordMetadata[index].maxDecibel.toStringAsFixed(1)} dB',
                        style: const TextStyle(fontSize: 12),
                      ),
                      Text(
                        _recordMetadata[index].description,
                        style: TextStyle(
                          fontSize: 12,
                          color: _getCategoryColor(_soundCategories[filePath]),
                        ),
                      ),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(
                          isPlaying ? Icons.stop : Icons.play_arrow,
                          color: isPlaying ? Colors.red : Colors.blue,
                        ),
                        onPressed: () {
                          if (isPlaying) {
                            _stopPlayback();
                          } else {
                            _playSound(filePath);
                          }
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          _deleteRecording(index);
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class AudioLevelPainter extends CustomPainter {
  AudioLevelPainter({required this.levels, required this.maxLevel});
  final List<double> levels;
  final double maxLevel;

  @override
  void paint(Canvas canvas, Size size) {
    if (levels.isEmpty) return;

    final paint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    // Draw background grid
    _drawGrid(canvas, size);

    // Draw the waveform
    final path = Path();
    final widthStep = size.width / (levels.length - 1);

    for (var i = 0; i < levels.length; i++) {
      final x = i * widthStep;
      // Use normalized values (0-100) for visualization
      final y = size.height - (levels[i] / 100) * size.height;

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, paint);

    // Draw threshold line
    final thresholdPaint = Paint()
      ..color = Colors.red.withOpacity(0.7)
      ..strokeWidth = 1.0;

    // Draw threshold at 65% of height (since we normalized to 0-100)
    final thresholdY = size.height - (65 / 100) * size.height;
    canvas.drawLine(
      Offset(0, thresholdY),
      Offset(size.width, thresholdY),
      thresholdPaint,
    );
  }

  void _drawGrid(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = Colors.grey.withOpacity(0.2)
      ..strokeWidth = 1.0;

    // Draw horizontal grid lines
    for (var i = 0; i <= 10; i++) {
      final y = i * (size.height / 10);
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        gridPaint,
      );
    }

    // Draw vertical grid lines
    for (var i = 0; i <= 10; i++) {
      final x = i * (size.width / 10);
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        gridPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
