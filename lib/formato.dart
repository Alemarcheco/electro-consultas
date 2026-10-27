import 'dart:math';

import 'package:flutter/services.dart';

/// Lee un número escrito con coma o con punto decimal.
double? leerNumero(String texto) {
  final t = texto.trim().replaceAll(',', '.');
  if (t.isEmpty) return null;
  return double.tryParse(t);
}

/// Muestra un número con unas [cifras] significativas y coma decimal.
String fmt(double x, {int cifras = 4}) {
  if (x.isNaN || x.isInfinite) return '—';
  if (x == 0) return '0';
  final abs = x.abs();
  String s;
  if (abs >= 1e9 || abs < 1e-4) {
    s = x
        .toStringAsExponential(cifras - 1)
        .replaceFirst('e+', ' × 10^')
        .replaceFirst('e', ' × 10^');
  } else {
    final enteras = (log(abs) / ln10).floor() + 1;
    s = x.toStringAsFixed((cifras - enteras).clamp(0, 8));
    if (s.contains('.')) {
      s = s.replaceFirst(RegExp(r'0+$'), '').replaceFirst(RegExp(r'\.$'), '');
    }
  }
  return s.replaceAll('.', ',');
}

const _prefijos = {
  -12: 'p',
  -9: 'n',
  -6: 'µ',
  -3: 'm',
  0: '',
  3: 'k',
  6: 'M',
  9: 'G',
};

/// Notación de ingeniería con prefijo SI: 4700, 'Ω' → "4,7 kΩ".
String ing(double x, String unidad, {int cifras = 4}) {
  if (x.isNaN || x.isInfinite) return '—';
  if (x == 0) return '0 $unidad';
  var exp = ((log(x.abs()) / ln10) / 3).floor() * 3;
  exp = exp.clamp(-12, 9);
  var valor = x / pow(10, exp);
  // Evita "1000 k" por redondeo.
  if (double.parse(valor.toStringAsPrecision(cifras)).abs() >= 1000 &&
      exp < 9) {
    exp += 3;
    valor = x / pow(10, exp);
  }
  return '${fmt(valor, cifras: cifras)} ${_prefijos[exp]}$unidad';
}

/// Permite escribir números con coma o punto.
final filtroDecimal = FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'));

/// Permite escribir números negativos con coma o punto.
final filtroDecimalConSigno = FilteringTextInputFormatter.allow(
  RegExp(r'[0-9.,\-]'),
);
