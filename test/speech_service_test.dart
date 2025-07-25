import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_template/services/speech_service.dart';

void main() {
  group('SpeechService Tests', () {
    late SpeechService speechService;

    setUp(() {
      speechService = SpeechService();
    });

    test('should create singleton instance', () {
      final instance1 = SpeechService();
      final instance2 = SpeechService();
      expect(instance1, equals(instance2));
    });

    test('should have initial state as not initialized', () {
      expect(speechService.isInitialized, false);
      expect(speechService.isListening, false);
      expect(speechService.lastWords, '');
    });

    test('should provide stream controllers', () {
      expect(speechService.isListeningStream, isA<Stream<bool>>());
      expect(speechService.wordsStream, isA<Stream<String>>());
      expect(speechService.errorStream, isA<Stream<String>>());
    });

    test('should handle dispose properly', () {
      expect(() => speechService.dispose(), returnsNormally);
    });
  });
}
