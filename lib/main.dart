import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/material.dart';
import 'input_screen.dart';

// Define primary colors
const Color riceSafeGreen = Color(0xFF00897B);
const Color riceSafeDarkGreen = Color(0xFF00695C);
const Color riceSafeLightBackground = Color(0xFFF8F9FA);
const Color riceSafeTextPrimary = Color(0xFF212529);
const Color riceSafeTextSecondary = Color(0xFF495057);
const Color riceSafeBorderColor = Color(0xFFDEE2E6);

void main() async {
  try {
    await dotenv.load(fileName: ".env");
    print(".env file loaded successfully!");
  } catch (e) {
    print("Error loading .env file: $e");
  }
  runApp(const RiceSafeApp());
}

class RiceSafeApp extends StatelessWidget {
  const RiceSafeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RiceSafe',
      theme: ThemeData(
        primaryColor: riceSafeGreen,
        scaffoldBackgroundColor: riceSafeLightBackground,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 1,
          iconTheme: const IconThemeData(color: riceSafeDarkGreen),
          titleTextStyle: TextStyle(
            color: riceSafeDarkGreen,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontFamily: 'Roboto',
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: riceSafeGreen,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(
              vertical: 15.0,
              horizontal: 24.0,
            ),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              fontFamily: 'Roboto',
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            elevation: 2,
          ),
        ),
        textTheme: TextTheme(
          // For section titles like "อัปโหลดรูปภาพ"
          titleMedium: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: riceSafeTextPrimary,
            fontFamily: 'Roboto',
          ),
          // For main content text
          bodyLarge: TextStyle(
            fontSize: 16.0,
            color: riceSafeTextPrimary,
            height: 1.5,
            fontFamily: 'Roboto',
          ),
          // For secondary text
          bodyMedium: TextStyle(
            fontSize: 14.0,
            color: riceSafeTextSecondary,
            height: 1.4,
            fontFamily: 'Roboto',
          ),
          // For the disease name on result screen
          headlineSmall: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: riceSafeTextPrimary,
            fontFamily: 'Roboto',
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          hintStyle: TextStyle(color: Colors.grey[400], fontFamily: 'Roboto'),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide(color: riceSafeBorderColor),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide(color: riceSafeBorderColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: const BorderSide(color: riceSafeGreen, width: 1.5),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16.0,
            vertical: 20.0,
          ),
        ),
        cardTheme: CardTheme(
          elevation: 1.5,
          margin: const EdgeInsets.symmetric(vertical: 8.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          color: Colors.white,
        ),
        dividerTheme: DividerThemeData(
          color: riceSafeBorderColor.withOpacity(0.7),
          thickness: 0.8,
        ),
        iconTheme: const IconThemeData(color: riceSafeGreen),
        colorScheme: ColorScheme.fromSeed(
          seedColor: riceSafeGreen,
          primary: riceSafeGreen,
          secondary: riceSafeDarkGreen,
          background: riceSafeLightBackground,
          onPrimary: Colors.white,
          onBackground: riceSafeTextPrimary,
        ).copyWith(surface: Colors.white),
      ),
      debugShowCheckedModeBanner: false,
      home: const InputScreen(),
    );
  }
}
