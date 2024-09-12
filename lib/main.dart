import 'dart:async';
import 'dart:math' as math;

import "package:flutter/material.dart";
import "package:provider/provider.dart";
import "package:camera/camera.dart";
import "package:tflite/tflite.dart";

import "./config_page.dart";
import "./settings_page.dart";
import "./history_page.dart";
import "./history_details_page.dart";
import "./theme.dart";
import "./bindbox.dart";
import "./sqlite_service.dart";

Future<void> main() async {
  // Ensure that plugin services are initialized so that availableCameras()
  // can be called before runApp()
  WidgetsFlutterBinding.ensureInitialized();
  //initialize database, only called once here
  //further operations are performed through mySqliteService global variable
  mySqliteService.initializeDB();

  // Obtain a list of the available cameras on the device.
  final cameras = await availableCameras();

  // Get a specific camera from the list of available cameras.
  final firstCamera = cameras.first;

  runApp(
    ChangeNotifierProvider<ThemeProvider>(
        create: (_) => ThemeProvider(), child: MyApp(firstCamera)),
  );
}

class MyApp extends StatelessWidget {
  final PageController _page_controller = PageController();
  final CameraDescription _firstCamera;

  MyApp(this._firstCamera);

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return MaterialApp(
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: themeProvider.getThemeMode(),
      title: "Indiecisive",
      home: PageView(
        controller: _page_controller,
        children: <Widget>[
          CameraPage(_firstCamera),
          ConfigurationPage(),
          HistoryPage(),
        ],
      ),
    );
  }
}

class CameraPage extends StatefulWidget {
  final CameraDescription _myCamera;

  CameraPage(this._myCamera);

  @override
  _CameraPageState createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  late CameraController _cameraController;
  bool isDetecting = false;
  //dummy data to insert to local database when camera button is pressed
  //haven't managed to take picture from camera, throws error
  final List<String> _dummyTitle = [
    "Brave New World",
    "Appetite for Destruction",
    "Pokemon",
    "Civilization V",
  ];
  final List<String> _dummyCategory = [
    "Books",
    "Music",
    "Movies",
    "Games",
  ];
  final List<List<String>> _dummyChoices = [
    [
      "assets/images/1984 cover.jpg",
      "assets/images/Da Vinci's Code.jpg",
      "assets/images/The Great Gatsby.jpg",
    ],
    [
      "assets/images/And_Justice_For_All_Album_Cover.jpg",
      "assets/images/Fleetwood_Mac_Album_Cover.png",
      "assets/images/human touch cover.jpg",
    ],
    [
      "assets/images/Avatar.jpg",
      "assets/images/Asterix and Obelix.jpg",
      "assets/images/Matrix.jpg",
    ],
    [
      "assets/images/Project Zomboid.jpg",
      "assets/images/RDR2.jpg",
      "assets/images/AOE3.jpg",
    ],
  ];
  final List<String> _dummyImage = [
    ("assets/images/Brave New World cover.jpg"),
    ("assets/images/appetite for destruction cover.jpg"),
    ("assets/images/Pokemon.jpg"),
    ("assets/images/Civilization V.jpg"),
  ];

  //for object identification
  List<dynamic> _recognitions = [];
  int _imageHeight = 0;
  int _imageWidth = 0;
  String _model = "";

  @override
  void initState() {
    super.initState();
    loadModel();
  }

  Future<void> startCamera() async {
    _cameraController =
        CameraController(widget._myCamera, ResolutionPreset.max);
  }

  setRecognitions(recognitions, imageHeight, imageWidth) {
    setState(() {
      _recognitions = recognitions;
      _imageHeight = imageHeight;
      _imageWidth = imageWidth;
    });
  }

  late final cameraInit = Future.wait([
    startCamera(),
    _cameraController.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});

      _cameraController.startImageStream((CameraImage img) {
        if (!isDetecting) {
          isDetecting = true;

          int startTime = new DateTime.now().millisecondsSinceEpoch;
          Tflite.detectObjectOnFrame(
            bytesList: img.planes.map((plane) {
              return plane.bytes;
            }).toList(),
            model: "SSDMobileNet",
            imageHeight: img.height,
            imageWidth: img.width,
            imageMean: 127.5,
            imageStd: 127.5,
            numResultsPerClass: 1,
            threshold: 0.4,
          ).then((recognitions) {
            if (!mounted) {
              return;
            }
            int endTime = new DateTime.now().millisecondsSinceEpoch;
            print("Detection took ${endTime - startTime}");

            setRecognitions(recognitions, img.height, img.width);

            isDetecting = false;
          });
        }
      });
    }),
  ]);

  loadModel() async {
    String? res;
    res = await Tflite.loadModel(
        model: "assets/detect.tflite", labels: "assets/labelmap.txt");
    print(res);
  }

  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Home"),
          centerTitle: true,
          //build settings icon
          leading: Builder(
            builder: (BuildContext context) {
              return IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SettingsPage()),
                  );
                },
                icon: const Icon(Icons.settings),
              );
            },
          ),
        ),
        body: SafeArea(
          child: Scaffold(
            // You must wait until the controller is initialized before displaying the
            // camera preview. Use a FutureBuilder to display a loading spinner until the
            // controller has finished initializing.
            body: FutureBuilder(
              future: cameraInit,
              builder: (context, snapshot) {
                //get size of body to fit camera preview fullscreen
                final double _bodyheight = MediaQuery.of(context).size.height;
                final double _bodywidth = MediaQuery.of(context).size.width;

                if (snapshot.connectionState == ConnectionState.done) {
                  // If the Future is complete, display the preview.
                  return Stack(
                    children: [
                      SizedBox(
                        width: _bodywidth,
                        height: _bodyheight,
                        child: AspectRatio(
                          aspectRatio: _cameraController.value.aspectRatio,
                          child: CameraPreview(_cameraController),
                        ),
                      ),
                      BndBox(
                          _recognitions == null ? [] : _recognitions,
                          math.max(_imageHeight, _imageWidth),
                          math.min(_imageHeight, _imageWidth),
                          _bodyheight,
                          _bodywidth,
                          _model),
                    ],
                  );
                } else {
                  // Otherwise, display a loading indicator.
                  return const Center(child: CircularProgressIndicator());
                }
              },
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
            child: const Icon(Icons.camera_alt),
            onPressed: () async {
              int random = math.Random().nextInt(_dummyTitle.length);
              //print("Main image path is: ${_dummyImage[random]} !!!!!");
              //create temp entry and send id of inserted row to choice page
              /*ImageEntry tempImageEntry = ImageEntry();
              for (int i = 0; i < _dummyChoices[random].length; i++) {
                tempImageEntry.imageEntries![i] = _dummyChoices[random][i];
              }
              int imageID =
                  await mySqliteService.insertImageChoice(tempImageEntry);*/

              int tempID = await mySqliteService.insertEntry(Entry(
                  type: 1,
                  title: _dummyTitle[random],
                  category: _dummyCategory[random],
                  choices: _dummyChoices[random].length,
                  //_dummyChoices[random]
                  //imageID
                  //index to row of ImageChoices database table
                  imageChoices: _dummyChoices[random],
                  image: _dummyImage[random]));
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => HistoryDetailsPage(
                          title: _dummyTitle[random],
                          category: _dummyCategory[random],
                          choicesNumber: _dummyChoices[random].length,
                          imagechoices: _dummyChoices[random],
                          image: _dummyImage[random],
                        )),
              );
            }),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        bottomNavigationBar: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.camera),
              label: "Camera",
              backgroundColor: Color(0x1C1B1F),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.toll_rounded),
              label: "Configuration",
              backgroundColor: Color(0x1C1B1F),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.list),
              label: "History",
              backgroundColor: Color(0x00000000),
            ),
          ],
          currentIndex: 0,
        ),
      ),
    );
  }
}
