import 'package:flutter/material.dart';

Map<int, Color> oliveMap = {
  50: const Color.fromRGBO(53, 95, 80, .1),
  100: const Color.fromRGBO(53, 95, 80, .2),
  200: const Color.fromRGBO(53, 95, 80, .3),
  300: const Color.fromRGBO(53, 95, 80, .4),
  400: const Color.fromRGBO(53, 95, 80, .5),
  500: const Color.fromRGBO(53, 95, 80, .6),
  600: const Color.fromRGBO(53, 95, 80, .7),
  700: const Color.fromRGBO(53, 95, 80, .8),
  800: const Color.fromRGBO(53, 95, 80, .9),
  900: const Color.fromRGBO(53, 95, 80, 1),
};
MaterialColor olive = MaterialColor(0xFF355F50, oliveMap);
// Use ezgif.com to change the loading screen animation GIF file:
//  1. convert to monochrome, 2. change background colour

var mbRegisters = List<int>.filled(64, 0);
int selectedSeeker = 0;
String selectedDeviceName = '';

enum BleSet { idle, scanning, connected }

var bleState = BleSet.idle;
