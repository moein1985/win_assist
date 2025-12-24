import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:win_assist/screens/login_screen.dart';

void main() {
  final sl = GetIt.instance;

  setUp(() {
    sl.registerLazySingleton<Logger>(() => Logger());
  });

  tearDown(() {
    if (sl.isRegistered<Logger>()) sl.unregister<Logger>();
  });

  testWidgets('LoginScreen shows SSH Port field with default 22', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: LoginScreen()));
    await tester.pumpAndSettle();

    // Find the SSH Port field by label
    final portField = find.widgetWithText(TextFormField, 'SSH Port');
    expect(portField, findsOneWidget);

    // Verify initial value is '22'
    final textField = tester.widget<TextFormField>(portField);
    final controller = textField.controller;
    expect(controller?.text, '22');
  });
}
