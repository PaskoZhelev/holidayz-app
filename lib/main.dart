import 'package:Holidayz/pages/home_page.dart';
import 'package:Holidayz/provider/holiday_provider.dart';
import 'package:Holidayz/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => HolidayProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: customDarkTheme1,
        home: HomePage(),
      ),
    );
  }
}

