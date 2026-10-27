import 'package:electro_consultas/calc/codigos.dart';
import 'package:electro_consultas/catalogo.dart';
import 'package:electro_consultas/formato.dart';
import 'package:electro_consultas/pantallas/calc_basicos.dart';
import 'package:electro_consultas/pantallas/calc_instalaciones.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('formato de ingeniería', () {
    expect(ing(4700, 'Ω'), '4,7 kΩ');
    expect(ing(0.0001, 'F'), '100 µF');
    expect(ing(999999, 'Ω'), '1 MΩ');
    expect(ing(1.5e6, 'Hz'), '1,5 MHz');
    expect(ing(0, 'V'), '0 V');
    expect(fmt(3.14159), '3,142');
  });

  test('bandas de colores', () {
    expect(
      valorBandas([banda('Amarillo'), banda('Violeta')], banda('Rojo')),
      4700,
    );
    expect(
      valorBandas([
        banda('Marrón'),
        banda('Negro'),
        banda('Negro'),
      ], banda('Marrón')),
      1000,
    );
    expect(
      valorBandas([banda('Rojo'), banda('Rojo')], banda('Oro')),
      closeTo(2.2, 1e-9),
    );
    final b = bandasPara(4700, 2)!;
    expect(b.$1.map((c) => c.nombre), ['Amarillo', 'Violeta']);
    expect(b.$2.nombre, 'Rojo');
    final c = bandasPara(0.47, 2)!;
    expect(c.$2.nombre, 'Plata');
    final d = bandasPara(12345, 3)!;
    expect(d.$3, 12300);
    expect(bandasPara(220, 3)!.$2.nombre, 'Negro');
  });

  test('valores normalizados', () {
    expect(valorNormalizado(4500, serieE24), 4700);
    expect(valorNormalizado(150, serieE24, porArriba: true), 150);
    expect(valorNormalizado(151, serieE24, porArriba: true), 160);
    expect(valorNormalizado(9.5, serieE12, porArriba: true), 10);
  });

  test('SMD', () {
    expect(decodificarSmd('103'), 10000);
    expect(decodificarSmd('4R7'), closeTo(4.7, 1e-9));
    expect(decodificarSmd('R10'), closeTo(0.1, 1e-9));
    expect(decodificarSmd('1002'), 10000);
    expect(decodificarSmd('01C'), 10000);
    expect(decodificarSmd('68X'), closeTo(49.9, 1e-9));
    expect(decodificarSmd('4k7'), closeTo(4700, 1e-9));
    expect(decodificarSmd('000'), 0);
    expect(() => decodificarSmd('ZZZ'), throwsA(isA<ErrorCodigo>()));
  });

  test('condensadores', () {
    expect(decodificarCondensador('104').$1, closeTo(100e-9, 1e-15));
    expect(decodificarCondensador('104K').$2, '±10 %');
    expect(decodificarCondensador('4n7').$1, closeTo(4.7e-9, 1e-15));
    expect(decodificarCondensador('2u2').$1, closeTo(2.2e-6, 1e-12));
    expect(decodificarCondensador('p47').$1, closeTo(0.47e-12, 1e-18));
    expect(decodificarCondensador('22').$1, closeTo(22e-12, 1e-18));
    expect(decodificarCondensador('109').$1, closeTo(1e-12, 1e-18));
    expect(codigoCondensador(100e-9), '104');
    expect(codigoCondensador(4.7e-9), '472');
    expect(codigoCondensador(10e-12), '100');
  });

  test('caída de tensión', () {
    // 2 × 25 m × 16 A / (48 × 2,5) = 6,67 V
    expect(
      caidaTension(
        sistema: Sistema.monofasica,
        longitud: 25,
        corriente: 16,
        seccion: 2.5,
        conductividad: 48,
      ),
      closeTo(6.667, 0.001),
    );
  });

  test('AWG', () {
    expect(seccionAwg(14), closeTo(2.08, 0.01));
    expect(seccionAwg(10), closeTo(5.26, 0.01));
  });

  test('búsqueda', () {
    expect(buscar('arduino').length, greaterThan(5));
    expect(buscar('RESISTÉNCIA').isNotEmpty, true);
    expect(
      buscar('ethernet').map((e) => e.titulo),
      contains('RJ45 Ethernet T568B'),
    );
  });
}
