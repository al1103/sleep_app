import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sleep/home/presentation/pages/widgets/base_navigation_bar.dart';

final soundPlayerProvider = StateProvider<int?>((ref) => null);
final isPlayingProvider = StateProvider<bool>((ref) => false);
final selectedTimerProvider = StateProvider<int>((ref) => 30);

@RoutePage()
class RelaxPage extends ConsumerStatefulWidget {
  const RelaxPage({super.key});

  @override
  ConsumerState<RelaxPage> createState() => _RelaxPageState();
}

class _RelaxPageState extends ConsumerState<RelaxPage>
    with SingleTickerProviderStateMixin {
  // Colors
  final Color _cardColor = const Color(0xFF1A1D2E);
  final Color _primaryColor = const Color(0xFF6366F1);
  final Color _darkBackgroundColor = const Color(0xFF0F1120);
  final Color _accentColor = const Color(0xFF22C55E);
  final Color _relaxBlue = const Color(0xFF60A5FA);

  late AnimationController _animationController;
  final List<int> _timerOptions = [5, 15, 30, 45, 60, 90];

  // Sound categories with their sounds
  final List<SoundCategory> _soundCategories = [
    SoundCategory(
      name: 'Nature',
      icon: Icons.nature,
      color: const Color(0xFF22C55E),
      sounds: [
        Sound(id: 1, name: 'Rain', icon: Icons.water_drop),
        Sound(id: 2, name: 'Forest', icon: Icons.forest),
        Sound(id: 3, name: 'Ocean', icon: Icons.waves),
        Sound(id: 4, name: 'Thunder', icon: Icons.thunderstorm),
        Sound(id: 5, name: 'Birds', icon: Icons.flutter_dash),
      ],
    ),
    SoundCategory(
      name: 'Ambient',
      icon: Icons.nightlight_round,
      color: const Color(0xFF60A5FA),
      sounds: [
        Sound(id: 6, name: 'White Noise', icon: Icons.blur_on),
        Sound(id: 7, name: 'Brown Noise', icon: Icons.blur_linear),
        Sound(id: 8, name: 'Pink Noise', icon: Icons.grain),
        Sound(id: 9, name: 'Fan', icon: Icons.air),
        Sound(id: 10, name: 'Humming', icon: Icons.music_note),
      ],
    ),
    SoundCategory(
      name: 'Meditation',
      icon: Icons.self_improvement,
      color: const Color(0xFFA78BFA),
      sounds: [
        Sound(id: 11, name: 'Singing Bowl', icon: Icons.music_note),
        Sound(id: 12, name: 'Ohm', icon: Icons.surround_sound),
        Sound(id: 13, name: 'Bells', icon: Icons.notifications_active),
        Sound(id: 14, name: 'Breath', icon: Icons.air),
        Sound(id: 15, name: 'Chimes', icon: Icons.wind_power),
      ],
    ),
    SoundCategory(
      name: 'ASMR',
      icon: Icons.spatial_audio_off,
      color: const Color(0xFFF97316),
      sounds: [
        Sound(id: 16, name: 'Tapping', icon: Icons.touch_app),
        Sound(id: 17, name: 'Whisper', icon: Icons.record_voice_over),
        Sound(id: 18, name: 'Crinkle', icon: Icons.waves),
        Sound(id: 19, name: 'Pages', icon: Icons.book),
        Sound(id: 20, name: 'Keyboard', icon: Icons.keyboard),
      ],
    ),
  ];

  int _selectedCategoryIndex = 0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _playSound(int soundId) {
    final isPlaying = ref.read(isPlayingProvider);
    final currentSoundId = ref.read(soundPlayerProvider);

    if (currentSoundId == soundId && isPlaying) {
      // Stop playing this sound
      ref.read(isPlayingProvider.notifier).state = false;
      ref.read(soundPlayerProvider.notifier).state = null;
      _animationController.reverse();
    } else {
      // Play this sound
      ref.read(isPlayingProvider.notifier).state = true;
      ref.read(soundPlayerProvider.notifier).state = soundId;
      _animationController.forward();

      // Here you would add your actual sound playing logic
      // playSound(soundId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isPlaying = ref.watch(isPlayingProvider);
    final currentPlayingSoundId = ref.watch(soundPlayerProvider);
    final selectedTimer = ref.watch(selectedTimerProvider);

    return Scaffold(
      backgroundColor: _darkBackgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                _buildAppBar(),
                SliverToBoxAdapter(
                  child: _buildContent(
                    isPlaying: isPlaying,
                    currentPlayingSoundId: currentPlayingSoundId,
                    selectedTimer: selectedTimer,
                  ),
                ),
                const SliverPadding(
                  padding: EdgeInsets.only(bottom: 80),
                ),
              ],
            ),
            if (isPlaying) _buildPlayingControls(),
          ],
        ),
      ),
      bottomNavigationBar: const BaseNavigationBar(),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 140,
      pinned: true,
      backgroundColor: _darkBackgroundColor,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.spa,
              color: _relaxBlue,
              size: 20,
            ),
            const SizedBox(width: 8),
            const Text(
              'Relax & Focus',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Gradient background
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    _relaxBlue.withOpacity(0.3),
                    _darkBackgroundColor,
                  ],
                ),
              ),
            ),

            // Decorative elements
            Positioned(
              right: -40,
              top: -20,
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _relaxBlue.withOpacity(0.1),
                ),
              ),
            ),

            Positioned(
              left: -30,
              bottom: 20,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _accentColor.withOpacity(0.05),
                ),
              ),
            ),

            // Quote text
            Positioned(
              bottom: 60,
              left: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '"Peace begins with a smile."',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  Text(
                    '- Mother Teresa',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.favorite_border, color: Colors.white),
          onPressed: () {},
          tooltip: 'Favorites',
        ),
        IconButton(
          icon: const Icon(Icons.settings, color: Colors.white),
          onPressed: () {},
          tooltip: 'Settings',
        ),
      ],
    );
  }

  Widget _buildContent({
    required bool isPlaying,
    required int? currentPlayingSoundId,
    required int selectedTimer,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCategorySelector(),
          const SizedBox(height: 24),
          _buildSoundGrid(currentPlayingSoundId),
          const SizedBox(height: 24),
          _buildRecentlyPlayed(),
          const SizedBox(height: 24),
          _buildTimerSelector(selectedTimer),
          const SizedBox(height: 24),
          _buildMixerCard(),
        ],
      ),
    );
  }

  Widget _buildCategorySelector() {
    return SizedBox(
      height: 44,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _soundCategories.length,
        itemBuilder: (context, index) {
          final category = _soundCategories[index];
          final isSelected = index == _selectedCategoryIndex;

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedCategoryIndex = index;
              });
            },
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: isSelected
                    ? category.color.withOpacity(0.2)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected
                      ? category.color
                      : Colors.grey.withOpacity(0.3),
                  width: 1.5,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    category.icon,
                    color: isSelected ? category.color : Colors.grey,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    category.name,
                    style: TextStyle(
                      color: isSelected ? category.color : Colors.grey,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSoundGrid(int? currentPlayingSoundId) {
    final sounds = _soundCategories[_selectedCategoryIndex].sounds;
    final color = _soundCategories[_selectedCategoryIndex].color;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: sounds.length,
      itemBuilder: (context, index) {
        final sound = sounds[index];
        final isPlaying = sound.id == currentPlayingSoundId;

        return GestureDetector(
          onTap: () => _playSound(sound.id),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: isPlaying ? color.withOpacity(0.2) : _cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isPlaying ? color : Colors.transparent,
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isPlaying
                        ? color.withOpacity(0.3)
                        : color.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    sound.icon,
                    color: isPlaying ? color : Colors.white70,
                    size: 28,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  sound.name,
                  style: TextStyle(
                    color: isPlaying ? color : Colors.white70,
                    fontWeight: isPlaying ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
                const SizedBox(height: 4),
                if (isPlaying) _buildSoundWave(color),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSoundWave(Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        5,
        (index) => Container(
          margin: const EdgeInsets.symmetric(horizontal: 1),
          width: 3,
          height: 8.0 * (1 + (index % 3) * 0.4),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(1),
          ),
        ),
      ),
    );
  }

  Widget _buildRecentlyPlayed() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recently Played',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 5,
            itemBuilder: (context, index) {
              final recentSounds = [
                Sound(id: 1, name: 'Rain', icon: Icons.water_drop),
                Sound(id: 6, name: 'White Noise', icon: Icons.blur_on),
                Sound(id: 3, name: 'Ocean', icon: Icons.waves),
                Sound(id: 11, name: 'Singing Bowl', icon: Icons.music_note),
                Sound(id: 17, name: 'Whisper', icon: Icons.record_voice_over),
              ];

              final sound = recentSounds[index];
              final colors = [
                _accentColor,
                _relaxBlue,
                _primaryColor,
                const Color(0xFFA78BFA),
                const Color(0xFFF97316),
              ];

              return Container(
                width: 120,
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      colors[index],
                      colors[index].withOpacity(0.7),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () => _playSound(sound.id),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            sound.icon,
                            color: Colors.white,
                            size: 32,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            sound.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTimerSelector(int selectedTimer) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Sleep Timer',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 44,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _timerOptions.length,
            itemBuilder: (context, index) {
              final time = _timerOptions[index];
              final isSelected = time == selectedTimer;

              return GestureDetector(
                onTap: () {
                  ref.read(selectedTimerProvider.notifier).state = time;
                },
                child: Container(
                  margin: const EdgeInsets.only(right: 12),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? _relaxBlue.withOpacity(0.2)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected
                          ? _relaxBlue
                          : Colors.grey.withOpacity(0.3),
                      width: 1.5,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      '$time min',
                      style: TextStyle(
                        color: isSelected ? _relaxBlue : Colors.grey,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMixerCard() {
    return Card(
      color: _cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _relaxBlue.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.surround_sound,
                    color: _relaxBlue,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Sound Mixer',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: _relaxBlue),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Text(
                    'Create Mix',
                    style: TextStyle(color: _relaxBlue),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              'Combine different sounds to create your perfect ambience for sleep, meditation, or focus.',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _relaxBlue.withOpacity(0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _relaxBlue.withOpacity(0.2)),
              ),
              child: const Column(
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.lightbulb_outline,
                        color: Colors.amber,
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Tip',
                        style: TextStyle(
                          color: Colors.amber,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Try mixing rain with brown noise for the perfect sleep environment.',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayingControls() {
    final playingSound = _getSoundById(ref.read(soundPlayerProvider) ?? 0);
    if (playingSound == null) return const SizedBox();

    final category = _getCategoryForSound(playingSound.id);

    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        decoration: BoxDecoration(
          color: _darkBackgroundColor.withOpacity(0.9),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        child: SafeArea(
          top: false,
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: category.color.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  playingSound.icon,
                  color: category.color,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      playingSound.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      '${ref.read(selectedTimerProvider)} min timer',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.stop_circle_outlined,
                    color: Colors.white, size: 32,),
                onPressed: () {
                  ref.read(isPlayingProvider.notifier).state = false;
                  ref.read(soundPlayerProvider.notifier).state = null;
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Sound? _getSoundById(int id) {
    for (final category in _soundCategories) {
      for (final sound in category.sounds) {
        if (sound.id == id) return sound;
      }
    }
    return null;
  }

  SoundCategory _getCategoryForSound(int soundId) {
    for (final category in _soundCategories) {
      for (final sound in category.sounds) {
        if (sound.id == soundId) return category;
      }
    }
    return _soundCategories[0]; // Default fallback
  }
}

// Data models
class SoundCategory {

  SoundCategory({
    required this.name,
    required this.icon,
    required this.color,
    required this.sounds,
  });
  final String name;
  final IconData icon;
  final Color color;
  final List<Sound> sounds;
}

class Sound {

  Sound({
    required this.id,
    required this.name,
    required this.icon,
  });
  final int id;
  final String name;
  final IconData icon;
}
