import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

final FirebaseAnalytics analytics = FirebaseAnalytics.instance;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await analytics.setUserProperty(name: 'beta_user', value: 'true');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Remote Config Demo',
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _message = 'Cargando...';
  bool _showAndroidVersion = false;

  @override
  void initState() {
    super.initState();
    fetchRemoteConfig();
  }

  Future<void> fetchRemoteConfig() async {
    final remoteConfig = FirebaseRemoteConfig.instance;

    await remoteConfig.setConfigSettings(RemoteConfigSettings(
      fetchTimeout: const Duration(seconds: 10),
      minimumFetchInterval: const Duration(seconds: 0),
    ));

    // Set default values for the remote config parameters
    await remoteConfig.setDefaults({
      'show_android_version': false,
      'welcome_message': 'Bienvenido a la app',
    });

    // Fetch config values
    await remoteConfig.fetchAndActivate();
    setState(() {
      // Get the values from remote config as remoteConfig.typeOfVariable('keyValue in Firebase Console')
      _message = remoteConfig.getString('welcome_message');
      _showAndroidVersion = remoteConfig.getBool('show_android_version');
      print('\x1B[32mIs user device android?: $_showAndroidVersion\x1B[0m');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Remote Config Demo')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _message,
              style: const TextStyle(fontSize: 24),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            // Display only if the user is on Android
            if (_showAndroidVersion)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  '¡Exclusive Android Feature!',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

