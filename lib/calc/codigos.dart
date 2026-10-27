import 'dart:math';

import 'package:flutter/material.dart';

/// Color de una banda del código de resistencias.
class ColorBanda {
  final String nombre;
  final Color color;
  final int? digito;
  final double? multiplicador;
  final double? tolerancia; // en %
  final int? ppm; // coeficiente de temperatura

  const ColorBanda(
    this.nombre,
    this.color, {
    this.digito,
    this.multiplicador,
    this.tolerancia,
    this.ppm,
  });
}

const coloresBanda = <ColorBanda>[
  ColorBanda('Negro', Color(0xFF000000), digito: 0, multiplicador: 1, ppm: 250),
  ColorBanda(
    'Marrón',
    Color(0xFF7B3F00),
    digito: 1,
    multiplicador: 10,
    tolerancia: 1,
    ppm: 100,
  ),
  ColorBanda(
    'Rojo',
    Color(0xFFE53935),
    digito: 2,
    multiplicador: 100,
    tolerancia: 2,
    ppm: 50,
  ),
  ColorBanda(
    'Naranja',
    Color(0xFFFF8F00),
    digito: 3,
    multiplicador: 1e3,
    tolerancia: 0.05,
    ppm: 15,
  ),
  ColorBanda(
    'Amarillo',
    Color(0xFFFDD835),
    digito: 4,
    multiplicador: 1e4,
    tolerancia: 0.02,
    ppm: 25,
  ),
  ColorBanda(
    'Verde',
    Color(0xFF43A047),
    digito: 5,
    multiplicador: 1e5,
    tolerancia: 0.5,
    ppm: 20,
  ),
  ColorBanda(
    'Azul',
    Color(0xFF1E88E5),
    digito: 6,
    multiplicador: 1e6,
    tolerancia: 0.25,
    ppm: 10,
  ),
  ColorBanda(
    'Violeta',
    Color(0xFF8E24AA),
    digito: 7,
    multiplicador: 1e7,
    tolerancia: 0.1,
    ppm: 5,
  ),
  ColorBanda(
    'Gris',
    Color(0xFF9E9E9E),
    digito: 8,
    multiplicador: 1e8,
    tolerancia: 0.01,
    ppm: 1,
  ),
  ColorBanda('Blanco', Color(0xFFFFFFFF), digito: 9, multiplicador: 1e9),
  ColorBanda('Oro', Color(0xFFD4AF37), multiplicador: 0.1, tolerancia: 5),
  ColorBanda('Plata', Color(0xFFC0C0C0), multiplicador: 0.01, tolerancia: 10),
  ColorBanda('Ninguno', Color(0x00000000), tolerancia: 20),
];

ColorBanda banda(String nombre) =>
    coloresBanda.firstWhere((c) => c.nombre == nombre);

/// Valor en ohmios a partir de las bandas de cifras y el multiplicador.
double valorBandas(List<ColorBanda> cifras, ColorBanda multiplicador) {
  var n = 0;
  for (final c in cifras) {
    n = n * 10 + c.digito!;
  }
  return n * multiplicador.multiplicador!;
}

/// Colores de cifras y multiplicador para [ohmios] con [nCifras] cifras
/// significativas (2 para 4 bandas, 3 para 5 y 6 bandas).
/// Devuelve null si el valor no se puede representar.
(List<ColorBanda>, ColorBanda, double)? bandasPara(double ohmios, int nCifras) {
  if (ohmios <= 0) return null;
  // Exponente para que queden nCifras enteras.
  var exp = (log(ohmios) / ln10).floor() - (nCifras - 1);
  var n = (ohmios / pow(10, exp)).round();
  if (n >= pow(10, nCifras)) {
    n ~/= 10;
    exp += 1;
  }
  if (exp < -2 || exp > 9) return null;
  final digitos = n.toString().padLeft(nCifras, '0').split('').map(int.parse);
  final cifras = [for (final d in digitos) coloresBanda[d]];
  final mult = exp >= 0
      ? coloresBanda[exp]
      : (exp == -1 ? banda('Oro') : banda('Plata'));
  return (cifras, mult, n * pow(10, exp).toDouble());
}

/// Series normalizadas de valores (década 1–10).
const serieE6 = [1.0, 1.5, 2.2, 3.3, 4.7, 6.8];
const serieE12 = [1.0, 1.2, 1.5, 1.8, 2.2, 2.7, 3.3, 3.9, 4.7, 5.6, 6.8, 8.2];
const serieE24 = [
  1.0, 1.1, 1.2, 1.3, 1.5, 1.6, 1.8, 2.0, 2.2, 2.4, 2.7, 3.0, //
  3.3, 3.6, 3.9, 4.3, 4.7, 5.1, 5.6, 6.2, 6.8, 7.5, 8.2, 9.1,
];

/// Valores E96 en el orden del código EIA-96 (01 = 100 … 96 = 976).
const eia96 = [
  100, 102, 105, 107, 110, 113, 115, 118, 121, 124, 127, 130, 133, 137, //
  140, 143, 147, 150, 154, 158, 162, 165, 169, 174, 178, 182, 187, 191,
  196, 200, 205, 210, 215, 221, 226, 232, 237, 243, 249, 255, 261, 267,
  274, 280, 287, 294, 301, 309, 316, 324, 332, 340, 348, 357, 365, 374,
  383, 392, 402, 412, 422, 432, 442, 453, 464, 475, 487, 499, 511, 523,
  536, 549, 562, 576, 590, 604, 619, 634, 649, 665, 681, 698, 715, 732,
  750, 768, 787, 806, 825, 845, 866, 887, 909, 931, 953, 976,
];

/// Valor normalizado de [serie] más cercano a [x]. Con [porArriba] devuelve
/// el menor valor normalizado que sea ≥ x.
double valorNormalizado(
  double x,
  List<double> serie, {
  bool porArriba = false,
}) {
  if (x <= 0) return 0;
  final dec = pow(10, (log(x) / ln10).floor()).toDouble();
  final candidatos = <double>[
    for (final f in [dec / 10, dec, dec * 10])
      for (final s in serie) double.parse((s * f).toStringAsPrecision(3)),
  ];
  if (porArriba) {
    return candidatos.where((c) => c >= x * (1 - 1e-9)).reduce(min);
  }
  // Cercanía en escala logarítmica.
  candidatos.sort((a, b) => (log(a / x)).abs().compareTo((log(b / x)).abs()));
  return candidatos.first;
}

class ErrorCodigo implements Exception {
  final String mensaje;
  ErrorCodigo(this.mensaje);
  @override
  String toString() => mensaje;
}

/// Decodifica el código impreso en una resistencia SMD: "103", "4R7",
/// "1002", "4K7" o EIA-96 como "01C". Devuelve ohmios.
double decodificarSmd(String codigo) {
  final c = codigo.trim().toUpperCase().replaceAll(' ', '');
  if (c.isEmpty) throw ErrorCodigo('Escribe el código.');
  // Letra como coma decimal (BS 1852): 4R7 = 4,7 Ω, R47 = 0,47 Ω, 4K7 = 4,7 kΩ.
  final conR = RegExp(r'^(\d*)([RKM])(\d*)$').firstMatch(c);
  if (conR != null && (conR[1]! + conR[3]!).isNotEmpty) {
    final v = double.parse(
      '${conR[1]!.isEmpty ? '0' : conR[1]}.${conR[3]!.isEmpty ? '0' : conR[3]}',
    );
    return v * const {'R': 1.0, 'K': 1e3, 'M': 1e6}[conR[2]]!;
  }
  // EIA-96: dos cifras + letra.
  final eia = RegExp(r'^(\d\d)([ZYRXSABHCDEF])$').firstMatch(c);
  if (eia != null) {
    final i = int.parse(eia[1]!);
    if (i < 1 || i > 96) {
      throw ErrorCodigo('En EIA-96 el número va de 01 a 96.');
    }
    const mult = {
      'Z': 0.001, 'Y': 0.01, 'R': 0.01, 'X': 0.1, 'S': 0.1, 'A': 1.0, //
      'B': 10.0, 'H': 10.0, 'C': 100.0, 'D': 1e3, 'E': 1e4, 'F': 1e5,
    };
    return eia96[i - 1] * mult[eia[2]]!;
  }
  if (RegExp(r'^\d{3,4}$').hasMatch(c)) {
    if (RegExp(r'^0+$').hasMatch(c)) return 0;
    final cifras = int.parse(c.substring(0, c.length - 1));
    final exp = int.parse(c[c.length - 1]);
    return cifras * pow(10, exp).toDouble();
  }
  if (c == '0' || c == '00') return 0;
  throw ErrorCodigo('Formato no reconocido. Ejemplos: 103, 4R7, 1002, 01C.');
}

const toleranciasCondensador = {
  'B': '±0,1 pF',
  'C': '±0,25 pF',
  'D': '±0,5 pF',
  'F': '±1 %',
  'G': '±2 %',
  'J': '±5 %',
  'K': '±10 %',
  'M': '±20 %',
  'Z': '+80 % / −20 %',
};

/// Decodifica el código de un condensador: "104", "4n7", "2u2", "p47",
/// "104K". Devuelve (faradios, tolerancia o null).
(double, String?) decodificarCondensador(String codigo) {
  var c = codigo.trim().replaceAll(' ', '').replaceAll('µ', 'u');
  if (c.isEmpty) throw ErrorCodigo('Escribe el código.');
  String? tol;
  final ultima = c[c.length - 1].toUpperCase();
  if (c.length >= 2 &&
      toleranciasCondensador.containsKey(ultima) &&
      RegExp(r'\d').hasMatch(c[c.length - 2])) {
    tol = toleranciasCondensador[ultima];
    c = c.substring(0, c.length - 1);
  }
  // Letra como coma decimal: 4n7, 2u2, p47, 1m.
  final conLetra = RegExp(r'^(\d*)([pPnNuUmM])(\d*)$').firstMatch(c);
  if (conLetra != null && (conLetra[1]! + conLetra[3]!).isNotEmpty) {
    final v = double.parse(
      '${conLetra[1]!.isEmpty ? '0' : conLetra[1]}.${conLetra[3]!.isEmpty ? '0' : conLetra[3]}',
    );
    const f = {'p': 1e-12, 'n': 1e-9, 'u': 1e-6, 'm': 1e-3};
    return (v * f[conLetra[2]!.toLowerCase()]!, tol);
  }
  if (RegExp(r'^\d{3}$').hasMatch(c)) {
    final cifras = int.parse(c.substring(0, 2));
    final d = int.parse(c[2]);
    final mult = switch (d) {
      8 => 0.01,
      9 => 0.1,
      _ => pow(10, d).toDouble(),
    };
    if (d == 6 || d == 7) {
      throw ErrorCodigo('El tercer dígito 6 o 7 no se usa en condensadores.');
    }
    return (cifras * mult * 1e-12, tol);
  }
  if (RegExp(r'^\d{1,2}$').hasMatch(c)) {
    return (int.parse(c) * 1e-12, tol);
  }
  // Decimales sin unidad (p. ej. ".1" o "0.047"): microfaradios.
  final dec = double.tryParse(c.replaceAll(',', '.'));
  if (dec != null && dec < 1) return (dec * 1e-6, tol);
  throw ErrorCodigo('Formato no reconocido. Ejemplos: 104, 4n7, 2u2, 103J.');
}

/// Código de 3 cifras para una capacidad en faradios (≥ 10 pF).
String? codigoCondensador(double faradios) {
  final pf = faradios / 1e-12;
  if (pf < 10 - 1e-9) return null;
  var exp = (log(pf) / ln10).floor() - 1;
  var n = (pf / pow(10, exp)).round();
  if (n >= 100) {
    n ~/= 10;
    exp += 1;
  }
  if (exp > 5) return null;
  return '$n$exp';
}
