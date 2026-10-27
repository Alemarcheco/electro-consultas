# Electro Consultas

App de consulta de electricidad y electrónica en español, sin conexión, al estilo de ElectroDroid. Hecha con Flutter (Android e iOS).

- **Calculadoras (19):** código de colores (4/5/6 bandas y de valor a colores), resistencias SMD, código de condensadores, ley de Ohm, serie/paralelo, divisor de tensión, resistencia para LED, potencia (continua, monofásica, trifásica), 555, filtro RC/RL, reactancia y resonancia, LM317, zener, amplificador operacional, decibelios, caída de tensión y sección de cable, AWG, consumo y coste, duración de batería.
- **Pinouts (52):** USB (A, micro, 3.0, C), fuente ATX, CPU, PCIe, SATA, Molex, ventilador, PS/2, RS-232, HDMI, VGA, DisplayPort, jack, XLR, MIDI, RJ45 (T568A/B), RJ11, OBD-II, Raspberry Pi, Arduino (Uno, Nano, Mega, Leonardo, Pro Mini), ESP32, ESP8266, módulos para Arduino, ICSP, circuitos integrados, reguladores, transistores y sensores.
- **Referencias (36 tablas):** códigos, series E, prefijos, fórmulas, conversiones, AWG, intensidad admisible, colores de cables, magnetotérmicos y diferenciales, fusibles, IP, tensiones por país, enchufes, resistividad, aislantes, soldadura, condensadores, pilas, LED, diodos, zener, transistores, reguladores, buses, direcciones I²C, ASCII y Arduino.

Buscador global con el icono de la lupa.

## Compilar

GitHub Actions compila el APK en cada push a `main` (pestaña Actions → la última ejecución → Artifacts → `electro-consultas-apk`).

En local: `flutter pub get && flutter test && flutter build apk --release`.
