import 'package:electro_consultas/catalogo.dart';
import 'package:electro_consultas/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('la portada muestra las tres secciones', (tester) async {
    await tester.pumpWidget(const ElectroConsultasApp());
    expect(find.text('Código de colores'), findsOneWidget);
    await tester.tap(find.text('Pinouts'));
    await tester.pumpAndSettle();
    expect(find.text('USB 2.0 tipo A / B'), findsOneWidget);
    await tester.tap(find.text('Referencias'));
    await tester.pumpAndSettle();
    expect(find.text('Código de colores de resistencias'), findsOneWidget);
  });

  // Abre cada pantalla en un móvil estrecho para detectar desbordes.
  for (final e in catalogo) {
    testWidgets('abre «${e.titulo}»', (tester) async {
      tester.view.physicalSize = const Size(360 * 3, 740 * 3);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(MaterialApp(home: Builder(builder: e.abrir)));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('la ley de Ohm calcula con dos datos', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: catalogo.firstWhere((e) => e.titulo == 'Ley de Ohm').abrir,
        ),
      ),
    );
    await tester.enterText(find.widgetWithText(TextField, 'Tensión (V)'), '12');
    await tester.enterText(
      find.widgetWithText(TextField, 'Resistencia (R)'),
      '6',
    );
    await tester.pump();
    expect(find.text('2 A'), findsOneWidget);
    expect(find.text('24 W'), findsOneWidget);
  });
}
