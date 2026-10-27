import 'package:electro_consultas/solar/dimensionado.dart';
import 'package:electro_consultas/solar/ejemplos.dart';
import 'package:flutter_test/flutter_test.dart';

Resultado _ej(EjemploSolar e) => dimensionar(
  Configuracion(
    consumos: e.consumos(),
    hsp: e.hsp,
    vSistema: e.vSistema,
    autonomia: e.autonomia,
    panel: panelPorId(e.panel),
    bateria: bateriaPorId(e.bateria),
    regulador: reguladorPorId(e.regulador),
    inversor: inversorPorId(e.inversor),
  ),
);

void main() {
  for (final e in ejemplosSolares) {
    test('ejemplo «${e.titulo}» sin avisos y coherente', () {
      final r = _ej(e);
      // ignore: avoid_print
      print(
        '${e.titulo}: ${r.whDia.round()} Wh/día, ${r.wSimultanea.round()} W, pico ${r.wArranque.round()} | '
        'PV ${r.nPaneles} (${r.series}S×${r.paralelo}P) ${r.pvInstalada.round()} W | '
        'bat ${r.nBaterias} (${r.batSerie}S×${r.batParalelo}P) ${r.kwhBaterias.toStringAsFixed(1)} kWh | '
        'reg ${r.nReguladores}×${r.regulador?.nombre} ${r.corrienteRegulador.round()} A | inv ${r.inversor?.nombre}\n  ${r.avisos}',
      );
      expect(r.avisos, isEmpty);
      expect(r.whProducidos, greaterThanOrEqualTo(r.whDia * 0.99));
      expect(r.autonomiaReal, greaterThanOrEqualTo(e.autonomia * 0.99));
      expect(
        r.series * panelPorId(e.panel).voc * 1.15,
        lessThanOrEqualTo(r.regulador?.vMaxPv ?? r.inversor!.mpptVmax!),
      );
    });
  }

  test('aviso si el panel grande va con PWM', () {
    final r = dimensionar(
      Configuracion(
        consumos: [Consumo('Luz', 10, 5)],
        hsp: 5,
        vSistema: 12,
        autonomia: 1,
        panel: panelPorId('cs410'),
        bateria: bateriaPorId('lfp12_100'),
        regulador: reguladorPorId('pwm30'),
      ),
    );
    expect(r.avisos.any((a) => a.contains('PWM')), true);
  });

  test('autoconsumo con red', () {
    final r = dimensionarRed(
      kwhMes: 300,
      hsp: 5,
      panel: panelPorId('longi430'),
    );
    expect(r.kwp, closeTo(2.5, 0.01));
    expect(r.paneles, 6);
    expect(r.inversor, isNotNull);
  });
}
