import "package:flutter/material.dart";
import "package:provider/provider.dart";
import "./theme.dart";
import 'dart:async';
import 'package:flutter_blue/flutter_blue.dart';

import "package:shared_preferences/shared_preferences.dart";

class BluetoothPopUp extends StatefulWidget {
  const BluetoothPopUp({Key? key, required this.devicesList}) : super(key: key);

  final List<BluetoothDevice> devicesList;

  @override
  _BluetoothPopUpState createState() => _BluetoothPopUpState();
}

class _BluetoothPopUpState extends State<BluetoothPopUp> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Bluetooth Devices available'),
      content: SizedBox(
        height: 200,
        width: 300,
        child: ListView.builder(
          itemCount: widget.devicesList.length, //diagrafoume
          itemBuilder: (BuildContext context, int index) {
            return ListTile(
              title: Text(widget.devicesList[index].name), //allazoume
              subtitle:
                  Text(widget.devicesList[index].id.toString()), //allazoume
            );
          },
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Close'),
        ),
      ],
    );
  }
}

class SettingsPage extends StatefulWidget {
  @override
  _SettingsState createState() => _SettingsState();
}

class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;
  ThemeData _lightTheme = ThemeData(brightness: Brightness.light);
  ThemeData _darkTheme = ThemeData(brightness: Brightness.dark);

  ThemeMode getThemeMode() => _themeMode;

  setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
  }

  ThemeData get lightTheme => _lightTheme;
  ThemeData get darkTheme => _darkTheme;
}

class _SettingsState extends State<SettingsPage> {
  bool darkMode = false;
  bool bluetooth = false;
  bool NFC = false;

  FlutterBlue flutterBlue = FlutterBlue.instance;
  List<BluetoothDevice> _devicesList = [];

  @override
  void initState() {
    super.initState();
    _loadDarkMode();
    _loadBluetooth();
    _loadNFC();
  }

  //shared preferences for dark mode
  Future<void> _loadDarkMode() async {
    final prefs = await SharedPreferences.getInstance();
    final isDarkMode = prefs.getBool('darkMode') ?? false;
    setState(() {
      darkMode = isDarkMode;
    });
  }

  Future<void> _saveDarkMode(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('darkMode', value);
  }

  //shared preferences for bluetooth
  Future<void> _loadBluetooth() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isBluetoothEnabled = prefs.getBool('bluetooth') ?? false;
    setState(() {
      bluetooth = isBluetoothEnabled;
    });
  }

  Future<void> _saveBluetooth(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('bluetooth', value);
  }

  //shared preferences for NFC
  Future<void> _loadNFC() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isNFC = prefs.getBool('NFC') ?? false;
    setState(() {
      NFC = isNFC;
    });
  }

  Future<void> _saveNFC(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('NFC', value);
  }

  // Start scanning for Bluetooth devices
  void _startScanning() {
    flutterBlue.scanResults.listen((results) {
      setState(() {
        _devicesList = results.map((r) => r.device).toList();
      });
    });
    flutterBlue.startScan(timeout: Duration(seconds: 4));
    flutterBlue.stopScan();
    showDialog(
      context: context,
      builder: (BuildContext context) => BluetoothPopUp(
        devicesList: _devicesList,
      ),
    );
  }

  // Stop scanning for Bluetooth devices
  Future<void> _stopScanning() async {
    flutterBlue.stopScan();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    _loadDarkMode().then((value) {
      themeProvider.setThemeMode(darkMode ? ThemeMode.dark : ThemeMode.light);
    });

    ThemeData _lightTheme = lightTheme;
    ThemeData _darkTheme = darkTheme;

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Settings"),
          centerTitle: true,
          leading: Builder(
            builder: (BuildContext context) {
              return IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.settings));
            },
          ),
        ),
        body: Column(
          children: <Widget>[
            //Dark Mode switch
            ListTile(
              title: const Text("Dark Mode"),
              trailing: Switch(
                value: darkMode,
                onChanged: (value) {
                  _saveDarkMode(value);
                  ThemeMode themeMode =
                      value ? ThemeMode.dark : ThemeMode.light;
                  Provider.of<ThemeProvider>(context, listen: false)
                      .setThemeMode(themeMode);
                },
              ),
            ),
            const Divider(
              height: 20,
              thickness: 1,
              indent: 15,
              endIndent: 15,
              color: Colors.black,
            ),
            ListTile(
              title: const Text("Bluetooth"),
              trailing: Switch(
                value: bluetooth,
                onChanged: (value) async {
                  SharedPreferences prefs =
                      await SharedPreferences.getInstance();
                  setState(() {
                    bluetooth = value;
                  });
                  await prefs.setBool('bluetooth', value);
                  if (value) {
                    _startScanning();
                  } else {
                    _stopScanning();
                  }
                },
              ),
            ),
            const Divider(
              height: 20,
              thickness: 1,
              indent: 15,
              endIndent: 15,
              color: Colors.black,
            ),
            ListTile(
              title: const Text("NFC"),
              trailing: Switch(
                value: NFC,
                onChanged: (value) async {
                  SharedPreferences prefs =
                      await SharedPreferences.getInstance();
                  setState(() {
                    NFC = value;
                  });
                  await prefs.setBool('NFC', value);
                },
              ),
            ),
            const Divider(
              height: 20,
              thickness: 1,
              indent: 15,
              endIndent: 15,
              color: Colors.black,
            ),
          ],
        ),
      ),
    );
  }
}
