import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lottie/lottie.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'splash logo animation is bundled and plays past the native frame',
    () async {
      final bytes = await rootBundle.load('assets/animations/splash_logo.json');

      final composition = await LottieComposition.fromByteData(bytes);

      // SplashScreen starts playing from frame 35, the native splash still.
      expect(composition.durationFrames, greaterThan(35));
    },
  );
}
