import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main(){
    runApp(const DemonModeApp());

}

class DemonModeApp extends StatelessWidget{
    const DemonModeApp({super.key});

    @override
    Widget build(BuildContext context){
    return MaterialApp(
        title : 'Demon Mode Protocol',
        theme : ThemeData.dark().copyWith(
            primaryColor : Colors.red,
            scaffoldBackgroundColor:Colors.black,
            appBarTheme: const AppBarTheme(
                backgroundColor : Colors.black ,
                foregroundColor : Colors.red,
            ),
            elevatedButtonTheme:ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                    backgroundColor : Colors.red,
                    foregroundColor : Colors.black,
                ),
            ),
        ),
        home: const HomeScreen(),
        );
    }
}