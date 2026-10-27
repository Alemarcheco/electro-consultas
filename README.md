# Electro Consultas

App de consulta de electricidad y electrónica en español, sin conexión, al estilo de ElectroDroid. Hecha con Flutter (Android e iOS).

- **Solar:** configurador de sistemas aislados (consumos, horas de sol pico por ciudad, paneles, baterías, reguladores PWM/MPPT e inversores de Jinko, LONGi, Canadian, JA, Trina, Pylontech, Trojan, Ritar, Ultracell, Victron, EPEver, Renogy, Growatt, Deye, Huawei, Fronius y SMA), autoconsumo con red, 8 ejemplos resueltos y tablas solares.
- **Calculadoras (22):** código de colores (4/5/6 bandas y de valor a colores), resistencias SMD, código de condensadores, ley de Ohm, serie/paralelo, divisor de tensión, resistencia para LED, potencia (continua, monofásica, trifásica), 555, filtro RC/RL, reactancia y resonancia, LM317, zener, amplificador operacional, decibelios, caída de tensión y sección de cable, AWG, consumo y coste, duración de batería, escalado 4–20 mA, tabla de calibración (3/5/11 puntos, error % del span) y CRC Modbus.
- **Pinouts (61):** USB (A, micro, 3.0, C), fuente ATX, CPU, PCIe, SATA, Molex, ventilador, PS/2, RS-232, HDMI, VGA, DisplayPort, jack, XLR, MIDI, RJ45 (T568A/B), RJ11, OBD-II, Raspberry Pi, Arduino (Uno, Nano, Mega, Leonardo, Pro Mini), ESP32, ESP8266, módulos para Arduino, ICSP, circuitos integrados, reguladores, transistores y sensores; industriales: Modbus RJ45/DB9, Profibus, CAN, DeviceNet, M12, borneras RS-485/422, transmisores 4–20 mA y caja de bornes de motor.
- **Referencias (46 tablas):** códigos, series E, prefijos, fórmulas, conversiones, AWG, intensidad admisible, colores de cables, magnetotérmicos y diferenciales, fusibles, IP, tensiones por país, enchufes, resistividad, aislantes, soldadura, condensadores, pilas, LED, diodos, zener, transistores, reguladores, buses, direcciones I²C, ASCII, Arduino y redes industriales (buses de campo, RS-232/422/485, funciones Modbus, Profibus, CAN, señales analógicas, PNP/NPN, termopares y RTD, topologías).
- **Guías:** guía completa del Fluke 754 en 14 capítulos (partes, menús, conexiones dibujadas, lazos 4–20 mA, temperatura, módulos y bombas de presión, recorridos de calibración de transmisores de presión, caudal por DP y temperatura, HART, documentación y seguridad). Guía de elaboración propia; el manual oficial está en fluke.com.

Buscador global con el icono de la lupa.

## Compilar

GitHub Actions compila el APK en cada push a `main` (pestaña Actions → la última ejecución → Artifacts → `electro-consultas-apk`).

En local: `flutter pub get && flutter test && flutter build apk --release`.
