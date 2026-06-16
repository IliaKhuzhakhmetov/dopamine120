import 'package:flutter_test/flutter_test.dart';
import 'package:sound_framework_example/main.dart';

void main() {
  testWidgets('renders the sound framework console', (tester) async {
    await tester.pumpWidget(const SoundFrameworkExampleApp());

    expect(find.text('Sound Framework'), findsWidgets);
    expect(find.text('Sounds'), findsOneWidget);
    expect(find.text('Profile Bend'), findsOneWidget);
  });
}
