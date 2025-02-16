// Thêm các import cần thiết
import 'dart:async';
import 'dart:io';
import 'dart:math' as math;

import 'package:auto_route/auto_route.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

@RoutePage()
class RecordPage extends StatefulWidget {
  const RecordPage({super.key});

  @override
  _RecordPageState createState() => _RecordPageState();
}

class AudioAnalysisData {
  final List<int> samples;
  final double volume;

  AudioAnalysisData(this.samples, this.volume);
}

class AudioChunkData {
  AudioChunkData(this.samples, this.volume, this.frequencyRanges);
  final List<int> samples;
  final double volume;
  final Map<String, List<double>>
      frequencyRanges; // Use List<double> instead of tuples
}

// Add this class to store sleep data points
class SleepDataPoint {
  SleepDataPoint(this.time, this.type, this.intensity);
  final DateTime time;
  final SleepSoundType type;
  final double intensity;
}

class _RecordPageState extends State<RecordPage> {
  // Các thông số tối ưu cho xử lý âm thanh
  static const int SAMPLE_RATE = 16000;
  static const int FFT_SIZE = 1024;
  static const int MONITOR_INTERVAL = 300;
  static const int MAX_BUFFER_SIZE = 65536;

  // Khai báo các biến cơ bản
  Timer? _audioMonitorTimer;
  final List<SleepRecording> _savedRecordings = [];
  final Map<String, String> _wavFileCache = {};
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  final AudioPlayer _player = AudioPlayer();
  final FlutterSoundHelper _flutterSoundHelper = FlutterSoundHelper();

  // Biến trạng thái
  bool _isRecording = false;
  bool _isCurrentlyRecordingSound = false;
  String? _currentFilePath;
  List<int> _audioBuffer = [];

// Giảm ngưỡng và mở rộng dải tần số
  final Map<SleepSoundType, (double, double)> _frequencyRanges = {
    SleepSoundType.snoring: (20.0, 850.0), // Tần số ngáy thường thấp hơn
    SleepSoundType.talking: (300.0, 3400.0), // Thu hẹp dải tần giọng nói
    SleepSoundType.breathing: (20.0, 400.0), // Hơi thở thường có tần số thấp
  };

  // Add these properties to _RecordPageState
  final List<SleepDataPoint> _sleepData = [];
  bool _showChart = false;
  bool _isPlaying = false;

  // Add cache properties
  List<FlSpot>? _snoringSpots;
  List<FlSpot>? _talkingSpots;
  List<FlSpot>? _breathingSpots;
  DateTime? _lastChartUpdate;

  @override
  void initState() {
    super.initState();
    _initializeRecorder();
    _loadExistingRecordings();
  }

  Future<void> _processAudioChunk(List<int> chunk) async {
    if (!_isRecording) return;

    try {
      final samples = _bytesToSamples(chunk);
      if (_audioBuffer.length > MAX_BUFFER_SIZE) {
        _audioBuffer = _audioBuffer.sublist(_audioBuffer.length - FFT_SIZE);
      }
      _audioBuffer.addAll(samples);

      if (_audioBuffer.length >= FFT_SIZE) {
        final volume =
            _calculateRMS(_audioBuffer.sublist(_audioBuffer.length - FFT_SIZE));
        if (volume > 100.0) {
          final analysisData = AudioAnalysisData(
            List<int>.from(_audioBuffer),
            volume,
          );
          // Use the top-level function "analyzeAudio" to avoid capturing unsendable objects.
          final soundType = await compute(analyzeAudio, analysisData);
          if (soundType != null && !_isCurrentlyRecordingSound && mounted) {
            setState(() => _isCurrentlyRecordingSound = true);
            await _startNewRecordingFile();
          }
        }
      }
    } catch (e) {
      debugPrint('Error processing chunk: $e');
    }
  }

  Future<void> _monitorAudio(Timer timer) async {
    if (!_isRecording || _currentFilePath == null) return;

    try {
      final file = File(_currentFilePath!);
      if (await file.exists()) {
        final bytes = await file.readAsBytes();
        if (bytes.isNotEmpty) {
          await _processAudioChunk(bytes);
        }
      }
    } catch (e) {
      debugPrint('Error monitoring audio: $e');
    }
  }

// Update startRecording method
  Future<void> _startRecording() async {
    if (_recorder.isRecording) return;

    try {
      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      _currentFilePath =
          '${directory.path}/sleep_recordings/sleep_$timestamp.pcm';

      setState(() {
        _isRecording = true;
        _audioBuffer.clear();
      });

      await _recorder.startRecorder(
        toFile: _currentFilePath,
        codec: Codec.pcm16,
        sampleRate: SAMPLE_RATE,
      );

      // Start monitoring with _monitorAudio
      _audioMonitorTimer?.cancel();
      _audioMonitorTimer = Timer.periodic(
        const Duration(milliseconds: MONITOR_INTERVAL),
        _monitorAudio,
      );

      debugPrint('Started recording to: $_currentFilePath');
    } catch (e) {
      debugPrint('Error starting recording: $e');
      setState(() => _isRecording = false);
      _currentFilePath = null;
    }
  }

// Add cleanup in dispose
  @override
  void dispose() {
    _audioMonitorTimer?.cancel();
    _audioBuffer.clear();
    _recorder.closeRecorder();
    _player.dispose();
    super.dispose();
  }

  Future<void> _initializeRecorder() async {
    try {
      await Permission.microphone.request();
      await _recorder.openRecorder();
      await _recorder.setSubscriptionDuration(const Duration(milliseconds: 10));

      final directory = await getApplicationDocumentsDirectory();
      await Directory('${directory.path}/sleep_recordings')
          .create(recursive: true);

      debugPrint('Recorder initialized successfully');
    } catch (e) {
      debugPrint('Error initializing recorder: $e');
    }
  }

  // Cải thiện phân tích FFT
  Future<List<double>> _computeFFT(List<int> samples) async {
    try {
      final int n = math.min(samples.length, FFT_SIZE);
      final List<double> magnitudes = List.filled(n ~/ 2, 0);

      // Xử lý theo từng phần để giảm tải
      const int batchSize = 64;
      for (int i = 0; i < n; i += batchSize) {
        final int end = math.min(i + batchSize, n);
        for (int j = i; j < end; j++) {
          final window = 0.54 - 0.46 * math.cos(2 * math.pi * j / (n - 1));
          magnitudes[j ~/ 2] += samples[j] * window;
        }
      }

      return magnitudes;
    } catch (e) {
      debugPrint('Error computing FFT: $e');
      return [];
    }
  }

  Future<SleepSoundType?> _analyzeSleepSound(List<int> samples) async {
    try {
      if (samples.isEmpty || !_isRecording) {
        // Thêm điều kiện kiểm tra ghi âm
        return null;
      }

      // Split samples into chunks for analysis
      final chunks = _splitIntoChunks(samples, FFT_SIZE);
      final List<SleepSoundType?> detectedTypes = [];

      for (final chunk in chunks) {
        final volume = _calculateRMS(chunk);

        // Chỉ phân tích khi đang ghi âm và âm lượng đủ lớn
        if (!_isRecording || volume < 50.0 || volume > 60000.0) {
          continue;
        }

        final magnitudes = await _computeFFT(chunk);
        final dominantFreq = _findDominantFrequency(magnitudes);

        // Check for each sound type
        if (_hasVoicePattern(magnitudes) &&
            _isInFrequencyRange(dominantFreq, SleepSoundType.talking)) {
          detectedTypes.add(SleepSoundType.talking);
        } else if (_checkSnoringPattern(magnitudes) &&
            _isInFrequencyRange(dominantFreq, SleepSoundType.snoring)) {
          detectedTypes.add(SleepSoundType.snoring);
        } else if (_isInFrequencyRange(
            dominantFreq, SleepSoundType.breathing)) {
          detectedTypes.add(SleepSoundType.breathing);
        }
      }

      // Get most frequent sound type only if still recording
      if (_isRecording) {
        final dominantType = _getMostFrequentSoundType(detectedTypes);
        if (dominantType != null) {
          debugPrint(
              'Dominant sound type detected: ${dominantType.toString()}');
        }
        return dominantType;
      }

      return null;
    } catch (e) {
      debugPrint('Error analyzing sleep sound: $e');
      return null;
    }
  }

  bool _isInFrequencyRange(double freq, SleepSoundType type) {
    final range = _frequencyRanges[type]!;
    return freq >= range.$1 && freq <= range.$2;
  }

  SleepSoundType? _getMostFrequentSoundType(List<SleepSoundType?> types) {
    if (types.isEmpty) return null;

    // Count occurrences of each sound type
    final frequency = <SleepSoundType, int>{};
    for (final type in types) {
      if (type != null) {
        frequency[type] = (frequency[type] ?? 0) + 1;
      }
    }

    if (frequency.isEmpty) return null;

    // Find type with highest frequency
    var maxType = frequency.entries.reduce((a, b) => a.value > b.value ? a : b);
    var totalSamples = types.length;
    var typeRatio = maxType.value / totalSamples;

    debugPrint('Sound type analysis:');
    debugPrint('Total samples: $totalSamples');
    debugPrint('Detected frequencies:');
    frequency.forEach((type, count) {
      debugPrint(
          '- ${type.toString()}: $count (${(count / totalSamples * 100).toStringAsFixed(1)}%)');
    });

    // Only return if the type appears in at least 30% of samples
    if (typeRatio >= 0.3) {
      debugPrint(
          'Selected type: ${maxType.key} (${(typeRatio * 100).toStringAsFixed(1)}%)');
      return maxType.key;
    }

    debugPrint('No dominant sound type found');
    return null;
  }

  List<List<int>> _splitIntoChunks(List<int> samples, int chunkSize) {
    final chunks = <List<int>>[];
    for (var i = 0; i < samples.length; i += chunkSize) {
      final end =
          (i + chunkSize < samples.length) ? i + chunkSize : samples.length;
      chunks.add(samples.sublist(i, end));
    }
    return chunks;
  }

  // Cải thiện theo dõi âm thanh

  // Update the _hasVoicePattern method for better voice detection
  bool _hasVoicePattern(List<double> magnitudes) {
    try {
      double voiceEnergy = 0.0;
      double totalEnergy = 0.0;
      int formantPeaks = 0;

      if (magnitudes.isEmpty) return false;

      final avgMagnitude =
          magnitudes.reduce((a, b) => a + b) / magnitudes.length;

      for (var i = 0; i < magnitudes.length; i++) {
        if (magnitudes[i].isNaN) continue;

        final freq = i * (SAMPLE_RATE / (2 * magnitudes.length));
        if (freq >= 300 && freq <= 3400) {
          // Điều chỉnh dải tần
          voiceEnergy += magnitudes[i];

          // Tăng độ chính xác phát hiện formant
          if (i > 0 &&
              i < magnitudes.length - 1 &&
              magnitudes[i] >
                  avgMagnitude * 1.5 && // Tăng ngưỡng phát hiện đỉnh
              magnitudes[i] >
                  magnitudes[i - 1] * 1.2 && // Thêm điều kiện so sánh
              magnitudes[i] > magnitudes[i + 1] * 1.2) {
            formantPeaks++;
          }
        }
        totalEnergy += magnitudes[i];
      }

      if (totalEnergy == 0) return false;

      final voiceRatio = voiceEnergy / totalEnergy;
      debugPrint('Voice pattern analysis:');
      debugPrint('- Voice ratio: $voiceRatio');
      debugPrint('- Formant peaks: $formantPeaks');

      // Tăng điều kiện nhận dạng giọng nói
      return voiceRatio > 0.4 && formantPeaks >= 3; // Yêu cầu nhiều formant hơn
    } catch (e) {
      debugPrint('Error in voice pattern analysis: $e');
      return false;
    }
  }

  Future<void> _startNewRecordingFile() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final recordingsDir = Directory('${directory.path}/sleep_recordings');

      // Đảm bảo thư mục tồn tại
      if (!await recordingsDir.exists()) {
        await recordingsDir.create(recursive: true);
      }

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      _currentFilePath =
          '${directory.path}/sleep_recordings/sleep_$timestamp.pcm';

      // Đảm bảo file cũ được dọn dẹp
      final file = File(_currentFilePath!);
      if (await file.exists()) {
        await file.delete();
      }

      await _recorder.startRecorder(
        toFile: _currentFilePath,
        codec: Codec.pcm16,
        sampleRate: SAMPLE_RATE,
        numChannels: 1,
      );

      debugPrint('Started recording to: $_currentFilePath');
      _audioBuffer.clear();
    } catch (e) {
      debugPrint('Failed to start recording: $e');
      _currentFilePath = null;
    }
  }

  List<int> _bytesToSamples(List<int> bytes) {
    final samples = <int>[];
    for (var i = 0; i < bytes.length - 1; i += 2) {
      final sample = (bytes[i + 1] << 8) | bytes[i];
      samples.add(sample);
    }
    return samples;
  }

  Future<void> _finalizeCurrentRecording() async {
    if (_currentFilePath == null || !_isRecording) {
      return;
    }

    try {
      // Stop the recorder if it's recording
      if (_recorder.isRecording) {
        await _recorder.stopRecorder();
        debugPrint('Recorder stopped');
      }

      // Verify the file exists and has content
      final file = File(_currentFilePath!);
      if (await file.exists()) {
        final fileSize = await file.length();
        if (fileSize == 0) {
          debugPrint('Empty recording detected - deleting file');
          await file.delete();
          _currentFilePath = null;
          return;
        }

        // Process and analyze the recording
        final bytes = await file.readAsBytes();
        final samples = _bytesToSamples(bytes);
        final soundType = await _analyzeSleepSound(samples);

        if (soundType != null) {
          final intensity = _calculateRMS(samples);
          final duration = samples.length / SAMPLE_RATE;

          setState(() {
            // Add to recordings list
            _savedRecordings.insert(
                0,
                SleepRecording(
                  filePath: _currentFilePath!,
                  timestamp: DateTime.now(),
                  type: soundType,
                  duration: duration,
                  intensity: intensity,
                ));

            // Add to sleep data for chart
            _sleepData.add(SleepDataPoint(
              DateTime.now(),
              soundType,
              intensity,
            ));
          });

          debugPrint('Recording saved: ${soundType.toString()}');
        } else {
          debugPrint('No valid sound detected - deleting file');
          await file.delete();
        }
      }
    } catch (e) {
      debugPrint('Error finalizing recording: $e');
      // Cleanup on error
      try {
        if (_currentFilePath != null) {
          await File(_currentFilePath!).delete();
        }
      } catch (cleanupError) {
        debugPrint('Error during cleanup: $cleanupError');
      }
    } finally {
      // Reset recording state
      setState(() {
        _isRecording = false;
        _isCurrentlyRecordingSound = false;
        _currentFilePath = null;
      });

      // Cancel any monitoring timer
      _audioMonitorTimer?.cancel();
      _audioMonitorTimer = null;
      final completedFilePath = _currentFilePath!;
      await _processCompletedRecording(completedFilePath);
    }
  }

  // Optimized WAV conversion with caching
  Future<String> _convertPcmToWav(String pcmFilePath) async {
    if (_wavFileCache.containsKey(pcmFilePath)) {
      final cachedPath = _wavFileCache[pcmFilePath]!;
      if (await File(cachedPath).exists()) {
        return cachedPath;
      }
    }

    final directory = await getApplicationDocumentsDirectory();
    final wavFilePath =
        '${directory.path}/sleep_recordings/playback_${DateTime.now().millisecondsSinceEpoch}.wav';

    try {
      await _flutterSoundHelper.pcmToWave(
        inputFile: pcmFilePath,
        outputFile: wavFilePath,
      );
      _wavFileCache[pcmFilePath] = wavFilePath;
      return wavFilePath;
    } catch (e) {
      debugPrint('Failed to convert PCM to WAV: $e');
      rethrow;
    }
  }

  double _findDominantFrequency(List<double> magnitudes) {
    var maxIndex = 0;
    double maxMagnitude = 0;

    for (var i = 0; i < magnitudes.length; i++) {
      if (magnitudes[i] > maxMagnitude) {
        maxMagnitude = magnitudes[i];
        maxIndex = i;
      }
    }

    return maxIndex * (SAMPLE_RATE / (2 * magnitudes.length));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF2C3E50), Color(0xFF3498DB)],
          ),
        ),
        child: CustomScrollView(
          slivers: [
            const SliverAppBar(
              pinned: true,
              backgroundColor: Colors.transparent,
              title: Text('Sleep Recorder'),
            ),
            SliverToBoxAdapter(
              child: RepaintBoundary(
                child: _buildRecordingButton(),
              ),
            ),
            if (_showChart)
              SliverToBoxAdapter(
                child: RepaintBoundary(
                  child: _buildSleepChart(),
                ),
              ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) =>
                    _buildRecordingItem(_savedRecordings[index]),
                childCount: _savedRecordings.length,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecordingItem(SleepRecording recording) {
    return RepaintBoundary(
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        color: Colors.white.withOpacity(0.1),
        child: ListTile(
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              _getSoundTypeIcon(recording.type),
              color: Colors.white,
            ),
          ),
          title: Row(
            children: [
              Expanded(
                child: Text(
                  recording.type.toString().split('.').last,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Text(
                _formatDuration(recording.duration),
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          subtitle: Text(
            _formatDateTime(recording.timestamp),
            style: const TextStyle(color: Colors.white70),
          ),
          trailing: SizedBox(
            width: 96, // Fixed width for two icons
            child: Row(
              children: [
                IconButton(
                  icon: Icon(
                    _isPlaying ? Icons.stop : Icons.play_arrow,
                    color: Colors.white,
                  ),
                  onPressed: () => _playRecording(recording.filePath),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.delete,
                    color: Colors.white70,
                  ),
                  onPressed: () {
                    final index = _savedRecordings.indexOf(recording);
                    if (index != -1) {
                      _deleteRecording(index);
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Add these helper methods
  IconData _getSoundTypeIcon(SleepSoundType type) {
    switch (type) {
      case SleepSoundType.snoring:
        return Icons.bed;
      case SleepSoundType.talking:
        return Icons.record_voice_over;
      case SleepSoundType.breathing:
        return Icons.air;
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')} - ${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }

  Future<void> _deleteRecording(int index) async {
    final recording = _savedRecordings[index];
    try {
      await File(recording.filePath).delete();
      setState(() {
        _savedRecordings.removeAt(index);
      });
    } catch (e) {
      debugPrint('Error deleting recording: $e');
    }
  }

  Future<void> _playRecording(String filePath) async {
    try {
      if (_isPlaying) {
        await _player.stop();
        setState(() => _isPlaying = false);
        return;
      }

      if (await File(filePath).exists()) {
        var wavFilePath = await _convertPcmToWav(filePath);
        await _player.setFilePath(wavFilePath);

        setState(() => _isPlaying = true);

        await _player.play();
        // Listen for playback completion
        _player.playerStateStream.listen((state) {
          if (state.processingState == ProcessingState.completed) {
            setState(() => _isPlaying = false);
          }
        });
      }
    } catch (e) {
      debugPrint('Failed to play recording: $e');
      setState(() => _isPlaying = false);
    }
  }

  // Update _startRecording method

  Future<void> _stopRecording() async {
    if (!_isRecording) return;

    try {
      await _finalizeCurrentRecording();
      _audioMonitorTimer?.cancel();
      _audioMonitorTimer = null;

      final filePath = _currentFilePath;
      if (filePath != null) {
        // Dừng ghi âm
        if (_recorder.isRecording) {
          await _recorder.stopRecorder();
          debugPrint('Recorder stopped');
        }

        // Kiểm tra file
        final file = File(filePath);
        if (await file.exists()) {
          final fileSize = await file.length();
          if (fileSize > 0) {
            await _processCompletedRecording(filePath);
          } else {
            debugPrint('Empty recording file detected');
            await file.delete();
          }
        }
      }
    } catch (e) {
      debugPrint('Error stopping recording: $e');
    } finally {
      // Reset state
      setState(() {
        _isRecording = false;
        _isCurrentlyRecordingSound = false;
        _currentFilePath = null;
      });
    }
  }

  bool _isSaving = false;

  Future<void> _processCompletedRecording(String filePath) async {
    setState(() => _isSaving = true);

    try {
      final file = File(filePath);
      if (!await file.exists()) {
        debugPrint('Recording file not found: $filePath');
        return;
      }

      final bytes = await file.readAsBytes();
      final samples = _bytesToSamples(bytes);
      final soundType = await _analyzeSleepSound(samples);
      final intensity = _calculateRMS(samples);
      final duration = samples.length / SAMPLE_RATE;

      if (soundType != null) {
        debugPrint('Processing recording:');
        debugPrint('- Sound type: $soundType');
        debugPrint('- Duration: ${_formatDuration(duration)}');
        debugPrint('- Intensity: $intensity');
        debugPrint('- File path: $filePath');

        setState(() {
          // Add to recordings list
          _savedRecordings.insert(
              0,
              SleepRecording(
                filePath: filePath,
                timestamp: DateTime.now(),
                type: soundType,
                duration: duration,
                intensity: intensity,
              ));

          // Add to sleep data for chart
          _sleepData.add(SleepDataPoint(
            DateTime.now(),
            soundType,
            _normalizeIntensity(intensity),
          ));

          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content:
                Text('Saved ${soundType.toString().split('.').last} recording'),
            backgroundColor: Colors.green,
          ));
        });
      } else {
        debugPrint('No valid sound detected - deleting file');
        await file.delete();

        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('No valid sound detected - Recording deleted'),
          backgroundColor: Colors.orange,
        ));
      }
    } catch (e) {
      debugPrint('Error processing recording: $e');
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Error saving recording'),
        backgroundColor: Colors.red,
      ));

      // Cleanup on error
      try {
        await File(filePath).delete();
      } catch (cleanupError) {
        debugPrint('Error cleaning up file: $cleanupError');
      }
    } finally {
      setState(() => _isSaving = false);
    }
  }

// Add helper method for intensity normalization
  double _normalizeIntensity(double rawIntensity) {
    // Normalize using logarithmic scale for better range
    double normalized = math.log(rawIntensity) / math.log(50000) * 5;
    return math.min(5.0, math.max(0.0, normalized));
  }

  Future<void> _loadExistingRecordings() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final recordingsDir = Directory('${directory.path}/sleep_recordings');
      // ignore: avoid_slow_async_io
      if (!await recordingsDir.exists()) {
        await recordingsDir.create(recursive: true);
        return;
      }

      final files = await recordingsDir.list().toList();
      final loadedRecordings = <SleepRecording>[];

      for (final file in files) {
        if (file.path.endsWith('.pcm')) {
          try {
            final bytes = await File(file.path).readAsBytes();
            final samples = _bytesToSamples(bytes);
            final soundType = await _analyzeSleepSound(samples);

            if (soundType != null) {
              final fileName = file.path.split(Platform.pathSeparator).last;
              final timestamp = DateTime.fromMillisecondsSinceEpoch(
                int.parse(fileName.split('_')[1].split('.')[0]),
              );

              loadedRecordings.add(
                SleepRecording(
                  filePath: file.path,
                  timestamp: timestamp,
                  type: soundType,
                  duration: samples.length / SAMPLE_RATE,
                  intensity: _calculateRMS(samples),
                ),
              );
            }
          } catch (e) {
            debugPrint('Error processing recording ${file.path}: $e');
          }
        }
      }

      // Sort recordings by timestamp (newest first) and update state
      setState(() {
        _savedRecordings
          ..clear()
          ..addAll(
            loadedRecordings
              ..sort((a, b) => b.timestamp.compareTo(a.timestamp)),
          );
      });

      debugPrint('Loaded ${_savedRecordings.length} recordings');
    } catch (e) {
      debugPrint('Error loading recordings: $e');
    }
  }

  double _calculateRMS(List<int> samples) {
    if (samples.isEmpty) return 0;

    var sum = 0;
    for (final sample in samples) {
      sum += sample * sample;
    }
    return math.sqrt(sum / samples.length);
  }

  String _formatDuration(double seconds) {
    final duration = Duration(milliseconds: (seconds * 1000).round());
    final minutes = duration.inMinutes;
    final remainingSeconds = duration.inSeconds - minutes * 60;
    // ignore: lines_longer_than_80_chars
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  Widget _buildSleepChart() {
    if (_sleepData.isEmpty) {
      return const Center(
        child: Text(
          'No sleep data recorded yet',
          style: TextStyle(color: Colors.white70),
        ),
      );
    }

    // Group data points by hour for better visualization
    final groupedData = <DateTime, Map<SleepSoundType, List<SleepDataPoint>>>{};

    for (final point in _sleepData) {
      final hour = DateTime(
        point.time.year,
        point.time.month,
        point.time.day,
        point.time.hour,
      );

      groupedData.putIfAbsent(hour, () => {});
      groupedData[hour]!.putIfAbsent(point.type, () => []);
      groupedData[hour]![point.type]!.add(point);
    }

    return Container(
      height: 250,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(
                  horizontalInterval: 1,
                  verticalInterval: 3600000, // 1 hour in milliseconds
                ),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(),
                  rightTitles: const AxisTitles(),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          _getSoundIntensityLabel(value),
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 10,
                          ),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 3600000, // 1 hour
                      getTitlesWidget: (value, meta) {
                        final time =
                            DateTime.fromMillisecondsSinceEpoch(value.toInt());
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            '${time.hour}:00',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 10,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: true),
                lineBarsData: [
                  // Snoring data
                  _createLineChartBar(
                    SleepSoundType.snoring,
                    Colors.red.withOpacity(0.8),
                  ),
                  // Talking data
                  _createLineChartBar(
                    SleepSoundType.talking,
                    Colors.green.withOpacity(0.8),
                  ),
                  // Breathing data
                  _createLineChartBar(
                    SleepSoundType.breathing,
                    Colors.blue.withOpacity(0.8),
                  ),
                ],
                minX: _sleepData.first.time.millisecondsSinceEpoch.toDouble(),
                maxX: _sleepData.last.time.millisecondsSinceEpoch.toDouble(),
                minY: 0,
                maxY: 5,
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendItem('Snoring', Colors.red),
              const SizedBox(width: 16),
              _buildLegendItem('Talking', Colors.green),
              const SizedBox(width: 16),
              _buildLegendItem('Breathing', Colors.blue),
            ],
          ),
        ],
      ),
    );
  }

  // Helper methods for the chart
  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 4,
          color: color.withOpacity(0.8),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  LineChartBarData _createLineChartBar(SleepSoundType type, Color color) {
    return LineChartBarData(
      spots: _getSpots(type),
      isCurved: true,
      color: color,
      barWidth: 3,
      isStrokeCapRound: true,
      dotData: FlDotData(
        getDotPainter: (spot, percent, barData, index) {
          return FlDotCirclePainter(
            radius: 3,
            color: color,
            strokeWidth: 1,
            strokeColor: Colors.white,
          );
        },
      ),
      belowBarData: BarAreaData(
        show: true,
        color: color.withOpacity(0.2),
      ),
    );
  }

  String _getSoundIntensityLabel(double value) {
    switch (value.round()) {
      case 0:
        return 'Silent';
      case 1:
        return 'Low';
      case 2:
        return 'Medium';
      case 3:
        return 'High';
      case 4:
        return 'Very High';
      default:
        return '';
    }
  }

  // Helper method to get chart spots for each sound type
  List<FlSpot> _getSpots(SleepSoundType type) {
    // Only regenerate spots if data changed
    if (_lastChartUpdate != null &&
        _sleepData.isNotEmpty &&
        _sleepData.last.time == _lastChartUpdate) {
      switch (type) {
        case SleepSoundType.snoring:
          return _snoringSpots ?? [];
        case SleepSoundType.talking:
          return _talkingSpots ?? [];
        case SleepSoundType.breathing:
          return _breathingSpots ?? [];
      }
    }

    // Update cache
    _lastChartUpdate = _sleepData.isNotEmpty ? _sleepData.last.time : null;

    final spots = _sleepData
        .where((data) => data.type == type)
        .map((data) => FlSpot(
              data.time.millisecondsSinceEpoch.toDouble(),
              data.intensity,
            ))
        .toList();

    switch (type) {
      case SleepSoundType.snoring:
        _snoringSpots = spots;
        break;
      case SleepSoundType.talking:
        _talkingSpots = spots;
        break;
      case SleepSoundType.breathing:
        _breathingSpots = spots;
        break;
    }

    return spots;
  }

  Widget _buildRecordingButton() {
    return GestureDetector(
      onTap: () async {
        if (_isRecording) {
          await _stopRecording();
        } else {
          await _startRecording();
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: _isRecording ? 100 : 80,
        height: _isRecording ? 100 : 80,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: _isRecording ? Colors.red : Colors.white,
          boxShadow: [
            BoxShadow(
              color: (_isRecording ? Colors.red : Colors.blue).withOpacity(0.3),
              blurRadius: _isRecording ? 20 : 10,
              spreadRadius: _isRecording ? 4 : 2,
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Main icon
            Icon(
              _isRecording ? Icons.stop : Icons.mic,
              size: _isRecording ? 50 : 40,
              color: _isRecording ? Colors.white : Colors.blue,
            ),

            // Recording indicator
            if (_isRecording)
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(seconds: 1),
                builder: (context, value, child) {
                  return Transform.rotate(
                    angle: value * 2 * math.pi,
                    child: CircularProgressIndicator(
                      value: null,
                      strokeWidth: 3,
                      color: Colors.white.withOpacity(0.5),
                    ),
                  );
                },
              ),

            // Saving indicator
            if (_isSaving)
              const Positioned(
                bottom: 5,
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

enum SleepSoundType {
  snoring,
  talking,
  breathing,
}

class SleepRecording {
  SleepRecording({
    required this.filePath,
    required this.timestamp,
    required this.type,
    this.duration = 0.0,
    this.intensity = 0.0,
  });
  final String filePath;
  final DateTime timestamp;
  final SleepSoundType type;
  final double duration;
  final double intensity;
}

bool _checkSnoringPattern(List<double> magnitudes) {
  try {
    // Calculate average magnitude
    final avgMagnitude = magnitudes.reduce((a, b) => a + b) / magnitudes.length;

    // Look for periodic patterns characteristic of snoring
    var peakCount = 0;
    var wasUp = false;
    double lastPeakValue = 0;
    final peakIntervals = <double>[];

    for (var i = 1; i < magnitudes.length - 1; i++) {
      if (magnitudes[i] > avgMagnitude * 1.2 && // Peak threshold
          magnitudes[i] > magnitudes[i - 1] &&
          magnitudes[i] > magnitudes[i + 1]) {
        if (lastPeakValue > 0) {
          peakIntervals.add(i - lastPeakValue);
        }
        lastPeakValue = i.toDouble();
        peakCount++;
        wasUp = true;
      } else if (wasUp && magnitudes[i] < avgMagnitude * 0.8) {
        wasUp = false;
      }
    }

    // Check if we have enough peaks and they're relatively regular
    if (peakCount >= 2 && peakIntervals.isNotEmpty) {
      final avgInterval =
          peakIntervals.reduce((a, b) => a + b) / peakIntervals.length;
      final regularPattern = peakIntervals.every(
        (interval) => (interval - avgInterval).abs() / avgInterval < 0.3,
      ); // 30% tolerance

      debugPrint(
        'Snoring analysis: peaks=$peakCount, regularPattern=$regularPattern',
      );
      return regularPattern;
    }

    return false;
  } catch (e) {
    debugPrint('Error checking snoring pattern: $e');
    return false;
  }
}

// Add constant at file level
const int SAMPLE_RATE = 16000;
const int FFT_SIZE = 1024;

// Top-level function for FFT computation (moved from _computeFFT)
Future<List<double>> computeFFT(List<int> samples) async {
  try {
    final int n = math.min(samples.length, FFT_SIZE);
    final List<double> magnitudes = List.filled(n ~/ 2, 0);
    const int batchSize = 64;
    for (int i = 0; i < n; i += batchSize) {
      final int end = math.min(i + batchSize, n);
      for (int j = i; j < end; j++) {
        final window = 0.54 - 0.46 * math.cos(2 * math.pi * j / (n - 1));
        magnitudes[j ~/ 2] += samples[j] * window;
      }
    }
    return magnitudes;
  } catch (e) {
    debugPrint('Error computing FFT: $e');
    return [];
  }
}

// Top-level helper to find dominant frequency
double findDominantFrequency(List<double> magnitudes) {
  var maxIndex = 0;
  double maxMagnitude = 0;
  for (var i = 0; i < magnitudes.length; i++) {
    if (magnitudes[i] > maxMagnitude) {
      maxMagnitude = magnitudes[i];
      maxIndex = i;
    }
  }
  return maxIndex * (SAMPLE_RATE / (2 * magnitudes.length));
}

bool checkSnoringPattern(List<double> magnitudes) {
  try {
    // Calculate average magnitude
    final avgMagnitude = magnitudes.reduce((a, b) => a + b) / magnitudes.length;
    int peakCount = 0;
    final List<double> peakIntervals = [];
    double lastPeakIndex = 0;

    for (int i = 1; i < magnitudes.length - 1; i++) {
      if (magnitudes[i] > avgMagnitude * 1.2 &&
          magnitudes[i] > magnitudes[i - 1] &&
          magnitudes[i] > magnitudes[i + 1]) {
        if (lastPeakIndex > 0) {
          peakIntervals.add(i - lastPeakIndex);
        }
        lastPeakIndex = i.toDouble();
        peakCount++;
      }
    }

    // Require at least 2 peaks and regular intervals (30% tolerance)
    if (peakCount >= 2 && peakIntervals.isNotEmpty) {
      final avgInterval =
          peakIntervals.reduce((a, b) => a + b) / peakIntervals.length;
      final regularPattern = peakIntervals.every(
        (interval) => ((interval - avgInterval).abs() / avgInterval) < 0.3,
      );
      debugPrint(
          'Snoring analysis: peakCount=$peakCount, regular=$regularPattern');
      return regularPattern;
    }
    return false;
  } catch (e) {
    debugPrint('Error checking snoring pattern: $e');
    return false;
  }
}

bool hasVoicePattern(List<double> magnitudes) {
  try {
    double voiceEnergy = 0.0;
    double totalEnergy = 0.0;
    int formantPeaks = 0;

    if (magnitudes.isEmpty) return false;

    final avgMagnitude = magnitudes.reduce((a, b) => a + b) / magnitudes.length;

    // Analyze each frequency bin
    for (int i = 0; i < magnitudes.length; i++) {
      final current = magnitudes[i];
      // Calculate frequency for this bin
      final freq = i * (SAMPLE_RATE / (2 * magnitudes.length));
      totalEnergy += current;

      // Consider voice frequencies (300-3400 Hz) with a slight boost above average
      if (freq >= 300 && freq <= 3400 && current > avgMagnitude * 1.1) {
        voiceEnergy += current;
        if (i > 0 &&
            i < magnitudes.length - 1 &&
            current > magnitudes[i - 1] &&
            current > magnitudes[i + 1]) {
          formantPeaks++;
        }
      }
    }

    if (totalEnergy == 0) return false;

    final voiceRatio = voiceEnergy / totalEnergy;
    debugPrint(
        'Voice analysis: voiceRatio=$voiceRatio, formantPeaks=$formantPeaks');

    // Determine if voice energy is high enough and enough peaks (formant candidates) exist
    return voiceRatio > 0.4 && formantPeaks >= 3;
  } catch (e) {
    debugPrint('Error in voice pattern detection: $e');
    return false;
  }
}

bool checkBreathingPattern(List<double> magnitudes, double dominantFreq) {
  try {
    final avgMagnitude = magnitudes.reduce((a, b) => a + b) / magnitudes.length;
    int breathCycles = 0;
    final List<double> peakIntervals = [];
    double lastPeakTime = 0;

    // Typical breathing rate is 12-20 breaths per minute, so intervals around 3-5 seconds
    const double minBreathInterval = 2.5; // seconds
    const double maxBreathInterval = 5.5; // seconds

    // Use the FFT bins as time markers (simulation)
    for (int i = 1; i < magnitudes.length - 1; i++) {
      // Approximate time corresponding to the current index
      final timePoint = i * (SAMPLE_RATE / (2 * magnitudes.length));

      // Look for gentle peaks characteristic of breathing sounds
      if (magnitudes[i] > avgMagnitude * 1.1 &&
          magnitudes[i] > magnitudes[i - 1] &&
          magnitudes[i] > magnitudes[i + 1]) {
        if (lastPeakTime > 0) {
          final interval = timePoint - lastPeakTime;
          if (interval >= minBreathInterval && interval <= maxBreathInterval) {
            peakIntervals.add(interval);
          }
        }
        lastPeakTime = timePoint;
        breathCycles++;
      }
    }

    if (breathCycles >= 2 && peakIntervals.isNotEmpty) {
      final avgInterval =
          peakIntervals.reduce((a, b) => a + b) / peakIntervals.length;
      final regularPattern = peakIntervals.every(
        (interval) => ((interval - avgInterval).abs() / avgInterval) < 0.2,
      );
      // Dominant frequency for breathing is typically very low (0.2-0.5 Hz)
      final frequencyOk = dominantFreq >= 0.2 && dominantFreq <= 0.5;

      debugPrint('Breathing analysis: breathCycles=$breathCycles, '
          'avgInterval=${avgInterval.toStringAsFixed(2)}, '
          'regular=$regularPattern, frequencyOk=$frequencyOk');
      return regularPattern && frequencyOk;
    }
    return false;
  } catch (e) {
    debugPrint('Error checking breathing pattern: $e');
    return false;
  }
}

// Top-level function to analyze audio (replacing _analyzeAudioInIsolate)
Future<SleepSoundType?> analyzeAudio(AudioAnalysisData data) async {
  try {
    if (data.samples.length < FFT_SIZE) return null;
    final samples = data.samples.length > FFT_SIZE
        ? data.samples.sublist(data.samples.length - FFT_SIZE)
        : data.samples;
    final magnitudes = await computeFFT(samples);
    if (magnitudes.isEmpty) return null;
    final dominantFreq = findDominantFrequency(magnitudes);

    final results = await Future.wait([
      Future(() => checkSnoringPattern(magnitudes)),
      Future(() => hasVoicePattern(magnitudes)),
      Future(() => checkBreathingPattern(magnitudes, dominantFreq)),
    ]);

    if (results[0]) return SleepSoundType.snoring;
    if (results[1]) return SleepSoundType.talking;
    if (results[2]) return SleepSoundType.breathing;
    return null;
  } catch (e) {
    debugPrint('Error in audio analysis: $e');
    return null;
  }
}
