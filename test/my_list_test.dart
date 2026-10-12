import 'package:cineflix/models/movie.dart';
import 'package:cineflix/screens/movie/movie_details_screen.dart';
import 'package:cineflix/screens/my_list/my_list_screen.dart';
import 'package:cineflix/services/movie_seed_service.dart';
import 'package:cineflix/services/my_list_service.dart';
import 'package:cineflix/theme/app_theme.dart';
import 'package:cineflix/widgets/movie_card.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeUser extends Fake implements User {
  final String _userUid;
  final String _userEmail;

  FakeUser({String uid = 'user-123', String email = 'user1@example.com'})
      : _userUid = uid,
        _userEmail = email;

  @override
  String get uid => _userUid;

  @override
  String get email => _userEmail;

  @override
  String get displayName => 'Demo User';
}

class MockMyListService extends MyListService {
  final Map<String, List<Movie>> _userLists = {};

  List<Movie> _getList(String? userId) {
    final uid = userId ?? 'default-user';
    return _userLists.putIfAbsent(uid, () => []);
  }

  @override
  Future<bool> addToMyList(Movie movie, {String? userId}) async {
    final list = _getList(userId);
    if (!list.any((m) => m.id == movie.id)) {
      list.add(movie);
    }
    return true;
  }

  @override
  Future<bool> removeFromMyList(String movieId, {String? userId}) async {
    final list = _getList(userId);
    list.removeWhere((m) => m.id == movieId);
    return true;
  }

  @override
  Future<bool> isInMyList(String movieId, {String? userId}) async {
    final list = _getList(userId);
    return list.any((m) => m.id == movieId);
  }

  @override
  Future<List<Movie>> getMyList({String? userId}) async {
    return List<Movie>.from(_getList(userId));
  }

  @override
  Stream<List<Movie>> watchMyList({String? userId}) {
    return Stream.value(List<Movie>.from(_getList(userId)));
  }

  @override
  Stream<bool> watchIsInMyList(String movieId, {String? userId}) {
    return Stream.value(_getList(userId).any((m) => m.id == movieId));
  }
}

void main() {
  final List<Movie> demoMovies = MovieSeedService.initialDemoMovies;
  late FakeUser userA;
  late FakeUser userB;
  late MockMyListService myListService;

  setUp(() {
    userA = FakeUser(uid: 'user-A', email: 'usera@example.com');
    userB = FakeUser(uid: 'user-B', email: 'userb@example.com');
    myListService = MockMyListService();
  });

  group('MyListService Unit Tests', () {
    test('addToMyList and isInMyList for User A', () async {
      final movie = demoMovies[0]; // Neon City

      expect(await myListService.isInMyList(movie.id, userId: userA.uid), false);

      final added = await myListService.addToMyList(movie, userId: userA.uid);
      expect(added, true);

      expect(await myListService.isInMyList(movie.id, userId: userA.uid), true);
    });

    test('removeFromMyList for User A', () async {
      final movie = demoMovies[0];

      await myListService.addToMyList(movie, userId: userA.uid);
      expect(await myListService.isInMyList(movie.id, userId: userA.uid), true);

      final removed = await myListService.removeFromMyList(movie.id, userId: userA.uid);
      expect(removed, true);

      expect(await myListService.isInMyList(movie.id, userId: userA.uid), false);
    });

    test('getMyList returns saved movies for user', () async {
      final m1 = demoMovies[0];
      final m2 = demoMovies[1];

      await myListService.addToMyList(m1, userId: userA.uid);
      await myListService.addToMyList(m2, userId: userA.uid);

      final saved = await myListService.getMyList(userId: userA.uid);
      expect(saved.length, equals(2));
      expect(saved.map((m) => m.id), containsAll([m1.id, m2.id]));
    });

    test('User isolation: User B cannot see User A My List items', () async {
      final movie = demoMovies[0];

      await myListService.addToMyList(movie, userId: userA.uid);

      expect(await myListService.isInMyList(movie.id, userId: userA.uid), true);
      expect(await myListService.isInMyList(movie.id, userId: userB.uid), false);

      final listA = await myListService.getMyList(userId: userA.uid);
      final listB = await myListService.getMyList(userId: userB.uid);

      expect(listA.length, equals(1));
      expect(listB.length, equals(0));
    });

    test('watchMyList emits updated list on changes', () async {
      final movie = demoMovies[2];
      await myListService.addToMyList(movie, userId: userA.uid);

      final stream = myListService.watchMyList(userId: userA.uid);
      final list = await stream.first;

      expect(list.length, equals(1));
      expect(list.first.id, equals(movie.id));
    });
  });

  group('MyListScreen UI Tests', () {
    testWidgets('Renders empty state when user list is empty', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: MyListScreen(
            user: userA,
            myListService: myListService,
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Your List is Empty'), findsOneWidget);
      expect(find.text('Movies you add to My List will appear here.'), findsOneWidget);
      expect(find.widgetWithText(ElevatedButton, 'Browse Movies'), findsOneWidget);
    });

    testWidgets('Renders movie grid when items are in user My List', (WidgetTester tester) async {
      final m1 = demoMovies[0];
      final m2 = demoMovies[1];
      await myListService.addToMyList(m1, userId: userA.uid);
      await myListService.addToMyList(m2, userId: userA.uid);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: MyListScreen(
            user: userA,
            myListService: myListService,
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.text('My List (2)'), findsOneWidget);
      expect(find.byType(MovieCard), findsNWidgets(2));
      expect(find.text(m1.title), findsAtLeastNWidgets(1));
      expect(find.text(m2.title), findsAtLeastNWidgets(1));
    });
  });

  group('MovieDetailsScreen Interactive My List Button Tests', () {
    testWidgets('Button toggles state and calls MyListService on tap', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1200, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final movie = demoMovies[0];

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: MovieDetailsScreen(
            movie: movie,
            myListService: myListService,
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Initially not saved -> shows '+ Add to My List'
      final addButton = find.widgetWithText(OutlinedButton, '+ Add to My List');
      expect(addButton, findsOneWidget);

      // Tap button to Add
      await tester.ensureVisible(addButton);
      await tester.tap(addButton);
      await tester.pumpAndSettle();

      // Should change button text to '✓ My List'
      final savedButton = find.widgetWithText(OutlinedButton, '✓ My List');
      expect(savedButton, findsOneWidget);
      expect(await myListService.isInMyList(movie.id), true);

      // Tap button to Remove
      await tester.tap(savedButton);
      await tester.pumpAndSettle();

      // Should change back to '+ Add to My List'
      expect(find.widgetWithText(OutlinedButton, '+ Add to My List'), findsOneWidget);
      expect(await myListService.isInMyList(movie.id), false);
    });
  });
}
