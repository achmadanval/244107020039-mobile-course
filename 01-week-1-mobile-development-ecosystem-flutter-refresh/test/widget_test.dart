import 'package:flutter_test/flutter_test.dart';
import 'package:my_first_app/main.dart';

void main() {
  testWidgets('Profil Mahasiswa smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ProfileApp());

    // Verify student name and details are displayed.
    expect(find.text('Profil Mahasiswa'), findsOneWidget);
    expect(find.text('Achmad Anval Adhiem Allain'), findsOneWidget);
    expect(find.text('244107020039'), findsOneWidget);
    expect(find.text('Teknik Informatika'), findsOneWidget);
  });
}
