import 'package:flutter/material.dart';

class SleepNotesScreen extends StatefulWidget {
  const SleepNotesScreen({Key? key}) : super(key: key);

  @override
  State<SleepNotesScreen> createState() => _SleepNotesScreenState();
}

class _SleepNotesScreenState extends State<SleepNotesScreen> {
  // Sample sleep notes (can be empty to show empty state)
  final List<String> _sleepNotes = [
    "I had trouble falling asleep last night after drinking coffee late.",
    "Woke up feeling refreshed after trying the new breathing technique.",
    "Sleep was interrupted multiple times by noise outside.",
    "The new pillow seems to be helping with my neck pain.",
    "Had vivid dreams after eating spicy food for dinner.",
  ];
  // Uncomment below and comment out the above list to test the empty state
  // final List<String> _sleepNotes = [];

  // Colors
  final Color _cardColor = const Color(0xFF1E1F23);
  final Color _primaryColor = const Color(0xFF6C63FF);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Sleep Notes', style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.filter_list, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: _buildNotesContent(),
      floatingActionButton: FloatingActionButton(
        backgroundColor: _primaryColor,
        child: const Icon(Icons.mic),
        onPressed: () {
          // Add new sleep note functionality
          _showAddNoteDialog();
        },
      ),
    );
  }

  Widget _buildNotesContent() {
    return _sleepNotes.isEmpty
        ? Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.notes_outlined,
                  size: 80,
                  color: Colors.white.withOpacity(0.2),
                ),
                const SizedBox(height: 16),
                Text(
                  "No sleep notes yet",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Record your sleep to add notes",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.4),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  icon: const Icon(Icons.mic),
                  label: const Text("Add First Note"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () => _showAddNoteDialog(),
                ),
              ],
            ),
          )
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _sleepNotes.length,
            physics: const BouncingScrollPhysics(),
            itemBuilder: (context, index) {
              return Dismissible(
                key: Key(_sleepNotes[index]),
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  color: Colors.redAccent,
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                direction: DismissDirection.endToStart,
                onDismissed: (direction) {
                  setState(() {
                    _sleepNotes.removeAt(index);
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Sleep note deleted'),
                      behavior: SnackBarBehavior.floating,
                      action: SnackBarAction(
                        label: 'UNDO',
                        onPressed: () {},
                      ),
                    ),
                  );
                },
                child: Card(
                  color: _cardColor,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Column(
                    children: [
                      ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        leading: CircleAvatar(
                          backgroundColor: _primaryColor.withOpacity(0.2),
                          child: Icon(Icons.mic, color: _primaryColor),
                        ),
                        title: Text(
                          _sleepNotes[index],
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Row(
                            children: [
                              Icon(
                                Icons.calendar_today,
                                size: 14,
                                color: Colors.white.withOpacity(0.6),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                "March ${index + 1}, 2025",
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.6),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.play_arrow,
                                  color: Colors.white70),
                              onPressed: () {
                                // Play audio note functionality
                              },
                            ),
                            IconButton(
                              icon:
                                  const Icon(Icons.edit, color: Colors.white70),
                              onPressed: () {
                                // Edit note functionality
                                _showEditNoteDialog(index);
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
  }

  void _showAddNoteDialog() {
    TextEditingController noteController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: _cardColor,
          title: const Text(
            "Add Sleep Note",
            style: TextStyle(color: Colors.white),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black45,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.mic,
                      color: _primaryColor,
                      size: 32,
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      "Record Audio",
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: noteController,
                style: const TextStyle(color: Colors.white),
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: "Type your sleep note here...",
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.4)),
                  filled: true,
                  fillColor: Colors.black45,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              child: Text(
                "Cancel",
                style: TextStyle(color: _primaryColor),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _primaryColor,
                foregroundColor: Colors.white,
              ),
              child: const Text("Save"),
              onPressed: () {
                if (noteController.text.isNotEmpty) {
                  setState(() {
                    _sleepNotes.insert(0, noteController.text);
                  });
                }
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showEditNoteDialog(int index) {
    TextEditingController noteController =
        TextEditingController(text: _sleepNotes[index]);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: _cardColor,
          title: const Text(
            "Edit Sleep Note",
            style: TextStyle(color: Colors.white),
          ),
          content: TextField(
            controller: noteController,
            style: const TextStyle(color: Colors.white),
            maxLines: 3,
            decoration: InputDecoration(
              hintText: "Edit your sleep note...",
              hintStyle: TextStyle(color: Colors.white.withOpacity(0.4)),
              filled: true,
              fillColor: Colors.black45,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          actions: [
            TextButton(
              child: Text(
                "Cancel",
                style: TextStyle(color: _primaryColor),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _primaryColor,
                foregroundColor: Colors.white,
              ),
              child: const Text("Update"),
              onPressed: () {
                if (noteController.text.isNotEmpty) {
                  setState(() {
                    _sleepNotes[index] = noteController.text;
                  });
                }
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
