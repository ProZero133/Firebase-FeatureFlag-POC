import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'next_screen.dart';

// Firebase Analytics instance to track user properties
final FirebaseAnalytics analytics = FirebaseAnalytics.instance;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize Firebase
  await Firebase.initializeApp();
  await analytics.setUserProperty(name: 'Beta_access', value: true.toString());
  await analytics.setUserProperty(name: 'user_id', value: '123456');
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
  // Variables to hold remote config values
  String _message = 'Loading...';
  bool _showAndroidVersion = false;
  bool _betaAccess = false;
  bool _enableNextScreen = false;

  @override
  void initState() {
    super.initState();
    // Fetch remote config values when the app starts
    fetchRemoteConfig();
  }


// Fetch remote config values from Firebase (Execute this every time you want to check for updates in Firebase Console)
  Future<void> fetchRemoteConfig() async {
    // Instantiate Firebase Remote Config
    final remoteConfig = FirebaseRemoteConfig.instance;

    // Set config settings
    // Fetch timeout is set to 10 seconds, and minimum fetch interval is set to 0 seconds
    await remoteConfig.setConfigSettings(RemoteConfigSettings(
      fetchTimeout: const Duration(seconds: 10),
      minimumFetchInterval: const Duration(seconds: 0),
    ));

    // Set default values for the remote config parameters in case they are not set in Firebase Console
    // or if the fetch fails
    await remoteConfig.setDefaults({
      'show_android_version': false,
      'welcome_message': 'Bienvenido a la app',
      'Beta_access': false,
    });

    // Fetch config values
    await remoteConfig.fetchAndActivate();
    setState(() {
      // Get the values from remote config as remoteConfig.typeOfVariable('keyValue in Firebase Console')
      _message = remoteConfig.getString('welcome_message');
      _showAndroidVersion = remoteConfig.getBool('show_android_version');
      _enableNextScreen = remoteConfig.getBool('show_beta_feature');

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
            ElevatedButton(
              onPressed: fetchRemoteConfig,
              child: const Text('Refresh Config'),
            ),
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
              const SizedBox(height: 40),
            ElevatedButton(
              // Enable the button only if enabled in Firebase Remote Config
              onPressed: _enableNextScreen
                  ? () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const NextScreen(),
                        ),
                      );
                    }
                  : null,
              child: const Text('Next Screen (Beta Feature)'),
            ),
          ],
        ),
      ),
    );
  }
}

