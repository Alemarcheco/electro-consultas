import 'dart:math';

import 'equipos.dart';

/// Un aparato de la lista de consumos.
class Consumo {
  String nombre;
  double w;
  double horas;
  int cantidad;
  double arranque;

  Consumo(
    this.nombre,
    this.w,
    this.horas, {
    this.cantidad = 1,
    this.arranque = 1,
  });

  Consumo.de(Aparato a, {int cantidad = 1, double? horas})
    : this(
        a.nombre,
        a.w,
        horas ?? a.horas,
        cantidad: cantidad,
        arranque: a.arranque,
      );

  double get whDia => w * horas * cantidad;
  double get wTotal => w * cantidad;
}

class Configuracion {
  final List<Consumo> consumos;
  final double hsp;
  final int vSistema;
  final double autonomia;
  final Panel panel;
  final Bateria bateria;

  /// null = elegir automáticamente.
  final Regulador? regulador;
  final Inversor? inversor;

  /// Rendimiento global (pérdidas por temperatura, suciedad, cables,
  /// batería e inversor).
  final double rendimiento;

  const Configuracion({
    required this.consumos,
    required this.hsp,
    required this.vSistema,
    required this.autonomia,
    required this.panel,
    required this.bateria,
    this.regulador,
    this.inversor,
    this.rendimiento = 0.75,
  });
}

class Resultado {
  final double whDia;
  final double wSimultanea;
  final double wArranque;
  final double pvNecesaria;
  final int series;
  final int paralelo;
  final double whBanco;
  final double ahBanco;
  final int batSerie;
  final int batParalelo;
  final Inversor? inversor;
  final Regulador? regulador;
  final int nReguladores;
  final double corrienteRegulador;
  final List<String> avisos;
  final Configuracion config;

  const Resultado({
    required this.whDia,
    required this.wSimultanea,
    required this.wArranque,
    required this.pvNecesaria,
    required this.series,
    required this.paralelo,
    required this.whBanco,
    required this.ahBanco,
    required this.batSerie,
    required this.batParalelo,
    required this.inversor,
    required this.regulador,
    required this.nReguladores,
    required this.corrienteRegulador,
    required this.avisos,
    required this.config,
  });

  int get nPaneles => series * paralelo;
  double get pvInstalada => nPaneles * config.panel.w;
  int get nBaterias => batSerie * batParalelo;
  double get kwhBaterias => nBaterias * config.bateria.kwh;

  /// Energía media que producen los paneles al día.
  double get whProducidos => pvInstalada * config.hsp * config.rendimiento;

  /// Días que aguanta el banco sin sol, usando la descarga recomendada.
  double get autonomiaReal =>
      kwhBaterias * 1000 * config.bateria.dod * 0.9 / whDia;
}

/// Tensión a la que carga el banco (≈ 14,4 V por cada 12 V).
double tensionCarga(int vSistema) => vSistema * 1.2;

/// Elige paneles en serie y ramas en paralelo para un regulador MPPT.
/// Devuelve null si ninguna combinación cabe en [vMax].
(int, int)? _seriesMppt(Panel p, int n, int vSistema, double vMax) {
  final vocFrio = p.voc * 1.15; // a unos −10 °C
  final sMax = (vMax / vocFrio).floor();
  final sMin = max(1, ((tensionCarga(vSistema) + 5) / p.vmp).ceil());
  if (sMax < sMin) return null;
  (int, int)? mejor;
  for (var s = min(sMax, max(n, sMin)); s >= sMin; s--) {
    final par = (n / s).ceil();
    if (mejor == null || s * par < mejor.$1 * mejor.$2) mejor = (s, par);
  }
  return mejor;
}

Resultado dimensionar(Configuracion c) {
  final avisos = <String>[];
  final v = c.vSistema;
  final whDia = c.consumos.fold(0.0, (a, x) => a + x.whDia);
  final wSim = c.consumos.fold(0.0, (a, x) => a + x.wTotal);
  // Peor caso: arranca el aparato con mayor pico mientras el resto funciona.
  final extraArranque = c.consumos.fold(
    0.0,
    (a, x) => max(a, x.w * (x.arranque - 1)),
  );
  final wArranque = wSim + extraArranque;

  if (v == 12 && wSim > 1500) {
    avisos.add(
      'Con más de 1500 W simultáneos conviene un sistema de 24 V o 48 V (menos corriente y cables más finos).',
    );
  } else if (v == 24 && wSim > 3500) {
    avisos.add('Con más de 3500 W simultáneos conviene un sistema de 48 V.');
  }

  // ── Paneles ──
  final pv = whDia / (c.hsp * c.rendimiento);
  final n = max(1, (pv / c.panel.w - 0.02).ceil());

  // ── Inversor ──
  Inversor? inv = c.inversor;
  final wInv = wSim * 1.25;
  if (inv == null) {
    final aptos =
        inversores
            .where(
              (i) => i.vBateria == v && i.w >= wInv && i.wPico >= wArranque,
            )
            .toList()
          ..sort((a, b) {
            final p = a.w.compareTo(b.w);
            if (p != 0) return p;
            return (b.hibrido ? 1 : 0) - (a.hibrido ? 1 : 0);
          });
    inv = aptos.isEmpty ? null : aptos.first;
    if (inv == null && wSim > 0) {
      avisos.add(
        'Ningún inversor del catálogo de $v V cubre ${wInv.round()} W: sube la tensión del sistema o reparte los consumos.',
      );
    }
  } else {
    if (inv.vBateria != v) {
      avisos.add(
        'El inversor ${inv.nombre} es de ${inv.vBateria} V y el sistema de $v V.',
      );
    }
    if (inv.w < wInv) {
      avisos.add(
        'El inversor ${inv.nombre} da ${inv.w.round()} W y se recomiendan ${wInv.round()} W (consumo simultáneo + 25 %).',
      );
    }
    if (inv.wPico < wArranque) {
      avisos.add(
        'El pico de arranque (${wArranque.round()} W) supera el del inversor (${inv.wPico.round()} W).',
      );
    }
  }

  // ── Regulador y conexión de paneles ──
  Regulador? reg;
  var nReg = 1;
  int series, paralelo;
  final usaHibrido = inv != null && inv.hibrido && c.regulador == null;
  final iEstimada = n * c.panel.w / tensionCarga(v);
  if (usaHibrido) {
    final sp = _seriesMppt(c.panel, n, v, inv.mpptVmax!);
    if (sp == null) {
      avisos.add(
        'El panel ${c.panel.nombre} no cabe en la entrada FV del inversor (${inv.mpptVmax!.round()} V).',
      );
      (series, paralelo) = (1, n);
    } else {
      (series, paralelo) = sp;
    }
    final wInst = series * paralelo * c.panel.w;
    if (wInst > inv.mpptW! * 1.0 ||
        wInst / tensionCarga(v) > inv.mpptAmperios!) {
      avisos.add(
        'La potencia FV (${wInst.round()} W) supera la del regulador interno del inversor (${inv.mpptW!.round()} W): añade un regulador MPPT aparte.',
      );
    }
  } else {
    final candidatos = c.regulador != null
        ? [c.regulador!]
        : reguladores
              .where(
                (r) =>
                    r.tensiones.contains(v) &&
                    (r.tipo == TipoRegulador.mppt || c.panel.de12V),
              )
              .toList();
    // El primero que lo cubre con un solo equipo; si no, el más grande repetido.
    reg = candidatos.firstWhere(
      (r) =>
          _corriente(r, c.panel, n, v) <= r.amperios && _cabe(r, c.panel, n, v),
      orElse: () =>
          candidatos.reduce((a, b) => a.amperios >= b.amperios ? a : b),
    );
    if (!reg.tensiones.contains(v)) {
      avisos.add('El regulador ${reg.nombre} no admite baterías de $v V.');
    }
    if (reg.tipo == TipoRegulador.pwm) {
      if (!c.panel.de12V) {
        avisos.add(
          'Con un regulador PWM solo sirven paneles de 12 V nominales (36 células). Con este panel usa MPPT.',
        );
      }
      series = max(1, v ~/ 12);
      paralelo = (n / series).ceil();
    } else {
      final sp = _seriesMppt(c.panel, n, v, reg.vMaxPv);
      if (sp == null) {
        avisos.add(
          'El panel ${c.panel.nombre} supera la tensión máxima del ${reg.nombre} (${reg.vMaxPv.round()} V).',
        );
        (series, paralelo) = (1, n);
      } else {
        (series, paralelo) = sp;
      }
    }
    nReg = max(
      1,
      (_corriente(reg, c.panel, series * paralelo, v) / reg.amperios - 0.001)
          .ceil(),
    );
    if (nReg > 1) {
      avisos.add(
        'Hacen falta $nReg reguladores ${reg.nombre}, cada uno con su grupo de paneles.',
      );
    }
  }

  // ── Baterías ──
  final whBanco = whDia * c.autonomia / (c.bateria.dod * 0.9);
  final ahBanco = whBanco / v;
  var batSerie = 1;
  if (c.bateria.vNominal > v) {
    avisos.add(
      'La batería ${c.bateria.nombre} es de ${c.bateria.vNominal} V: no sirve para un sistema de $v V.',
    );
  } else {
    batSerie = v ~/ c.bateria.vNominal;
  }
  final batParalelo = max(1, (ahBanco / c.bateria.ah - 0.02).ceil());
  if (batParalelo > 4 && c.bateria.quimica != Quimica.litio) {
    avisos.add(
      'Más de 4 ramas de baterías de plomo en paralelo se descompensan: elige baterías de más capacidad.',
    );
  }
  final iCarga = usaHibrido
      ? series * paralelo * c.panel.w / tensionCarga(v)
      : nReg * (reg?.amperios ?? 0);
  if (c.bateria.quimica != Quimica.litio &&
      iCarga > batParalelo * c.bateria.ah * 0.25) {
    avisos.add(
      'La corriente de carga (${iCarga.round()} A) es alta para baterías de plomo de ${(batParalelo * c.bateria.ah).round()} Ah (máx. ≈ 20 % de la capacidad).',
    );
  }
  if (c.hsp < 3) {
    avisos.add(
      'Con menos de 3 HSP el sistema sale muy grande; revisa el dato de tu zona.',
    );
  }

  return Resultado(
    whDia: whDia,
    wSimultanea: wSim,
    wArranque: wArranque,
    pvNecesaria: pv,
    series: series,
    paralelo: paralelo,
    whBanco: whBanco,
    ahBanco: ahBanco,
    batSerie: batSerie,
    batParalelo: batParalelo,
    inversor: inv,
    regulador: reg,
    nReguladores: nReg,
    corrienteRegulador: reg == null
        ? iEstimada
        : _corriente(reg, c.panel, series * paralelo, v),
    avisos: avisos,
    config: c,
  );
}

/// Corriente de salida que tiene que manejar el regulador.
double _corriente(Regulador r, Panel p, int n, int v) {
  if (r.tipo == TipoRegulador.pwm) {
    final series = max(1, v ~/ 12);
    return (n / series).ceil() * p.isc * 1.25;
  }
  return n * p.w / tensionCarga(v);
}

bool _cabe(Regulador r, Panel p, int n, int v) => r.tipo == TipoRegulador.pwm
    ? p.de12V
    : _seriesMppt(p, n, v, r.vMaxPv) != null;

// ───────────── Autoconsumo con red ─────────────

class ResultadoRed {
  final double kwp;
  final int paneles;
  final double kwpInstalado;
  final double kwhAnio;
  final InversorRed? inversor;
  const ResultadoRed(
    this.kwp,
    this.paneles,
    this.kwpInstalado,
    this.kwhAnio,
    this.inversor,
  );
}

/// Sistema conectado a red que cubre [cobertura] (0–1) del consumo mensual.
ResultadoRed dimensionarRed({
  required double kwhMes,
  required double hsp,
  required Panel panel,
  double cobertura = 1,
  double rendimiento = 0.8,
}) {
  final kwp = kwhMes * cobertura / (30 * hsp * rendimiento);
  final n = max(1, (kwp * 1000 / panel.w - 0.02).ceil());
  final inst = n * panel.w / 1000;
  final aptos = inversoresRed.where((i) => i.kw >= inst / 1.2).toList()
    ..sort((a, b) => a.kw.compareTo(b.kw));
  return ResultadoRed(
    kwp,
    n,
    inst,
    inst * hsp * rendimiento * 365,
    aptos.isEmpty ? null : aptos.first,
  );
}
