import 'dart:io' as io;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';

class RecordPage extends ConsumerStatefulWidget {
  const RecordPage({super.key});

  @override
  ConsumerState<RecordPage> createState() => RecordPageState();
}

class RecordPageState extends ConsumerState<RecordPage> {
  List<String> filesList = [];
  List<io.FileSystemEntity> _recordedFiles = [];
  final AudioPlayer player = AudioPlayer(); // Create a player

  @override
  void initState() {
    super.initState();
    _initializeDirectory();
  }

  Future<void> _initializeDirectory() async {
    final directory = await getApplicationDocumentsDirectory();
    final path = directory.path;
    final dir = io.Directory(path);

    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }

    final files = dir.listSync();
    setState(() {
      filesList = files.map((file) => file.path).toList();
      _recordedFiles = files;
    });
  }

  Future<void> _deleteFile(io.File file) async {
    try {
      await file.delete();
      await _initializeDirectory();
      debugPrint('File deleted: ${file.path}');
    } catch (e) {
      debugPrint('Error deleting file: $e');
    }
  }

  Future<void> _playAudio(String url) async {
    try {
      await player.setUrl(url); // Load a URL
      player.play(); // Play without waiting for completion
    } catch (e) {
      debugPrint('Error playing audio: $e');
    }
  }

  @override
  void dispose() {
    player.dispose(); // Dispose the player when not needed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recorded Files'),
      ),
      body: Center(
        child: Column(
          children: [
            ElevatedButton(
              onPressed: _initializeDirectory,
              child: const Text('Refresh'),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _recordedFiles.length,
                itemBuilder: (context, index) {
                  final file = _recordedFiles[index];
                  return ListTile(
                    title: Text(file.path.split('/').last),
                    onTap: () async {
                      await _playAudio(file.path);
                    },
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () async {
                        await _deleteFile(io.File(file.path));
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
