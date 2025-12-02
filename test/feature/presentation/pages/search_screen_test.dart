import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/utils/machine.dart';
import 'package:flutter_application_1/feature/cubit/language_cubit.dart';
import 'package:flutter_application_1/feature/presentation/pages/search_screen.dart';
import 'package:flutter_application_1/feature/repositories/machine_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_application_1/l10n/app_localizations.dart';

import 'dart:io';

class MockLanguageCubit extends MockCubit<LanguageState> implements LanguageCubit {}
class MockMachineRepository extends Mock implements MachineRepository {}

class MockHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  }
}

void main() {
  late MockLanguageCubit mockLanguageCubit;
  late MockMachineRepository mockMachineRepository;

  setUp(() {
    HttpOverrides.global = MockHttpOverrides();
    mockLanguageCubit = MockLanguageCubit();
    mockMachineRepository = MockMachineRepository();

    final sl = GetIt.instance;
    if (sl.isRegistered<MachineRepository>()) {
      sl.unregister<MachineRepository>();
    }
    sl.registerLazySingleton<MachineRepository>(() => mockMachineRepository);

    // Mock machine data
    final machines = [
      Machine(
        id: '1',
        name: {'en': 'Bench Press', 'tr': 'Sehpa Presi'},
        description: {'en': 'Chest exercise'},
        imageUrl: 'url',
        videoUrl: 'url',
        bodyPart: 'chest',
        instructions: {'en': ['Step 1']},
        targetMuscles: {'en': ['Chest']},
        difficulty: 'intermediate',
      )
    ];

    when(() => mockMachineRepository.getMachines()).thenAnswer((_) async => machines);
  });

  tearDown(() {
    HttpOverrides.global = null;
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: BlocProvider<LanguageCubit>.value(
        value: mockLanguageCubit,
        child: const SearchScreen(),
      ),
    );
  }

  testWidgets('SearchScreen loads and searches correctly', (tester) async {
    when(() => mockLanguageCubit.state).thenReturn(LanguageState(const Locale('en')));

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pump(); // Trigger loadMachines
    await tester.pump(); // Rebuild after setState

    // Verify initial load
    expect(find.text('Bench Press'), findsOneWidget);

    // Perform search
    await tester.enterText(find.byType(TextField), 'bench');
    await tester.pump();

    // Verify result remains (now RichText)
    expect(find.byWidgetPredicate((widget) {
      if (widget is RichText) {
        final text = widget.text.toPlainText();
        return text.contains('Bench Press');
      }
      return false;
    }), findsOneWidget);

    // Perform search with no match
    await tester.enterText(find.byType(TextField), 'squat');
    await tester.pump();

    // Verify result is gone
    expect(find.text('Bench Press'), findsNothing);
    expect(find.text('No results'), findsOneWidget);
  });

  testWidgets('SearchScreen searches with localized name', (tester) async {
    when(() => mockLanguageCubit.state).thenReturn(LanguageState(const Locale('tr')));

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pump();
    await tester.pump();

    // Verify localized name is shown (MachineGrid uses LanguageCubit too)
    // But wait, MachineGrid uses context.watch, so it should update.
    // However, SearchScreen uses getName(locale) for filtering.
    
    // Search for Turkish name
    await tester.enterText(find.byType(TextField), 'sehpa');
    await tester.pump();

    // Verify result matches
    // Since highlighting is active, it uses RichText.
    expect(find.byWidgetPredicate((widget) {
      if (widget is RichText) {
        final text = widget.text.toPlainText();
        return text.contains('Sehpa');
      }
      return false;
    }), findsOneWidget);
    
    expect(find.text('No results'), findsNothing);
  });
}
