import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../formato.dart';
import '../solar/dimensionado.dart';
import '../solar/ejemplos.dart';
import '../solar/equipos.dart';
import '../widgets.dart';

// ───────────────────────── Sistema aislado ─────────────────────────

class ConfiguradorSolar extends StatefulWidget {
  final EjemploSolar? ejemplo;
  const ConfiguradorSolar({super.key, this.ejemplo});

  @override
  State<ConfiguradorSolar> createState() => _ConfiguradorSolarState();
}

class _ConfiguradorSolarState extends EstadoCalculo<ConfiguradorSolar> {
  late List<Consumo> _consumos;
  late final _hsp = simple('HSP', ini: fmt(widget.ejemplo?.hsp ?? 5));
  late final _autonomia = simple(
    'días',
    ini: fmt(widget.ejemplo?.autonomia ?? 1),
  );
  late String? _lugar = widget.ejemplo?.lugar;
  late int _v = widget.ejemplo?.vSistema ?? 24;
  late Panel _panel = panelPorId(widget.ejemplo?.panel ?? 'cs410');
  late Bateria _bateria = bateriaPorId(widget.ejemplo?.bateria ?? 'lfp24_100');
  late Regulador? _regulador = reguladorPorId(widget.ejemplo?.regulador);
  late Inversor? _inversor = inversorPorId(widget.ejemplo?.inversor);

  @override
  void initState() {
    super.initState();
    _consumos =
        widget.ejemplo?.consumos() ??
        [
          Consumo.de(aparatosTipicos[0], cantidad: 4),
          Consumo.de(
            aparatosTipicos.firstWhere((a) => a.nombre == 'Refrigerador'),
          ),
          Consumo.de(
            aparatosTipicos.firstWhere((a) => a.nombre == 'Televisor LED 32"'),
          ),
          Consumo.de(
            aparatosTipicos.firstWhere((a) => a.nombre == 'Ventilador'),
          ),
        ];
  }

  void _cambiarTension(int v) {
    setState(() {
      _v = v;
      if (_bateria.vNominal > v) {
        _bateria = baterias.firstWhere(
          (b) => b.vNominal == v && b.quimica == Quimica.litio,
        );
      }
      if (_inversor != null && _inversor!.vBateria != v) _inversor = null;
      if (_regulador != null && !_regulador!.tensiones.contains(v)) {
        _regulador = null;
      }
    });
  }

  Future<void> _editar([int? indice]) async {
    final c = indice == null ? null : _consumos[indice];
    final nombre = TextEditingController(text: c?.nombre ?? '');
    final w = TextEditingController(text: c == null ? '' : fmt(c.w));
    final h = TextEditingController(text: c == null ? '' : fmt(c.horas));
    final n = TextEditingController(text: '${c?.cantidad ?? 1}');
    var motor = (c?.arranque ?? 1) > 1;
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setD) => AlertDialog(
          title: Text(indice == null ? 'Nuevo aparato' : 'Editar aparato'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nombre,
                  decoration: const InputDecoration(labelText: 'Nombre'),
                ),
                for (final (ctl, etiqueta) in [
                  (w, 'Potencia (W)'),
                  (h, 'Horas de uso al día'),
                  (n, 'Cantidad'),
                ])
                  TextField(
                    controller: ctl,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [filtroDecimal],
                    decoration: InputDecoration(labelText: etiqueta),
                  ),
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  value: motor,
                  onChanged: (v) => setD(() => motor = v!),
                  title: const Text('Tiene motor o compresor'),
                  subtitle: const Text(
                    'Pico de arranque ≈ 3 veces su potencia',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
    final pw = leerNumero(w.text),
        ph = leerNumero(h.text),
        pn = leerNumero(n.text);
    if (ok == true && pw != null && ph != null && pn != null) {
      final nuevo = Consumo(
        nombre.text.trim().isEmpty ? 'Aparato' : nombre.text.trim(),
        pw,
        ph,
        cantidad: pn.round().clamp(1, 999),
        arranque: motor ? (c != null && c.arranque > 1 ? c.arranque : 3) : 1,
      );
      setState(
        () => indice == null ? _consumos.add(nuevo) : _consumos[indice] = nuevo,
      );
    }
    for (final t in [nombre, w, h, n]) {
      t.dispose();
    }
  }

  Future<void> _anadir() async {
    final elegido = await showModalBottomSheet<Aparato?>(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.7,
        builder: (context, scroll) => ListView(
          controller: scroll,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Otro aparato (escribir datos)'),
              onTap: () => Navigator.pop(context, const Aparato('', 0, 0)),
            ),
            const Divider(),
            for (final a in aparatosTipicos)
              ListTile(
                title: Text(a.nombre),
                subtitle: Text('${fmt(a.w)} W · ${fmt(a.horas)} h/día'),
                onTap: () => Navigator.pop(context, a),
              ),
          ],
        ),
      ),
    );
    if (elegido == null) return;
    if (elegido.nombre.isEmpty) {
      await _editar();
    } else {
      setState(() => _consumos.add(Consumo.de(elegido)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final hsp = _hsp.v, dias = _autonomia.v;
    final texto = Theme.of(context).textTheme;
    final esquema = Theme.of(context).colorScheme;
    Resultado? r;
    if (hsp != null &&
        hsp > 0 &&
        dias != null &&
        dias > 0 &&
        _consumos.isNotEmpty) {
      r = dimensionar(
        Configuracion(
          consumos: _consumos,
          hsp: hsp,
          vSistema: _v,
          autonomia: dias,
          panel: _panel,
          bateria: _bateria,
          regulador: _regulador,
          inversor: _inversor,
        ),
      );
    }
    return PantallaCalculo(
      titulo: widget.ejemplo?.titulo ?? 'Sistema solar aislado',
      formulas: const [
        'Energía diaria = Σ (W × horas × cantidad)',
        'Potencia de paneles = Energía / (HSP × 0,75)',
        'Baterías (Wh) = Energía × días / (descarga máx. × 0,9)',
        'Inversor ≥ consumo simultáneo × 1,25 y pico ≥ arranque de motores',
        'Regulador MPPT: corriente ≈ W de paneles / tensión de carga (14,4 V por cada 12 V)',
        'Paneles en serie: Voc × 1,15 × nº ≤ tensión máxima del regulador',
        'Para sistemas aislados usa las HSP del peor mes del año si quieres que no falte energía en invierno.',
      ],
      children: [
        if (widget.ejemplo != null)
          Card(
            color: esquema.secondaryContainer,
            margin: const EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                '${widget.ejemplo!.descripcion}\nPuedes cambiar cualquier dato: los resultados se recalculan solos.',
              ),
            ),
          ),
        const Titulo('1. Qué quieres alimentar'),
        for (var i = 0; i < _consumos.length; i++)
          Card(
            margin: const EdgeInsets.only(bottom: 6),
            child: ListTile(
              dense: true,
              title: Text(
                '${_consumos[i].cantidad > 1 ? '${_consumos[i].cantidad} × ' : ''}${_consumos[i].nombre}',
              ),
              subtitle: Text(
                '${fmt(_consumos[i].w)} W · ${fmt(_consumos[i].horas)} h/día → ${fmt(_consumos[i].whDia)} Wh/día'
                '${_consumos[i].arranque > 1 ? ' · motor' : ''}',
              ),
              onTap: () => _editar(i),
              trailing: IconButton(
                tooltip: 'Quitar',
                icon: const Icon(Icons.delete_outline),
                onPressed: () => setState(() => _consumos.removeAt(i)),
              ),
            ),
          ),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: _anadir,
            icon: const Icon(Icons.add),
            label: const Text('Añadir aparato'),
          ),
        ),
        const SizedBox(height: 8),
        const Titulo('2. Dónde está la instalación'),
        Desplegable<String?>(
          etiqueta: 'Ciudad (horas sol pico)',
          valor: _lugar,
          opciones: [
            (null, 'Otra: escribe las HSP'),
            for (final (c, h) in horasSolPico) (c, '$c · ${fmt(h)} HSP'),
          ],
          alCambiar: (c) {
            setState(() => _lugar = c);
            if (c != null) {
              _hsp.texto.text = fmt(
                horasSolPico.firstWhere((x) => x.$1 == c).$2,
              );
            }
          },
        ),
        const SizedBox(height: 12),
        CampoValor(
          _hsp,
          'Horas sol pico',
          ayuda: 'Horas equivalentes de sol a 1000 W/m² (media anual)',
        ),
        const Titulo('3. Equipos'),
        SelectorModo(
          valor: _v,
          opciones: const [(12, '12 V'), (24, '24 V'), (48, '48 V')],
          alCambiar: _cambiarTension,
        ),
        CampoValor(
          _autonomia,
          'Autonomía sin sol',
          ayuda: 'Días que deben aguantar las baterías',
        ),
        Desplegable<Panel>(
          etiqueta: 'Panel solar',
          valor: _panel,
          opciones: [
            for (final p in paneles) (p, '${p.nombre} (${fmt(p.w)} W)'),
          ],
          alCambiar: (p) => setState(() => _panel = p),
        ),
        const SizedBox(height: 12),
        Desplegable<Bateria>(
          etiqueta: 'Batería',
          valor: _bateria,
          opciones: [
            for (final b in baterias.where((b) => b.vNominal <= _v))
              (b, b.nombre),
          ],
          alCambiar: (b) => setState(() => _bateria = b),
        ),
        const SizedBox(height: 12),
        Desplegable<Regulador?>(
          etiqueta: 'Regulador de carga',
          valor: _regulador,
          opciones: [
            (null, 'Automático'),
            for (final x in reguladores.where((x) => x.tensiones.contains(_v)))
              (
                x,
                '${x.nombre} (${x.tipo == TipoRegulador.pwm ? 'PWM' : 'MPPT'})',
              ),
          ],
          alCambiar: (x) => setState(() => _regulador = x),
        ),
        const SizedBox(height: 12),
        Desplegable<Inversor?>(
          etiqueta: 'Inversor',
          valor: _inversor,
          opciones: [
            (null, 'Automático'),
            for (final x in inversores.where((x) => x.vBateria == _v))
              (x, '${x.nombre} (${fmt(x.w)} W)'),
          ],
          alCambiar: (x) => setState(() => _inversor = x),
        ),
        const SizedBox(height: 16),
        const Titulo('4. Tu sistema'),
        if (r == null)
          const Aviso(
            'Añade al menos un aparato y escribe las HSP y los días de autonomía.',
          )
        else ...[
          Text('Consumo', style: texto.titleSmall),
          Resultados([
            ('Energía al día', '${fmt(r.whDia / 1000, cifras: 3)} kWh'),
            ('Potencia simultánea', ing(r.wSimultanea, 'W')),
            ('Pico de arranque', ing(r.wArranque, 'W')),
          ]),
          Text('Paneles', style: texto.titleSmall),
          Resultados([
            ('Potencia necesaria', ing(r.pvNecesaria, 'W')),
            ('Paneles', '${r.nPaneles} × ${fmt(_panel.w)} W'),
            ('Conexión', '${r.series} en serie × ${r.paralelo} en paralelo'),
            ('Potencia instalada', ing(r.pvInstalada, 'W')),
            ('Tensión de la serie (Voc)', '${fmt(r.series * _panel.voc)} V'),
            (
              'Producción media',
              '${fmt(r.whProducidos / 1000, cifras: 3)} kWh/día',
            ),
          ], nota: _panel.nombre),
          Text('Baterías', style: texto.titleSmall),
          Resultados(
            [
              ('Capacidad necesaria', '${fmt(r.ahBanco)} Ah a $_v V'),
              ('Baterías', '${r.nBaterias} × ${_bateria.nombre}'),
              (
                'Conexión',
                '${r.batSerie} en serie × ${r.batParalelo} en paralelo',
              ),
              ('Energía almacenada', '${fmt(r.kwhBaterias, cifras: 3)} kWh'),
              ('Autonomía real', '${fmt(r.autonomiaReal, cifras: 2)} días'),
            ],
            nota:
                '${nombreQuimica(_bateria.quimica)}: descarga hasta el ${(100 * _bateria.dod).round()} %, unos ${_bateria.ciclos} ciclos.',
          ),
          Text('Regulador e inversor', style: texto.titleSmall),
          Resultados([
            (
              'Regulador',
              r.regulador == null
                  ? 'Incluido en el inversor'
                  : '${r.nReguladores > 1 ? '${r.nReguladores} × ' : ''}${r.regulador!.nombre}',
            ),
            ('Corriente de carga', '${fmt(r.corrienteRegulador, cifras: 3)} A'),
            ('Inversor', r.inversor?.nombre ?? 'Ninguno adecuado'),
            if (r.inversor != null)
              (
                'Potencia del inversor',
                '${ing(r.inversor!.w, 'W')} (pico ${ing(r.inversor!.wPico, 'W')})',
              ),
            if (r.inversor != null)
              (
                'Fusible de batería',
                '≈ ${fmt(r.inversor!.w / _v / 0.9 * 1.25, cifras: 2)} A',
              ),
          ], nota: r.inversor?.nota.isEmpty ?? true ? null : r.inversor!.nota),
          for (final a in r.avisos)
            Card(
              color: esquema.errorContainer,
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: Icon(
                  Icons.warning_amber,
                  color: esquema.onErrorContainer,
                ),
                title: Text(
                  a,
                  style: TextStyle(color: esquema.onErrorContainer),
                ),
              ),
            ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: _listaMateriales(r!)));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Lista de materiales copiada')),
              );
            },
            icon: const Icon(Icons.copy),
            label: const Text('Copiar lista de materiales'),
          ),
          const SizedBox(height: 8),
          Text(
            'Datos de equipos orientativos: confirma siempre con la ficha técnica del fabricante y con un instalador.',
            style: texto.bodySmall,
          ),
        ],
      ],
    );
  }

  String _listaMateriales(Resultado r) {
    final b = StringBuffer('Sistema solar aislado de $_v V\n')
      ..writeln(
        'Consumo: ${fmt(r.whDia)} Wh/día · ${fmt(r.wSimultanea)} W simultáneos',
      )
      ..writeln(
        '- ${r.nPaneles} paneles ${_panel.nombre} (${r.series}S × ${r.paralelo}P, ${fmt(r.pvInstalada)} W)',
      )
      ..writeln(
        '- ${r.nBaterias} baterías ${_bateria.nombre} (${r.batSerie}S × ${r.batParalelo}P, ${fmt(r.kwhBaterias)} kWh)',
      );
    if (r.regulador != null) {
      b.writeln('- ${r.nReguladores} regulador ${r.regulador!.nombre}');
    }
    if (r.inversor != null) b.writeln('- Inversor ${r.inversor!.nombre}');
    b.writeln('Aparatos:');
    for (final c in _consumos) {
      b.writeln(
        '  · ${c.cantidad} × ${c.nombre}: ${fmt(c.w)} W, ${fmt(c.horas)} h/día',
      );
    }
    return b.toString();
  }
}

// ───────────────────────── Autoconsumo con red ─────────────────────────

class AutoconsumoRed extends StatefulWidget {
  const AutoconsumoRed({super.key});
  @override
  State<AutoconsumoRed> createState() => _AutoconsumoRedState();
}

class _AutoconsumoRedState extends EstadoCalculo<AutoconsumoRed> {
  late final _kwh = simple('kWh/mes', ini: '300');
  late final _hsp = simple('HSP', ini: '5');
  late final _cobertura = simple('%', ini: '80');
  late final _precio = simple('por kWh', ini: '0,15');
  String? _lugar;
  Panel _panel = paneles.firstWhere((p) => p.id == 'longi430');

  @override
  Widget build(BuildContext context) {
    final kwh = _kwh.v, hsp = _hsp.v, cob = _cobertura.v, precio = _precio.v;
    Widget res;
    if (kwh == null || hsp == null || hsp <= 0 || cob == null || cob <= 0) {
      res = const Aviso('Completa los datos.');
    } else {
      final r = dimensionarRed(
        kwhMes: kwh,
        hsp: hsp,
        panel: _panel,
        cobertura: cob / 100,
      );
      res = Resultados(
        [
          ('Potencia necesaria', '${fmt(r.kwp, cifras: 3)} kWp'),
          ('Paneles', '${r.paneles} × ${fmt(_panel.w)} W'),
          ('Potencia instalada', '${fmt(r.kwpInstalado, cifras: 3)} kWp'),
          ('Producción', '${fmt(r.kwhAnio / 12, cifras: 3)} kWh/mes'),
          ('Producción al año', '${fmt(r.kwhAnio, cifras: 4)} kWh'),
          (
            'Inversor de red',
            r.inversor == null
                ? 'Varios inversores'
                : '${r.inversor!.nombre} (${fmt(r.inversor!.kw)} kW)',
          ),
          (
            'Superficie aprox.',
            '${fmt(r.paneles * (_panel.w > 500 ? 2.6 : 2.0), cifras: 2)} m²',
          ),
          if (precio != null)
            ('Ahorro al año', fmt(r.kwhAnio * precio, cifras: 4)),
        ],
        nota:
            'Sin baterías: si se va la corriente, el inversor de red se apaga por seguridad. '
            'Para tener luz en los apagones usa un inversor híbrido.',
      );
    }
    return PantallaCalculo(
      titulo: 'Autoconsumo con red',
      formulas: const [
        'kWp = kWh al mes × cobertura / (30 × HSP × 0,8)',
        'El inversor puede ser hasta un 20 % menor que la potencia de paneles.',
        'Otros inversores de red: Huawei SUN2000, Fronius Primo/Symo, SMA Sunny Boy, Growatt MIN/MOD.',
      ],
      children: [
        CampoValor(_kwh, 'Consumo mensual (mira tu factura)'),
        Desplegable<String?>(
          etiqueta: 'Ciudad (horas sol pico)',
          valor: _lugar,
          opciones: [
            (null, 'Otra: escribe las HSP'),
            for (final (c, h) in horasSolPico) (c, '$c · ${fmt(h)} HSP'),
          ],
          alCambiar: (c) {
            setState(() => _lugar = c);
            if (c != null) {
              _hsp.texto.text = fmt(
                horasSolPico.firstWhere((x) => x.$1 == c).$2,
              );
            }
          },
        ),
        const SizedBox(height: 12),
        CampoValor(_hsp, 'Horas sol pico'),
        CampoValor(_cobertura, 'Parte del consumo a cubrir'),
        Desplegable<Panel>(
          etiqueta: 'Panel solar',
          valor: _panel,
          opciones: [
            for (final p in paneles) (p, '${p.nombre} (${fmt(p.w)} W)'),
          ],
          alCambiar: (p) => setState(() => _panel = p),
        ),
        const SizedBox(height: 12),
        CampoValor(_precio, 'Precio del kWh (en tu moneda)'),
        res,
      ],
    );
  }
}
