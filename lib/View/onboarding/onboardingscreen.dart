import 'package:audioplayer/View/Pages/AllSongs/Songs.dart';
import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnBoardingPage extends StatefulWidget {
  const OnBoardingPage({super.key});

  @override
  OnBoardingPageState createState() => OnBoardingPageState();
}

class OnBoardingPageState extends State<OnBoardingPage> {
  final introKey = GlobalKey<IntroductionScreenState>();
  static const String ONBOARD_KEY = 'has_seen_onboard';

  void _onIntroEnd(context) async {
    // Save that user has seen onboarding
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(ONBOARD_KEY, true);

    // Navigate to main screen
    if (!mounted) return;
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => const Songs()));
  }

  Widget _buildImage(String assetName, [double width = 250]) {
    return Icon(
      _getIconData(assetName),
      size: width,
      color: Colors.blue.shade700,
    );
  }

  IconData _getIconData(String name) {
    switch (name) {
      case 'music':
        return Icons.music_note;
      case 'playlist':
        return Icons.queue_music;
      case 'controls':
        return Icons.play_circle_filled;
      default:
        return Icons.music_note;
    }
  }

  @override
  Widget build(BuildContext context) {
    const bodyStyle = TextStyle(fontSize: 19.0);

    const pageDecoration = PageDecoration(
      titleTextStyle: TextStyle(
        fontSize: 28.0,
        fontWeight: FontWeight.w700,
        color: Colors.blue,
      ),
      bodyTextStyle: bodyStyle,
      bodyPadding: EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
      pageColor: Colors.white,
      imagePadding: EdgeInsets.zero,
    );

    return IntroductionScreen(
      key: introKey,
      globalBackgroundColor: Colors.white,
      pages: [
        PageViewModel(
          title: "Welcome to Music Player",
          body:
              "Your personal music companion. Listen to your favorite songs with style and convenience.",
          image: _buildImage('music'),
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: "Organize Your Music",
          body:
              "Create custom playlists, mark favorites, and keep your music perfectly organized.",
          image: _buildImage('playlist'),
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: "Advanced Playback Controls",
          body:
              "Enjoy features like shuffle, repeat, equalizer and smooth playback controls.",
          image: _buildImage('controls'),
          decoration: pageDecoration,
        ),
      ],
      onDone: () => _onIntroEnd(context),
      onSkip: () => _onIntroEnd(context),
      showSkipButton: true,
      skipOrBackFlex: 0,
      nextFlex: 0,
      showBackButton: false,
      back: const Icon(Icons.arrow_back),
      skip: const Text(
        'Skip',
        style: TextStyle(fontWeight: FontWeight.w600, color: Colors.blue),
      ),
      next: const Icon(Icons.arrow_forward, color: Colors.blue),
      done: const Text(
        'Done',
        style: TextStyle(fontWeight: FontWeight.w600, color: Colors.blue),
      ),
      curve: Curves.fastLinearToSlowEaseIn,
      controlsMargin: const EdgeInsets.all(16),
      dotsDecorator: DotsDecorator(
        size: const Size(10.0, 10.0),
        color: Colors.grey,
        activeColor: Colors.blue,
        activeSize: const Size(22.0, 10.0),
        activeShape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(25.0)),
        ),
      ),
    );
  }
}

class OnboardingService {
  static const String ONBOARD_KEY = 'has_seen_onboard';

  static Future<bool> hasSeenOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(ONBOARD_KEY) ?? false;
  }
}
