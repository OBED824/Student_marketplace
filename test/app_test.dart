import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:student_marketplace_simple/app_state.dart';
import 'package:student_marketplace_simple/helpers.dart';

Future<AppState> newState() async {
  SharedPreferences.setMockInitialValues({});
  final state = AppState(await SharedPreferences.getInstance());
  state.load();
  await state.seedIfEmpty();
  return state;
}

void main() {
  test('validators', () {
    expect(validateUniversityEmail('a@students.mak.ac.ug'), isNull);
    expect(validateUniversityEmail('a@gmail.com'), isNotNull);
    expect(validatePhone('0771234567'), isNull);
    expect(validatePhone('123'), isNotNull);
    expect(validatePassword('abc123'), isNull);
    expect(validatePassword('abcdef'), isNotNull);
  });

  test('ugx formatting', () => expect(ugx(1450000), 'UGX 1,450,000'));

  test('login works with demo account, fails with wrong password', () async {
    final state = await newState();
    expect(await state.login('aisha@students.mak.ac.ug', 'wrong1'), isNotNull);
    expect(await state.login('aisha@students.mak.ac.ug', 'password123'), isNull);
    expect(state.isLoggedIn, isTrue);
  });

  test('register rejects duplicate email', () async {
    final state = await newState();
    final err = await state.register(
        name: 'Test', email: 'aisha@students.mak.ac.ug', phone: '0771234567', password: 'abc123', university: 'Other', campus: 'Main Campus');
    expect(err, isNotNull);
  });

  test('search, category filter and favorites', () async {
    final state = await newState();
    await state.login('aisha@students.mak.ac.ug', 'password123');
    state.setFilters(category: 'Phones');
    expect(state.feed.every((p) => p.category == 'Phones'), isTrue);
    state.setFilters(clearCategory: true, search: 'laptop');
    expect(state.feed.isNotEmpty, isTrue);

    final p = state.productById('p2')!; // Brian's laptop
    await state.toggleFavorite(p);
    expect(state.isFavorite('p2'), isTrue);
    // Brian got a notification
    expect(state.notifications.any((n) => n.userId == 'u2'), isTrue);
  });

  test('sold items leave the feed', () async {
    final state = await newState();
    await state.login('aisha@students.mak.ac.ug', 'password123');
    final before = state.feed.length;
    await state.setSold(state.productById('p1')!, true);
    expect(state.feed.length, before - 1);
  });
}
