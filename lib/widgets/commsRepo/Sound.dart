// First, add this to your pubspec.yaml:
// dependencies:
//   just_audio: ^0.9.36

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class SoundButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onPressed;
  final String soundUrl;

  const SoundButton({
    Key? key,
    required this.child,
    required this.onPressed,
    this.soundUrl = '/assets/sounds/error.mp3',
  }) : super(key: key);

  @override
  State<SoundButton> createState() => _SoundButtonState();
}

class _SoundButtonState extends State<SoundButton> {
  late AudioPlayer _audioPlayer;
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();
    _initAudio();
  }

  Future<void> _initAudio() async {
    _audioPlayer = AudioPlayer();
    try {
      await _audioPlayer.setAsset(widget.soundUrl);
      setState(() => _isLoaded = true);
    } catch (e) {
      print('Error loading audio: $e');
    }
  }

  Future<void> _playSound() async {
    if (_isLoaded) {
      try {
        await _audioPlayer.seek(Duration.zero);
        await _audioPlayer.play();
      } catch (e) {
        print('Error playing sound: $e');
      }
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        await _playSound();
        widget.onPressed();
      },
      child: widget.child,
    );
  }
}





// Usage example with your login button:
class Screen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SoundButton(
          soundUrl: 'assets/click.mp3', 
          onPressed: () {
            // Your login logic
            print('Button clicked with sound!');
          },
          child: const Text('Login'),
        ),
      ),
    );
  }
}