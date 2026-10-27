import 'dimensionado.dart';
import 'equipos.dart';

class EjemploSolar {
  final String titulo;
  final String descripcion;
  final List<Consumo> Function() consumos;
  final String lugar;
  final double hsp;
  final int vSistema;
  final double autonomia;
  final String panel;
  final String bateria;
  final String? regulador;
  final String? inversor;

  const EjemploSolar({
    required this.titulo,
    required this.descripcion,
    required this.consumos,
    required this.lugar,
    required this.hsp,
    required this.vSistema,
    required this.autonomia,
    required this.panel,
    required this.bateria,
    this.regulador,
    this.inversor,
  });
}

Consumo _c(String nombre, {int n = 1, double? h}) => Consumo.de(
  aparatosTipicos.firstWhere((a) => a.nombre == nombre),
  cantidad: n,
  horas: h,
);

Panel panelPorId(String id) => paneles.firstWhere((p) => p.id == id);
Bateria bateriaPorId(String id) => baterias.firstWhere((b) => b.id == id);
Regulador? reguladorPorId(String? id) =>
    id == null ? null : reguladores.firstWhere((r) => r.id == id);
Inversor? inversorPorId(String? id) =>
    id == null ? null : inversores.firstWhere((i) => i.id == id);

final ejemplosSolares = <EjemploSolar>[
  EjemploSolar(
    titulo: 'Luces y celulares (12 V)',
    descripcion:
        'Lo mínimo para un apagón: iluminación, cargar teléfonos y la radio.',
    consumos: () => [
      _c('Bombillo LED', n: 4),
      _c('Celular (carga)', n: 3),
      _c('Radio'),
      _c('Router WiFi', h: 8),
    ],
    lugar: 'La Habana',
    hsp: 5.3,
    vSistema: 12,
    autonomia: 1,
    panel: 'gen200',
    bateria: 'lfp12_100',
    regulador: 'ep3210',
    inversor: 'ph12800',
  ),
  EjemploSolar(
    titulo: 'Casa pequeña contra apagones (24 V)',
    descripcion: 'Luces, refrigerador, TV, ventiladores y router con un inversor todo en uno.',
    consumos: () => [
      _c('Bombillo LED', n: 6),
      _c('Refrigerador'),
      _c('Televisor LED 32"'),
      _c('Ventilador', n: 2),
      _c('Router WiFi'),
      _c('Celular (carga)', n: 3),
    ],
    lugar: 'La Habana',
    hsp: 5.3,
    vSistema: 24,
    autonomia: 1,
    panel: 'cs410',
    bateria: 'lfp24_100',
    inversor: 'spf3000',
  ),
  EjemploSolar(
    titulo: 'Vivienda completa (48 V)',
    descripcion: 'Con aire acondicionado inverter, lavadora, microondas y bomba de agua.',
    consumos: () => [
      _c('Bombillo LED', n: 10),
      _c('Refrigerador inverter'),
      _c('Televisor LED 50"'),
      _c('Ventilador', n: 2),
      _c('Aire acondicionado inverter 12 000 BTU'),
      _c('Lavadora'),
      _c('Microondas'),
      _c('Bomba de agua ½ HP'),
      _c('Router WiFi'),
      _c('Laptop'),
      _c('Celular (carga)', n: 4),
    ],
    lugar: 'Ciudad de México',
    hsp: 5.5,
    vSistema: 48,
    autonomia: 1,
    panel: 'jinko580',
    bateria: 'us5000',
    inversor: 'spf5000',
  ),
  EjemploSolar(
    titulo: 'Vivienda con Victron (48 V)',
    descripcion: 'Misma idea con equipos Victron por separado: MultiPlus-II + SmartSolar.',
    consumos: () => [
      _c('Bombillo LED', n: 10),
      _c('Refrigerador inverter'),
      _c('Televisor LED 50"'),
      _c('Aire acondicionado inverter 12 000 BTU', h: 5),
      _c('Lavadora'),
      _c('Microondas'),
      _c('Computadora de mesa'),
      _c('Router WiFi'),
    ],
    lugar: 'Sevilla',
    hsp: 5.2,
    vSistema: 48,
    autonomia: 1.5,
    panel: 'longi430',
    bateria: 'us5000',
    regulador: 'v250100',
    inversor: 'mp2_48_5000',
  ),
  EjemploSolar(
    titulo: 'Híbrido con red (Deye 48 V)',
    descripcion:
        'Usa el sol primero, las baterías de respaldo y la red cuando falta.',
    consumos: () => [
      _c('Bombillo LED', n: 8),
      _c('Refrigerador'),
      _c('Congelador'),
      _c('Televisor LED 50"'),
      _c('Aire acondicionado inverter 12 000 BTU', h: 4),
      _c('Lavadora'),
      _c('Router WiFi'),
      _c('Cámaras de seguridad (DVR)'),
    ],
    lugar: 'Santo Domingo',
    hsp: 5.3,
    vSistema: 48,
    autonomia: 0.5,
    panel: 'trina550',
    bateria: 'rack100',
    inversor: 'deye5k',
  ),
  EjemploSolar(
    titulo: 'Cabaña de fin de semana (plomo)',
    descripcion: 'Sistema económico con baterías AGM y regulador PWM.',
    consumos: () => [
      _c('Bombillo LED', n: 3, h: 4),
      _c('Radio'),
      _c('Celular (carga)', n: 2),
      _c('Ventilador', h: 4),
    ],
    lugar: 'Bogotá',
    hsp: 4.2,
    vSistema: 12,
    autonomia: 2,
    panel: 'gen100',
    bateria: 'ritar100',
    regulador: 'pwm30',
    inversor: 'ph12800',
  ),
  EjemploSolar(
    titulo: 'Bomba de agua de pozo (24 V)',
    descripcion: 'Bombear de día y tener agua en el tanque; poca batería.',
    consumos: () => [_c('Bomba de agua 1 HP', h: 3), _c('Bombillo LED', n: 2)],
    lugar: 'Lima',
    hsp: 5.0,
    vSistema: 24,
    autonomia: 0.5,
    panel: 'ja415',
    bateria: 'lfp24_100',
    inversor: 'gen3k24',
  ),
  EjemploSolar(
    titulo: 'Furgoneta / camper (12 V)',
    descripcion: 'Nevera de 12 V, luces y portátil con equipos Victron.',
    consumos: () => [
      _c('Nevera 12 V (camper)'),
      _c('Bombillo LED', n: 2, h: 4),
      _c('Laptop', h: 3),
      _c('Celular (carga)', n: 2),
    ],
    lugar: 'Madrid',
    hsp: 4.8,
    vSistema: 12,
    autonomia: 2,
    panel: 'gen200',
    bateria: 'victron200',
    regulador: 'v10030',
    inversor: 'ph12800',
  ),
];
