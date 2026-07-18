import 'package:findmyot/providers/devices_provider.dart';
import 'package:findmyot/providers/auth_provider.dart';
import 'package:findmyot/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:findmyot/screens/login_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        Provider(create: (context) => ApiService()),
        ChangeNotifierProvider(create: (context) => DevicesProvider(apiService: context.read<ApiService>())),
        ChangeNotifierProvider(create: (context) => AuthProvider(apiService: context.read<ApiService>()))
      ],
      child: MyApp()
    )
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(fontFamily: "Headline"),
      home: const LoginScreen(),
    );
  }
}