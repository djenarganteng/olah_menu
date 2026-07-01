import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:olah_menu/services/onboarding_service.dart';

void main() {
  test('OnboardingService marks completion in shared preferences', () async {
    SharedPreferences.setMockInitialValues({});

    expect(await OnboardingService.isCompleted(), isFalse);

    await OnboardingService.markCompleted();

    expect(await OnboardingService.isCompleted(), isTrue);
  });
}
