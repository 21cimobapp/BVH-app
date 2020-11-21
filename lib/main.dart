import 'package:civideoconnectadmin/StartScreen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:civideoconnectadmin/theme.dart';
import 'package:civideoconnectadmin/custom_theme.dart';
import 'package:civideoconnectadmin/providers/countries.dart';
import 'package:civideoconnectadmin/providers/phone_auth.dart';

void main() {
  runApp(
    CustomTheme(
      initialThemeKey: MyThemeKeys.LIGHT1,
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (context) => CountryProvider(),
          ),
          ChangeNotifierProvider(
            create: (context) => PhoneAuthDataProvider(),
          ),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Video Connect Admin App',
          theme: CustomTheme.of(context),
          home: StartScreen(),
        )
        //home :HomePageNew(),

        );
  }
}
