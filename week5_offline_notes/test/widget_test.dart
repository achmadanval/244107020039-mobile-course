import 'package:flutter_test/flutter_test.dart';
import 'package:week5_offline_notes/data/local/note.dart';

void main() {
  test('Note fromMap & toMap serialization test', () {
    final now = DateTime.now();
    final note = Note(
      id: 1,
      title: 'Judul Catatan',
      body: 'Isi catatan',
      updatedAt: now,
      dirty: true,
    );
    final map = note.toMap();
    final parsed = Note.fromMap(map);

    expect(parsed.id, 1);
    expect(parsed.title, 'Judul Catatan');
    expect(parsed.body, 'Isi catatan');
    expect(parsed.dirty, true);
  });
}
