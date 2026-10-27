import 'package:flutter/material.dart';

import 'modelo.dart';

// Equipos que se repiten en los esquemas.
const _f754Medir = EquipoDibujo('Fluke 754 · MEDIR', [
  Borne('V Ω RTD +', color: rojoPunta),
  Borne('COM −', color: negroPunta),
  Borne('mA + (24 V lazo)', color: rojoPunta),
  Borne('mA −', color: negroPunta),
]);

const _f754Generar = EquipoDibujo('Fluke 754 · GENERAR', [
  Borne('SOURCE +', color: rojoPunta),
  Borne('SOURCE −', color: negroPunta),
]);

const _f754Completo = EquipoDibujo('Fluke 754', [
  Borne('SOURCE +', color: rojoPunta),
  Borne('SOURCE −', color: negroPunta),
  Borne('MEAS mA +', color: rojoPunta),
  Borne('MEAS mA −', color: negroPunta),
]);

const _avisoVersion =
    'Guía práctica propia. Los nombres de teclas y menús pueden cambiar según la versión de firmware: '
    'si algo no coincide, consulta el manual oficial del Fluke 753/754, que se descarga gratis en español desde fluke.com.';

final guiaFluke754 = Guia('Fluke 754', 'Calibrador documentador de procesos con HART', [
  // ───────────────────────── 1 ─────────────────────────
  const Capitulo(
    'Qué es y qué hace',
    'Funciones, rangos y accesorios',
    Icons.info_outline,
    [
      Parrafo(
        'El Fluke 754 es un calibrador de procesos multifunción: mide y genera las señales típicas de '
        'instrumentación (mA, V, mV, Ω, RTD, termopares, frecuencia y presión con módulos externos), '
        'alimenta lazos de 2 hilos, se comunica por HART con los transmisores y DOCUMENTA las '
        'calibraciones (guarda los resultados «como se encontró» y «como se dejó» para pasarlos al PC).',
      ),
      Nota(_avisoVersion),
      Subtitulo('Lo que puede hacer'),
      Vinetas([
        'Medir y generar a la vez (pantalla dividida): ideal para calibrar transmisores.',
        'Alimentar un transmisor de 2 hilos con su fuente interna de 24 V.',
        'Simular un transmisor (absorber corriente de un lazo ya alimentado).',
        'Medir y simular termopares y RTD (Pt100, Pt1000…).',
        'Medir presión con módulos Fluke 750P (y compatibles 700P) y una bomba.',
        'Probar presostatos y termostatos (punto de disparo, rearme y banda muerta).',
        'Rampas, pasos de 25 % y pasos automáticos para recorrer el rango.',
        'Comunicador HART: leer y cambiar rango, tag, unidades; trim de salida y de sensor.',
        'Calibraciones documentadas con tolerancia y resultado pasa / no pasa.',
        'Transferir tareas y resultados al PC con el software DPCTrack2.',
      ]),
      Subtitulo('Rangos aproximados'),
      TablaGuia(
        ['Función', 'Medir', 'Generar'],
        [
          ['Tensión CC', '0 a 300 V', '0 a 15 V'],
          ['mV CC', '±110 mV', '±110 mV'],
          ['Tensión CA', 'hasta 300 V', '—'],
          ['Corriente CC', '0 a 100 mA', '0 a 22 mA (generar o simular)'],
          ['Resistencia', '0 a 11 kΩ', '5 Ω a 11 kΩ'],
          ['Frecuencia', '1 Hz a 50 kHz', 'hasta 50 kHz y tren de pulsos'],
          ['RTD', 'Pt100, Pt200, Pt500, Pt1000, Ni120, Cu10…', 'Las mismas'],
          ['Termopar', 'J, K, T, E, R, S, B, L, U, N, C, XK, BP', 'Los mismos'],
          ['Presión', 'Con módulo 750P', '—'],
          ['Alimentación de lazo', '24 V CC', ''],
        ],
      ),
      Nota(
        'Valores orientativos de la serie 75x. Mira las especificaciones exactas y la exactitud en la hoja de datos de tu unidad.',
      ),
      Subtitulo('Accesorios habituales'),
      Vinetas([
        'Cables de prueba rojo y negro con pinzas de cocodrilo y ganchos.',
        'Cable de termopar y miniconectores del tipo correcto (K amarillo/verde, J negro…).',
        'Módulos de presión Fluke 750P: manométricos, diferenciales, absolutos y de vacío.',
        'Bombas de prueba: neumática (hasta ≈ 40 bar), hidráulica (hasta ≈ 700 bar) y de baja presión.',
        'Mangueras y adaptadores (NPT, BSP, M20).',
        'Batería de litio, cargador y cable USB para DPCTrack2.',
      ]),
    ],
    palabras: ['fluke', '754', '753', 'calibrador', 'especificaciones'],
  ),

  // ───────────────────────── 2 ─────────────────────────
  const Capitulo(
    'Partes del equipo',
    'Bornes, teclas y pantalla',
    Icons.devices_other,
    [
      DibujoEquipo(),
      Nota('Esquema simplificado, no a escala.'),
      Subtitulo('Bornes de la parte superior'),
      TablaGuia(
        ['Borne', 'Uso'],
        [
          [
            'MEASURE V · Ω · RTD · Hz (+ y COM)',
            'Medir tensión, resistencia, RTD y frecuencia',
          ],
          ['MEASURE 3W / 4W', 'Bornes extra para RTD de 3 y 4 hilos'],
          [
            'MEASURE mA (+ y −)',
            'Medir corriente; con «alimentación de lazo» da 24 V',
          ],
          [
            'SOURCE (+ y −)',
            'Generar V, mA, Ω, RTD y frecuencia; simular transmisor',
          ],
          [
            'Conector TC',
            'Miniconector plano para medir o simular termopares (lleva la compensación de unión fría)',
          ],
          ['Conector de módulo de presión', 'Cable del módulo 750P'],
          ['Puerto USB / serie', 'Conexión al PC (DPCTrack2)'],
        ],
      ),
      Subtitulo('Teclas'),
      TablaGuia(
        ['Tecla', 'Para qué sirve'],
        [
          ['MEAS', 'Modo medir'],
          ['SOURCE', 'Modo generar'],
          [
            'MEAS / SOURCE',
            'Pantalla dividida: genera arriba y mide abajo (calibración)',
          ],
          ['V / mV', 'Elegir tensión'],
          ['mA', 'Elegir corriente'],
          ['Ω / RTD', 'Elegir resistencia o RTD'],
          ['TC', 'Elegir termopar'],
          ['Hz / pulsos', 'Elegir frecuencia o pulsos'],
          ['Presión', 'Elegir medida de presión (módulo conectado)'],
          ['HART', 'Abrir el comunicador HART'],
          ['SETUP', 'Configuración del equipo'],
          [
            'Teclas programables (debajo de la pantalla)',
            'Su función cambia: aparece escrita encima de cada una',
          ],
          [
            'Flechas ▲ ▼ ◄ ►',
            'Moverse por menús y cambiar valores; ▲ ▼ también dan pasos al generar',
          ],
          ['ENTER', 'Aceptar'],
          [
            'CLEAR / ZERO',
            'Borrar o poner a cero (p. ej. el módulo de presión)',
          ],
          ['Teclado numérico', 'Escribir valores'],
        ],
      ),
      Subtitulo('Qué hay en la pantalla'),
      Vinetas([
        'Arriba: modo (MEDIR, GENERAR o ambos) y la función activa.',
        'Centro: el valor medido o generado en grande, con sus unidades y, si hay escala, el %.',
        'Abajo: rótulos de las teclas programables (opciones disponibles en ese momento).',
        'Indicadores: batería, alimentación de lazo activa, HART conectado.',
      ]),
    ],
    palabras: ['bornes', 'teclas', 'pantalla', 'partes', 'fluke'],
  ),

  // ───────────────────────── 3 ─────────────────────────
  const Capitulo(
    'Menús y configuración',
    'SETUP, modos y opciones',
    Icons.settings,
    [
      Subtitulo('Modos de trabajo'),
      TablaGuia(
        ['Modo', 'Cuándo usarlo'],
        [
          [
            'MEDIR',
            'Comprobar una señal: tensión de una fuente, corriente de un lazo, temperatura…',
          ],
          [
            'GENERAR',
            'Inyectar una señal: simular un transmisor ante un PLC, un RTD ante un indicador…',
          ],
          [
            'MEDIR / GENERAR',
            'Calibrar: generas la entrada del instrumento y mides su salida a la vez',
          ],
          [
            'TAREAS / PROCEDIMIENTOS',
            'Calibraciones guardadas que se ejecutan paso a paso y se documentan',
          ],
          ['HART', 'Hablar con el transmisor: ver y cambiar su configuración'],
        ],
      ),
      Subtitulo('Opciones habituales del SETUP'),
      TablaGuia(
        ['Opción', 'Qué hace'],
        [
          ['Idioma', 'Español, inglés y otros'],
          ['Fecha y hora', 'Para que los resultados queden bien fechados'],
          ['Contraste / retroiluminación', 'Legibilidad'],
          ['Apagado automático', 'Ahorra batería'],
          [
            'Frecuencia de red (50 / 60 Hz)',
            'Mejora el rechazo de ruido: pon la de tu país',
          ],
          ['Unidades de temperatura', '°C, °F, K'],
          ['Escala de temperatura', 'ITS-90 / IPTS-68'],
          ['Unidades de presión', 'bar, kPa, psi, mbar, inH₂O, mmHg…'],
          [
            'Resistencia HART (250 Ω)',
            'Activa la resistencia interna cuando el lazo no tiene la suya',
          ],
          [
            'Alimentación de lazo (24 V)',
            'Activa o desactiva los 24 V en los bornes mA de medida',
          ],
          ['Tipo de RTD / TC por defecto', 'Para no elegirlo cada vez'],
          [
            'Compensación de unión fría',
            'Interna (sensor del equipo) o externa / manual',
          ],
          ['Amortiguación (damping)', 'Promedia la lectura para estabilizarla'],
          ['Memoria', 'Ver y borrar tareas y resultados'],
          ['Comunicaciones', 'Puerto para el PC'],
          [
            'Calibración del propio equipo',
            'Protegida con contraseña: solo laboratorio',
          ],
        ],
      ),
      Subtitulo('Funciones de las teclas programables'),
      TablaGuia(
        ['Función', 'Para qué'],
        [
          [
            'Escala (Scale)',
            'Muestra la lectura en % o en unidades de proceso. Lineal o con raíz cuadrada (√) para caudal',
          ],
          ['Mín / Máx', 'Guarda el valor mínimo y máximo medido'],
          ['Retener (Hold)', 'Congela la lectura'],
          [
            'Paso (Step)',
            'Cambia el valor generado en saltos fijos (p. ej. 25 % = 4 mA)',
          ],
          [
            'Rampa (Ramp)',
            'Sube y baja el valor generado de forma continua: busca puntos de disparo',
          ],
          [
            'Paso automático (Auto step)',
            'Recorre 0-25-50-75-100 % solo, con el tiempo de espera que elijas',
          ],
          [
            'As Found / As Left',
            'Ejecuta y guarda la calibración antes y después del ajuste',
          ],
          ['Tareas', 'Carga una calibración preparada en el PC'],
        ],
      ),
    ],
    palabras: [
      'menu',
      'setup',
      'configuracion',
      'opciones',
      'modos',
      'rampa',
      'escala',
    ],
  ),

  // ───────────────────────── 4 ─────────────────────────
  const Capitulo(
    'Conexiones básicas',
    'Medir y generar V, mA, Ω, frecuencia',
    Icons.cable,
    [
      Subtitulo('Medir tensión, resistencia o frecuencia'),
      Conexion(
        'Medir tensión CC/CA o frecuencia',
        [
          _f754Medir,
          EquipoDibujo('Circuito', [Borne('+ / fase'), Borne('− / común')]),
        ],
        [Cable((0, 0), (1, 0), rojoPunta), Cable((0, 1), (1, 1), negroPunta)],
      ),
      Pasos([
        'Pulsa MEAS y elige V (o Hz).',
        'Conecta el rojo a V Ω RTD y el negro a COM.',
        'Toca los puntos del circuito y lee el valor. En CA cambia la función a V CA.',
      ]),
      Nota(
        'Máximo 300 V y categoría CAT II: no lo uses en cuadros de distribución de alta energía.',
        peligro: true,
      ),
      Subtitulo('Medir la corriente de un lazo ya alimentado'),
      Conexion(
        'Medir mA en serie con el lazo',
        [
          _f754Medir,
          EquipoDibujo('Lazo 4–20 mA', [
            Borne('Hilo cortado lado fuente'),
            Borne('Hilo cortado lado carga'),
          ]),
        ],
        [
          Cable(
            (0, 2),
            (1, 0),
            rojoPunta,
            etiqueta: 'la corriente entra por +',
          ),
          Cable((0, 3), (1, 1), negroPunta),
        ],
      ),
      Pasos([
        'Pulsa MEAS y mA. Comprueba que la alimentación de lazo está DESACTIVADA (el lazo ya tiene fuente).',
        'Abre el lazo (suelta un hilo o usa los bornes de prueba del transmisor).',
        'Pon el calibrador en serie: la corriente debe entrar por mA + y salir por mA −.',
        'Lee los mA. Si sale negativo, has invertido los cables.',
      ]),
      Nota(
        'Nunca conectes los bornes mA directamente a una fuente de tensión: es un cortocircuito y fundirá el fusible.',
        peligro: true,
      ),
      Subtitulo('Generar tensión, mV o frecuencia'),
      Conexion(
        'Generar V / mV / Hz hacia una entrada',
        [
          _f754Generar,
          EquipoDibujo('Entrada de PLC / indicador', [
            Borne('IN +'),
            Borne('IN −'),
          ]),
        ],
        [Cable((0, 0), (1, 0), rojoPunta), Cable((0, 1), (1, 1), negroPunta)],
      ),
      Pasos([
        'Pulsa SOURCE y elige V, mV o Hz.',
        'Escribe el valor con el teclado y pulsa ENTER.',
        'Usa ▲ ▼ o la función Paso para ir cambiando el valor.',
      ]),
      Subtitulo('Medir resistencia y RTD (2, 3 y 4 hilos)'),
      Conexion(
        'Medir Pt100 a 4 hilos',
        [
          EquipoDibujo('Fluke 754 · MEDIR RTD', [
            Borne('V Ω RTD +', color: rojoPunta),
            Borne('COM −', color: negroPunta),
            Borne('3W', color: rojoPunta),
            Borne('4W', color: negroPunta),
          ]),
          EquipoDibujo('Pt100', [
            Borne('Rojo 1'),
            Borne('Blanco 1'),
            Borne('Rojo 2'),
            Borne('Blanco 2'),
          ]),
        ],
        [
          Cable((0, 0), (1, 0), rojoPunta),
          Cable((0, 1), (1, 1), negroPunta),
          Cable((0, 2), (1, 2), rojoPunta),
          Cable((0, 3), (1, 3), negroPunta),
        ],
      ),
      Pasos([
        'Pulsa MEAS y Ω/RTD; elige el tipo (Pt100 α 0,00385 es el más común) y el número de hilos.',
        '2 hilos: solo + y COM (la resistencia del cable se suma al error).',
        '3 hilos: + y COM más el borne 3W en el hilo repetido.',
        '4 hilos: los cuatro bornes; es la conexión más exacta.',
      ]),
    ],
    palabras: [
      'conexion',
      'medir',
      'generar',
      'tension',
      'corriente',
      'rtd',
      'pt100',
      'resistencia',
      'frecuencia',
    ],
  ),

  // ───────────────────────── 5 ─────────────────────────
  const Capitulo(
    'Lazos de 4–20 mA',
    'Alimentar, generar y simular transmisores',
    Icons.loop,
    [
      Parrafo(
        'El 754 trabaja con lazos de corriente de tres formas: MIDE (en serie con un lazo existente), '
        'ALIMENTA y mide (da 24 V a un transmisor desconectado de su fuente) y GENERA o SIMULA '
        '(sustituye al transmisor ante el PLC).',
      ),
      Subtitulo('Alimentar un transmisor de 2 hilos y medir su salida'),
      Conexion(
        'Transmisor en banco con los 24 V del 754',
        [
          _f754Medir,
          EquipoDibujo('Transmisor 2 hilos', [
            Borne('+', color: rojoPunta),
            Borne('−', color: negroPunta),
          ]),
        ],
        [
          Cable((0, 2), (1, 0), rojoPunta, etiqueta: '24 V'),
          Cable((0, 3), (1, 1), negroPunta),
        ],
      ),
      Pasos([
        'Desconecta el transmisor de su fuente o llévalo al banco.',
        'Pulsa MEAS, mA y activa la alimentación de lazo (24 V).',
        'Rojo de mA + al + del transmisor; negro de mA − al − del transmisor.',
        'Debes leer entre 3,8 y 20,5 mA. Si lees 0, revisa polaridad y que el lazo esté activado.',
      ]),
      Nota(
        'Para comunicar por HART en esta conexión activa la resistencia interna de 250 Ω.',
      ),
      Subtitulo('Generar mA (el 754 alimenta el lazo)'),
      Conexion(
        'Generar 4–20 mA hacia una entrada pasiva',
        [
          _f754Generar,
          EquipoDibujo('Entrada AI pasiva (sin fuente)', [
            Borne('AI +'),
            Borne('AI −'),
          ]),
        ],
        [Cable((0, 0), (1, 0), rojoPunta), Cable((0, 1), (1, 1), negroPunta)],
      ),
      Pasos([
        'Pulsa SOURCE y mA. Elige «generar» (source).',
        'Escribe 4 mA y ENTER. Comprueba que el PLC o SCADA marca 0 %.',
        'Sube con el paso de 25 %: 8, 12, 16 y 20 mA → 25, 50, 75 y 100 %.',
      ]),
      Subtitulo('Simular un transmisor en un lazo con fuente'),
      Conexion(
        'Simular transmisor (el lazo pone los 24 V)',
        [
          _f754Generar,
          EquipoDibujo('Bornes del transmisor', [
            Borne('+ (viene de la fuente)'),
            Borne('− (va al PLC)'),
          ], color: Color(0xFF6D4C41)),
          EquipoDibujo('PLC con fuente 24 V', [
            Borne('+24 V', lado: Lado.izquierda),
            Borne('AI', lado: Lado.izquierda),
          ]),
        ],
        [
          Cable((0, 0), (1, 0), rojoPunta),
          Cable((0, 1), (1, 1), negroPunta),
          Cable((1, 0), (2, 0), rojoPunta, etiqueta: 'cableado de campo'),
          Cable((1, 1), (2, 1), negroPunta),
        ],
      ),
      Pasos([
        'Quita el transmisor (o suéltalo de sus bornes) y conecta el 754 en su lugar.',
        'Pulsa SOURCE, mA y elige «simular transmisor» (simulate). El 754 regula la corriente pero NO pone tensión.',
        'El + del 754 va donde llega el positivo de la fuente; el − hacia la entrada del PLC.',
        'Fija los mA y comprueba la lectura en el PLC, el SCADA o el indicador.',
      ]),
      Nota(
        'Si eliges «generar» en un lazo que ya tiene fuente, las dos tensiones se suman o se enfrentan y la corriente no será correcta.',
        peligro: true,
      ),
      Subtitulo('Probar la escala en el PLC: valores esperados'),
      TablaGuia(
        ['%', 'mA', '1–5 V en 250 Ω'],
        [
          ['0 %', '4,00', '1,00'],
          ['25 %', '8,00', '2,00'],
          ['50 %', '12,00', '3,00'],
          ['75 %', '16,00', '4,00'],
          ['100 %', '20,00', '5,00'],
          ['Fallo bajo (NAMUR)', '< 3,6', ''],
          ['Fallo alto (NAMUR)', '> 21,0', ''],
        ],
      ),
    ],
    palabras: [
      '4-20',
      'lazo',
      'loop',
      'simular',
      'transmisor',
      'alimentacion',
      '24v',
      'plc',
    ],
  ),

  // ───────────────────────── 6 ─────────────────────────
  const Capitulo(
    'Temperatura',
    'Termopares y RTD: medir y simular',
    Icons.thermostat,
    [
      Subtitulo('Medir un termopar'),
      Conexion(
        'Termopar al conector TC',
        [
          EquipoDibujo('Fluke 754', [
            Borne('TC + (miniconector)', color: amarilloCable),
            Borne('TC −', color: rojoPunta),
          ]),
          EquipoDibujo('Termopar tipo K', [
            Borne('+ (verde IEC)'),
            Borne('− (blanco IEC)'),
          ]),
        ],
        [
          Cable((0, 0), (1, 0), verdeCable, etiqueta: 'cable de extensión K'),
          Cable((0, 1), (1, 1), Color(0xFFEEEEEE)),
        ],
      ),
      Pasos([
        'Pulsa MEAS y TC; elige el tipo de termopar (J, K, T…).',
        'Usa un miniconector y cable del MISMO tipo: si usas cobre, el error puede ser de varios grados.',
        'Deja la compensación de unión fría en «interna» y espera 1–2 min a que se estabilice la temperatura del conector.',
      ]),
      Subtitulo('Simular un termopar ante un transmisor o un PLC'),
      Pasos([
        'Pulsa SOURCE y TC; elige el tipo.',
        'Conecta del conector TC a la entrada del transmisor con cable del mismo tipo.',
        'Escribe la temperatura: el 754 genera los mV correspondientes y compensa la unión fría.',
        'Si el instrumento tiene su propia compensación (casi siempre), deja la del 754 en interna.',
      ]),
      Subtitulo('Simular una RTD (Pt100)'),
      Conexion(
        'Simular Pt100 hacia un transmisor de temperatura',
        [
          _f754Generar,
          EquipoDibujo('Transmisor RTD', [
            Borne('RTD 1'),
            Borne('RTD 2 y 3 (puente)'),
          ]),
        ],
        [
          Cable((0, 0), (1, 0), rojoPunta),
          Cable(
            (0, 1),
            (1, 1),
            negroPunta,
            etiqueta: 'en 3 hilos, une 2 y 3 en el transmisor',
          ),
        ],
      ),
      Pasos([
        'Pulsa SOURCE y Ω/RTD; elige Pt100 (385).',
        'En la simulación el 754 se conecta a 2 hilos: en un transmisor de 3 o 4 hilos, puentea en el propio transmisor los bornes del mismo lado.',
        'Escribe la temperatura y comprueba la salida del transmisor.',
      ]),
      Nota(
        'Algunos transmisores usan corriente de excitación pulsada: si la lectura salta, revisa el apartado de RTD pulsada del manual.',
      ),
      Subtitulo('Valores de referencia Pt100 (α = 0,00385)'),
      TablaGuia(
        ['°C', 'Ω'],
        [
          ['−50', '80,31'],
          ['0', '100,00'],
          ['25', '109,73'],
          ['50', '119,40'],
          ['100', '138,51'],
          ['150', '157,33'],
          ['200', '175,86'],
          ['300', '212,05'],
          ['400', '247,09'],
        ],
      ),
      Subtitulo('Valores de referencia termopar K (unión fría a 0 °C)'),
      TablaGuia(
        ['°C', 'mV'],
        [
          ['0', '0,000'],
          ['100', '4,096'],
          ['200', '8,138'],
          ['300', '12,209'],
          ['400', '16,397'],
          ['500', '20,644'],
          ['600', '24,905'],
          ['800', '33,275'],
          ['1000', '41,276'],
        ],
      ),
    ],
    palabras: [
      'termopar',
      'termocupla',
      'rtd',
      'pt100',
      'temperatura',
      'simular',
      'tc',
    ],
  ),

  // ───────────────────────── 7 ─────────────────────────
  const Capitulo(
    'Presión: módulos y bombas',
    'Elegir módulo, montar la bomba, poner a cero',
    Icons.compress,
    [
      Parrafo(
        'El 754 no mide presión por sí mismo: lo hace con un módulo de presión Fluke 750P conectado a su '
        'puerto. La presión la produce una bomba manual (o la propia línea) y se aplica a la vez al módulo '
        'y al instrumento a calibrar con una «T».',
      ),
      Subtitulo('Tipos de módulo'),
      TablaGuia(
        ['Tipo', 'Mide', 'Uso'],
        [
          [
            'Manométrico (gauge)',
            'Respecto a la atmósfera',
            'Transmisores de presión normales, manómetros, presostatos',
          ],
          [
            'Diferencial',
            'Diferencia entre lado alto (H) y bajo (L)',
            'Transmisores DP de caudal y nivel, filtros',
          ],
          [
            'Absoluto',
            'Respecto al vacío',
            'Transmisores absolutos, barómetros',
          ],
          ['Vacío', 'Por debajo de la atmósfera', 'Vacuostatos'],
          [
            'Alta presión',
            'Hasta cientos de bar',
            'Hidráulica (con bomba hidráulica)',
          ],
        ],
      ),
      Nota(
        'Elige un módulo cuyo rango cubra el del instrumento sin pasarse mucho: la exactitud es un % del fondo de escala del módulo. Ej.: transmisor de 0–10 bar → módulo de unos 20 bar (como el 750P27), no uno de 200 bar.',
      ),
      Subtitulo('Bombas de prueba'),
      TablaGuia(
        ['Bomba', 'Rango típico', 'Fluido'],
        [
          [
            'Baja presión',
            'Vacío a ≈ 1–2,5 bar',
            'Aire. Para DP de caudal y nivel, mbar e inH₂O',
          ],
          [
            'Neumática',
            'Vacío a ≈ 40 bar',
            'Aire. La más usada en transmisores',
          ],
          ['Hidráulica', 'Hasta ≈ 700 bar', 'Agua desmineralizada o aceite'],
        ],
      ),
      Vinetas([
        'Válvula de alivio / venteo: descarga la presión.',
        'Selector presión / vacío (bombas neumáticas).',
        'Ajuste fino (vernier): tornillo para afinar el punto exacto.',
        'Cebado (hidráulicas): llena el circuito sin aire antes de subir presión.',
      ]),
      Subtitulo('Montaje con la bomba'),
      Conexion(
        'Calibración de presión con bomba y módulo',
        [
          EquipoDibujo('Bomba de prueba', [
            Borne('Salida 1'),
            Borne('Salida 2'),
          ], color: Color(0xFF37474F)),
          EquipoDibujo('Módulo 750P', [
            Borne('Presión', lado: Lado.izquierda),
            Borne('Cable', lado: Lado.derecha),
          ], color: Color(0xFF00695C)),
          EquipoDibujo('Fluke 754', [
            Borne('Puerto de presión', color: grisManguera),
          ]),
        ],
        [
          Cable(
            (0, 0),
            (1, 0),
            grisManguera,
            tipo: TipoCable.manguera,
            etiqueta: 'manguera',
          ),
          Cable((1, 1), (2, 0), negroPunta, etiqueta: 'cable del módulo'),
        ],
      ),
      Parrafo(
        'La segunda salida de la bomba (o una T) lleva la misma presión al transmisor.',
      ),
      Subtitulo('Poner a cero el módulo'),
      Pasos([
        'Conecta el módulo al 754 y elige la función de presión: el equipo lo reconoce solo.',
        'Abre la válvula de venteo de la bomba para que el módulo vea la presión atmosférica.',
        'Pulsa ZERO (o la tecla de puesta a cero). En módulos absolutos se introduce la presión barométrica en lugar de hacer cero.',
        'Cierra el venteo y comprueba que no hay fugas: sube a un valor, espera 30 s y la lectura debe quedarse quieta.',
      ]),
      Nota(
        'No superes nunca la presión máxima del módulo ni la del transmisor. Despresuriza siempre antes de desconectar mangueras.',
        peligro: true,
      ),
      Nota(
        'Módulos neumáticos: no los uses con líquidos salvo que el módulo sea compatible (los de alta presión con acero inoxidable sí admiten agua).',
      ),
    ],
    palabras: [
      'presion',
      'modulo',
      '750p',
      '700p',
      'bomba',
      'cero',
      'manometro',
      'hidraulica',
      'neumatica',
    ],
  ),

  // ───────────────────────── 8 ─────────────────────────
  const Capitulo(
    'Recorrido: transmisor de presión',
    'Calibración completa de 5 puntos con bomba y módulo',
    Icons.speed,
    [
      Parrafo(
        'Ejemplo: transmisor HART de 0–10 bar, salida 4–20 mA, tolerancia ±0,25 % del span. Se usa una bomba '
        'neumática, un módulo de ≈ 20 bar y los 24 V del 754.',
      ),
      Conexion(
        'Montaje para calibrar un transmisor de presión',
        [
          EquipoDibujo('Bomba + módulo 750P', [
            Borne('Presión al transmisor'),
            Borne('Cable del módulo'),
          ], color: Color(0xFF37474F)),
          EquipoDibujo('Transmisor de presión', [
            Borne('Toma de presión', lado: Lado.izquierda),
            Borne('Cable al módulo (pasa)', lado: Lado.izquierda),
            Borne('+', color: rojoPunta, lado: Lado.derecha),
            Borne('−', color: negroPunta, lado: Lado.derecha),
          ]),
          _f754Medir,
        ],
        [
          Cable((0, 0), (1, 0), grisManguera, tipo: TipoCable.manguera),
          Cable((1, 2), (2, 2), rojoPunta, etiqueta: 'mA + 24 V'),
          Cable((1, 3), (2, 3), negroPunta),
        ],
      ),
      Nota(
        'El cable del módulo va directo al puerto de presión del 754 (en el dibujo se omite para no cruzar líneas).',
      ),
      Subtitulo('Preparación'),
      Pasos([
        'Aísla el transmisor del proceso (cierra válvulas, abre el venteo del manifold) o llévalo al banco.',
        'Avisa a sala de control: la señal va a moverse. Pon el lazo en manual.',
        'Conecta la bomba a la toma del transmisor y al módulo; el módulo, al 754.',
        'Conecta los mA del 754 al transmisor con alimentación de lazo activada (o mide en serie si sigue en su lazo).',
        'Pon a cero el módulo con el venteo abierto y ciérralo.',
      ]),
      Subtitulo('Configurar el 754'),
      Pasos([
        'Pulsa MEAS: arriba elige presión (del módulo); abajo, mA con alimentación de lazo. En la pantalla dividida verás presión y mA a la vez.',
        'Activa la escala de la presión: 0 % = 0 bar y 100 % = 10 bar. Activa la escala de mA: 4–20 mA. Así ves el error directamente en %.',
        'Si el transmisor es HART, pulsa HART para leer su rango (LRV/URV) y comprobar que coincide con 0–10 bar.',
        'Opcional: usa «As Found» y escribe la tolerancia (0,25 %) y los puntos (0-25-50-75-100 % subiendo, y bajando si se pide histéresis).',
      ]),
      Subtitulo('Recorrido «como se encontró» (As Found)'),
      TablaGuia(
        ['Punto', 'Presión aplicada', 'Salida ideal', 'Límite ±0,25 %'],
        [
          ['0 %', '0,0 bar', '4,000 mA', '3,960 – 4,040'],
          ['25 %', '2,5 bar', '8,000 mA', '7,960 – 8,040'],
          ['50 %', '5,0 bar', '12,000 mA', '11,960 – 12,040'],
          ['75 %', '7,5 bar', '16,000 mA', '15,960 – 16,040'],
          ['100 %', '10,0 bar', '20,000 mA', '19,960 – 20,040'],
        ],
      ),
      Pasos([
        'Sube con la bomba hasta acercarte al punto y afina con el vernier. No te pases: si te pasas, baja por debajo y vuelve a subir (para no falsear la histéresis).',
        'Espera a que la lectura se estabilice (10–30 s) y pulsa «aceptar punto» (o anota los mA).',
        'Repite en todos los puntos subiendo y luego bajando.',
        'El 754 calcula el error: error % = (mA medidos − mA ideales) / 16 × 100.',
        'Si todos los puntos están dentro de tolerancia: PASA, no hace falta ajustar.',
      ]),
      Subtitulo('Ajuste (si no pasa)'),
      Pasos([
        'Transmisor HART: entra en HART → servicios → «trim de sensor» (zero trim con 0 bar aplicado, y lower/upper trim con presiones exactas del módulo).',
        'Después haz «trim de salida» (D/A trim): el transmisor fija 4 mA, escribes lo que mide el 754, y lo mismo a 20 mA.',
        'Transmisor analógico: ajusta los tornillos ZERO (a 0 %) y SPAN (a 100 %); repite cero y span hasta que no cambien.',
      ]),
      Subtitulo('Recorrido «como se dejó» (As Left)'),
      Pasos([
        'Repite los mismos puntos y guarda el resultado.',
        'Ventea, desconecta, vuelve a poner el transmisor en servicio y avisa a sala de control.',
        'En la oficina, descarga los resultados a DPCTrack2 para el certificado.',
      ]),
      Nota(
        'Si el transmisor está montado más alto o más bajo que la toma de proceso con líquido en la línea, ten en cuenta la columna de líquido (≈ 0,1 bar por metro de agua).',
      ),
    ],
    palabras: [
      'calibrar',
      'transmisor',
      'presion',
      'bomba',
      'as found',
      'as left',
      'recorrido',
      'puntos',
      'trim',
    ],
  ),

  // ───────────────────────── 9 ─────────────────────────
  const Capitulo(
    'Recorrido: transmisor de caudal (DP)',
    'Presión diferencial con raíz cuadrada',
    Icons.water,
    [
      Parrafo(
        'Los transmisores de caudal por placa orificio, Venturi o Annubar miden presión DIFERENCIAL. El caudal '
        'es proporcional a la raíz cuadrada de la ΔP. Ejemplo: transmisor 0–250 mbar, 4–20 mA, con extracción '
        'de raíz cuadrada.',
      ),
      Conexion(
        'Transmisor DP: presión en el lado H, lado L a la atmósfera',
        [
          EquipoDibujo('Bomba de baja presión', [
            Borne('Salida'),
          ], color: Color(0xFF37474F)),
          EquipoDibujo('Transmisor DP', [
            Borne('H (alta)', lado: Lado.izquierda),
            Borne('L (baja) → venteo', lado: Lado.izquierda),
            Borne('+', color: rojoPunta, lado: Lado.derecha),
            Borne('−', color: negroPunta, lado: Lado.derecha),
          ]),
          _f754Medir,
        ],
        [
          Cable(
            (0, 0),
            (1, 0),
            grisManguera,
            tipo: TipoCable.manguera,
            etiqueta: 'T al módulo',
          ),
          Cable((1, 2), (2, 2), rojoPunta),
          Cable((1, 3), (2, 3), negroPunta),
        ],
      ),
      Pasos([
        'En el manifold de 3 o 5 válvulas: cierra las de proceso, abre la ecualizadora y ventea. Nunca abras la ecualizadora con las de proceso abiertas.',
        'Conecta la bomba (de baja presión, en mbar) al lado H y al módulo diferencial (o manométrico de bajo rango). Deja el lado L abierto a la atmósfera.',
        'Haz cero del módulo y comprueba los 4 mA a 0 mbar.',
        'Configura la escala del 754 en modo raíz cuadrada (√) si el transmisor saca la señal en caudal.',
      ]),
      Subtitulo('Puntos de calibración'),
      Parrafo(
        'Si el transmisor saca señal LINEAL en ΔP, calibra como uno de presión normal. Si saca CAUDAL (raíz cuadrada activada):',
      ),
      TablaGuia(
        ['Caudal', 'ΔP aplicada', 'Salida'],
        [
          ['0 %', '0 mbar', '4,00 mA'],
          ['25 %', '15,6 mbar (6,25 %)', '8,00 mA'],
          ['50 %', '62,5 mbar (25 %)', '12,00 mA'],
          ['75 %', '140,6 mbar (56,25 %)', '16,00 mA'],
          ['100 %', '250 mbar (100 %)', '20,00 mA'],
        ],
      ),
      Parrafo(
        'Fórmula: mA = 4 + 16 × √(ΔP / ΔPmáx).  ΔP = ΔPmáx × ((mA − 4) / 16)².',
      ),
      Nota(
        'Por debajo de ≈ 1 % de caudal muchos transmisores cortan la raíz a 0 (low flow cut-off): no lo tomes como error.',
      ),
      Subtitulo('Nivel por presión diferencial'),
      Parrafo(
        'En nivel con DP (tanque cerrado) se calibra igual pero LINEAL: ΔP = altura × densidad × g. '
        'Si hay sello o pierna húmeda, el 0 % puede corresponder a una ΔP negativa o elevada (supresión / elevación de cero). '
        'Aplica la presión en H o en L según indique el rango (p. ej. −50 a +150 mbar).',
      ),
    ],
    palabras: [
      'caudal',
      'flujo',
      'dp',
      'diferencial',
      'raiz cuadrada',
      'placa orificio',
      'nivel',
      'manifold',
    ],
  ),

  // ───────────────────────── 10 ─────────────────────────
  const Capitulo(
    'Recorrido: transmisor de temperatura',
    'Simular RTD o termopar y medir los mA',
    Icons.device_thermostat,
    [
      Parrafo(
        'Ejemplo: transmisor Pt100 de 0–150 °C, 4–20 mA, tolerancia ±0,5 % del span.',
      ),
      Conexion(
        'Calibrar transmisor de temperatura con MEDIR / GENERAR',
        [
          _f754Completo,
          EquipoDibujo('Transmisor de temperatura', [
            Borne('Entrada RTD', lado: Lado.izquierda),
            Borne('Entrada RTD (común)', lado: Lado.izquierda),
            Borne('Salida +', lado: Lado.izquierda),
            Borne('Salida −', lado: Lado.izquierda),
          ]),
        ],
        [
          Cable((0, 0), (1, 0), rojoPunta),
          Cable((0, 1), (1, 1), negroPunta),
          Cable((0, 2), (1, 2), rojoPunta, etiqueta: '24 V lazo'),
          Cable((0, 3), (1, 3), negroPunta),
        ],
      ),
      Pasos([
        'Pulsa MEAS/SOURCE: arriba GENERAR RTD Pt100, abajo MEDIR mA con alimentación de lazo.',
        'Escala de mA: 4–20 mA = 0–150 °C, para leer el error directo.',
        'Genera 0 °C y comprueba 4,00 mA; sigue con los demás puntos (o usa el paso automático).',
      ]),
      TablaGuia(
        ['Punto', 'Temperatura', 'Pt100', 'Salida ideal'],
        [
          ['0 %', '0 °C', '100,00 Ω', '4,00 mA'],
          ['25 %', '37,5 °C', '114,58 Ω', '8,00 mA'],
          ['50 %', '75 °C', '128,99 Ω', '12,00 mA'],
          ['75 %', '112,5 °C', '143,24 Ω', '16,00 mA'],
          ['100 %', '150 °C', '157,33 Ω', '20,00 mA'],
        ],
      ),
      Subtitulo('Con termopar'),
      Pasos([
        'Arriba GENERAR TC del tipo correcto (con cable de ese tipo al transmisor).',
        'Abajo MEDIR mA con alimentación de lazo.',
        'Ojo: si el transmisor compensa la unión fría y el 754 también genera compensado, el resultado es correcto. Usa cable de compensación, no cobre.',
      ]),
      Subtitulo('Calibrar el conjunto sensor + transmisor'),
      Parrafo(
        'Para comprobar también el sensor, mete la sonda en un horno o baño de calibración junto a una sonda patrón, mide la temperatura con el 754 y compara con la salida del transmisor.',
      ),
    ],
    palabras: [
      'temperatura',
      'transmisor',
      'rtd',
      'termopar',
      'calibrar',
      'pt100',
      'recorrido',
    ],
  ),

  // ───────────────────────── 11 ─────────────────────────
  const Capitulo(
    'Otros recorridos',
    'Presostatos, convertidores I/P, válvulas e indicadores',
    Icons.toggle_on,
    [
      Subtitulo('Prueba de presostato'),
      Conexion(
        'Presostato con bomba y contacto al 754',
        [
          _f754Medir,
          EquipoDibujo('Presostato', [Borne('C (común)'), Borne('NO / NC')]),
        ],
        [
          Cable((0, 0), (1, 0), rojoPunta, etiqueta: 'medir continuidad'),
          Cable((0, 1), (1, 1), negroPunta),
        ],
      ),
      Pasos([
        'Conecta la bomba al presostato y al módulo; los contactos del presostato a los bornes de medida (función de prueba de interruptor).',
        'Elige la prueba de interruptor (switch test) e indica el valor esperado y si es de contacto seco o con tensión.',
        'Sube la presión DESPACIO con el vernier hasta que cambie el contacto: el 754 guarda la presión de disparo.',
        'Baja despacio hasta que vuelva: guarda la presión de rearme. Banda muerta = disparo − rearme.',
        'Repite 2–3 veces para ver la repetibilidad.',
      ]),
      Subtitulo('Convertidor I/P (4–20 mA → 0,2–1 bar)'),
      Pasos([
        'GENERA mA hacia el convertidor (rojo a +, negro a −).',
        'MIDE la presión de salida con un módulo conectado a la salida del I/P (alimentado con aire a ≈ 1,4 bar).',
        'Puntos: 4 mA → 0,2 bar; 8 → 0,4; 12 → 0,6; 16 → 0,8; 20 → 1,0 bar (3–15 psi).',
        'Ajusta ZERO a 4 mA y SPAN a 20 mA.',
      ]),
      Subtitulo('Posicionador de válvula'),
      Pasos([
        'GENERA 4, 8, 12, 16 y 20 mA (o simula si el lazo tiene fuente) y comprueba la apertura: 0, 25, 50, 75 y 100 %.',
        'Con posicionador HART, lee la posición real y la señal de retorno con el comunicador del 754.',
        'Usa la rampa para ver si la válvula se mueve suave o a saltos (fricción).',
      ]),
      Subtitulo('Indicador o entrada de PLC'),
      Pasos([
        'GENERA o SIMULA la señal (mA, V, RTD, TC) con el paso automático.',
        'Anota lo que marca el indicador o el SCADA en cada punto.',
        'Error % = (lectura − ideal) / span × 100.',
      ]),
      Subtitulo('Caudalímetro de pulsos'),
      Pasos([
        'GENERA frecuencia (Hz) hacia el totalizador o PLC para comprobar el factor K.',
        'O MIDE la frecuencia que da el caudalímetro: caudal = frecuencia / factor K.',
      ]),
    ],
    palabras: [
      'presostato',
      'switch',
      'i/p',
      'convertidor',
      'valvula',
      'posicionador',
      'indicador',
      'pulsos',
      'caudalimetro',
    ],
  ),

  // ───────────────────────── 12 ─────────────────────────
  const Capitulo(
    'HART',
    'Comunicador integrado: leer, cambiar rango y trims',
    Icons.settings_input_antenna,
    [
      Parrafo(
        'HART superpone una señal digital (1200 / 2200 Hz) sobre los 4–20 mA. El 754 puede leer y '
        'cambiar la configuración de transmisores de los principales fabricantes (Rosemount, Endress+Hauser, '
        'Yokogawa, Siemens, ABB…). Necesita al menos 250 Ω en el lazo.',
      ),
      Subtitulo('Conexión'),
      Vinetas([
        'En banco: bornes mA con alimentación de lazo de 24 V y resistencia HART interna de 250 Ω activada.',
        'En campo: en paralelo con el transmisor o con la resistencia del lazo (cables HART del kit), sin abrir el lazo. El lazo ya tiene su fuente y su resistencia.',
      ]),
      Subtitulo('Qué se puede hacer'),
      TablaGuia(
        ['Menú', 'Para qué'],
        [
          [
            'Conectar',
            'Busca el equipo (dirección 0; en multidrop, de 1 a 15 o 63)',
          ],
          ['Información', 'Tag, fabricante, modelo, nº de serie, versión'],
          ['Variables', 'PV (variable primaria), % de rango, mA, SV/TV/QV'],
          ['Rango (LRV / URV)', 'Valores de 4 y 20 mA'],
          ['Unidades', 'bar, kPa, °C…'],
          ['Amortiguación', 'Damping en segundos'],
          ['Función de transferencia', 'Lineal o raíz cuadrada'],
          [
            'Cambiar rango (re-range)',
            'Con teclado (escribes LRV/URV) o aplicando la presión real',
          ],
          [
            'Prueba de lazo (loop test)',
            'El transmisor fija la corriente que pidas (4, 12, 20 mA…) para probar el lazo',
          ],
          [
            'Trim de salida (D/A)',
            'Ajusta la salida analógica a lo que mide el 754',
          ],
          [
            'Trim de sensor',
            'Ajusta la lectura digital del sensor (cero, bajo y alto)',
          ],
          ['Cambiar tag / descripción', 'Identificación del equipo'],
          ['Protección de escritura', 'Ver si está bloqueado'],
        ],
      ),
      Subtitulo('Ejemplo: cambiar el rango de 0–10 a 0–6 bar'),
      Pasos([
        'Conecta y pulsa HART. Espera a que aparezca el tag y la PV.',
        'Entra en configuración → rango.',
        'Escribe LRV = 0 bar, URV = 6 bar y envía.',
        'Comprueba: aplica 3 bar y deberías leer 12 mA.',
        'Avisa a control: también hay que cambiar la escala en el PLC / SCADA.',
      ]),
      Subtitulo('Orden correcto de ajuste'),
      Pasos([
        '1.º Trim de sensor (para que la PV digital sea correcta).',
        '2.º Trim de salida (para que los mA reflejen la PV).',
        '3.º Re-range solo si cambia el rango de trabajo (no corrige errores).',
      ]),
      Nota(
        'Re-range NO es calibrar: si el sensor mide mal, cambiar el rango no lo arregla.',
      ),
    ],
    palabras: [
      'hart',
      'comunicador',
      'rango',
      'lrv',
      'urv',
      'trim',
      'loop test',
      'rosemount',
      'tag',
    ],
  ),

  // ───────────────────────── 13 ─────────────────────────
  const Capitulo(
    'Documentar y tareas',
    'As Found / As Left, tolerancias y PC',
    Icons.assignment_turned_in,
    [
      Parrafo(
        'La «D» de calibrador documentador: el 754 guarda cada calibración con el tag, la fecha, los puntos, '
        'los errores y si pasa o no pasa. Así se generan los certificados en el PC.',
      ),
      Subtitulo('Flujo de trabajo'),
      Pasos([
        'En el PC (DPCTrack2) crea los instrumentos con su tag, rango, tolerancia y puntos de prueba.',
        'Envía las tareas al 754 por USB.',
        'En campo: carga la tarea, conecta según indica y ejecuta «As Found».',
        'Si no pasa, ajusta y ejecuta «As Left».',
        'De vuelta, descarga los resultados al PC, revisa e imprime el certificado.',
      ]),
      Subtitulo('Datos de una tarea'),
      TablaGuia(
        ['Campo', 'Ejemplo'],
        [
          ['Tag', 'PT-101'],
          ['Entrada (generar o medir)', 'Presión 0–10 bar (módulo)'],
          ['Salida (medir)', 'mA 4–20, alimentación de lazo'],
          ['Función', 'Lineal / raíz cuadrada'],
          ['Tolerancia', '±0,25 % del span'],
          ['Puntos', '0, 25, 50, 75, 100 % (subiendo y bajando)'],
          ['Tiempo de espera', '10 s por punto'],
        ],
      ),
      Subtitulo('Cálculo del error'),
      Parrafo(
        'Error (% del span) = (salida medida − salida ideal) / (salida máx. − salida mín.) × 100',
      ),
      Parrafo(
        'Ejemplo: a 50 % se esperaban 12,000 mA y se miden 12,030 mA → (0,030 / 16) × 100 = 0,19 % → pasa con tolerancia 0,25 %.',
      ),
      Nota(
        'Usa la calculadora «Tabla de calibración» (pestaña Cálculos → Industrial) para hacer este cálculo en todos los puntos.',
      ),
    ],
    palabras: [
      'documentar',
      'as found',
      'as left',
      'tarea',
      'dpctrack',
      'certificado',
      'tolerancia',
      'error',
    ],
  ),

  // ───────────────────────── 14 ─────────────────────────
  const Capitulo(
    'Problemas y seguridad',
    'Fallos típicos y cómo resolverlos',
    Icons.build,
    [
      TablaGuia(
        ['Problema', 'Causa probable', 'Solución'],
        [
          [
            'Leo 0 mA alimentando el transmisor',
            'Lazo de 24 V desactivado o polaridad invertida',
            'Activa la alimentación de lazo; rojo al + del transmisor',
          ],
          [
            'El transmisor no llega a 20 mA',
            'Demasiada resistencia en el lazo',
            'Quita resistencias extra: con 24 V caben unos 500 Ω en el lazo (según la tensión mínima del transmisor)',
          ],
          [
            'HART no conecta',
            'Falta la resistencia de 250 Ω o dirección distinta de 0',
            'Activa la resistencia HART o conéctate en paralelo a la del lazo; busca en multidrop',
          ],
          [
            'La presión baja sola',
            'Fuga en racores o manguera',
            'Aprieta, cambia juntas y repite la prueba de fugas',
          ],
          [
            'La lectura de presión no vuelve a cero',
            'Módulo sin poner a cero o con presión atrapada',
            'Ventea y pulsa ZERO',
          ],
          [
            'Error de varios grados con termopar',
            'Cable de cobre o de otro tipo, conector caliente',
            'Usa cable y miniconector del mismo tipo, espera a que se estabilice',
          ],
          [
            'Simulación de mA inestable',
            'Elegiste «generar» en un lazo con fuente',
            'Cambia a «simular transmisor»',
          ],
          [
            'La lectura de RTD salta',
            'Transmisor con excitación pulsada',
            'Activa la opción de RTD pulsada si existe; consulta el manual',
          ],
          [
            'No mide mA',
            'Fusible fundido',
            'Comprueba y cambia el fusible por uno del mismo tipo',
          ],
        ],
      ),
      Subtitulo('Seguridad'),
      Vinetas([
        'No apliques más de 300 V entre bornes ni entre un borne y tierra.',
        'Nunca conectes los bornes de mA a una fuente de tensión.',
        'Desconecta las puntas del circuito antes de cambiar de función.',
        'El 754 estándar NO es intrínsecamente seguro: no lo uses en zonas con atmósfera explosiva sin permiso de trabajo en caliente o la versión Ex adecuada.',
        'Despresuriza siempre antes de soltar racores; usa gafas con presiones altas.',
        'Antes de tocar un lazo en servicio, avisa a sala de control y pon el lazo en manual o en bypass.',
      ]),
      Nota(_avisoVersion),
    ],
    palabras: ['problemas', 'fallos', 'seguridad', 'fusible', 'hart', 'fuga'],
  ),
]);
