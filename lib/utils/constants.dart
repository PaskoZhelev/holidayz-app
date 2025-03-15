
import 'package:Holidayz/utils/text_style.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const DB_NAME = "holidayz.db";

const DB_VERSION = 1;

const MIN_YEAR = 2024;
const MAX_YEAR = 2050;

var RAILEWAY_FONT = GoogleFonts.ralewayTextTheme();
var UBUNTU_FONT = GoogleFonts.ubuntuTextTheme();
var KANIT_FONT = GoogleFonts.kanitTextTheme();
var MULISH_FONT = GoogleFonts.mulishTextTheme();
var JOSEFIN_FONT = GoogleFonts.josefinSansTextTheme();
var JOST_FONT = GoogleFonts.jostTextTheme();
var CABIN_FONT = GoogleFonts.cabinTextTheme();

var MAIN_TEXT_THEME = CABIN_FONT;

var darkTheme = ThemeData.dark().copyWith(
      primaryColor: mainColor1,
      scaffoldBackgroundColor: const Color(0xFF101010),
      textTheme: TextThemeColor.nullFontColor(MAIN_TEXT_THEME),
      primaryTextTheme: TextThemeColor.nullFontColor(MAIN_TEXT_THEME),
  colorScheme: ThemeData.dark().colorScheme.copyWith(
    primary: mainColor1,
  ),
    );

var TEAL_COLOR = Colors.teal;
var DARK_COLOR = const Color(0xFF282828);

var mainColor1 = TEAL_COLOR;

var EXCHANGE_RATE_API_KEY = '370ec24e8136672e91000cdc';

extension NumberFormatting on num {
  String toCleanString() {
    return this % 1 == 0
        ? toInt().toString()
        : toString();
  }
}
