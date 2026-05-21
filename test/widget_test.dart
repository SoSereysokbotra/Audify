import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:audify/presentation/auth/screens/login_screen.dart';

void main() {
  testWidgets('Login screen smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: LoginScreen()));

    expect(find.text('Audify'), findsOneWidget);
    expect(find.text('Welcome Back'), findsOneWidget);
  });
}
