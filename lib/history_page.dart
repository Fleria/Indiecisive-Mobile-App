import "package:flutter/material.dart";
//import "package:provider/provider.dart";
import "./sqlite_service.dart";

import "./history_details_page.dart";

class HistoryLog extends StatelessWidget {
  //represent the actual card that holds data
  final String title;
  final String category;
  final int choicesNumber;
  final List<String>? imagechoices;
  String? image;

  HistoryLog(
      {required this.title,
      required this.category,
      required this.choicesNumber,
      this.imagechoices,
      this.image});

  @override
  Widget build(BuildContext context) {
    final double width =
        MediaQuery.of(context).size.width; //available max width
    final double height =
        MediaQuery.of(context).size.height; //available max height

    //replace image with default if null was given to constructor
    image ??= "assets/images/roll-the-dice.gif";

    return Container(
      alignment: const Alignment(0.0, -1.0),
      margin: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 6.0),
      child: SizedBox(
        //defines max size of whole card
        width: width,
        height: 100,
        child: Card(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Expanded(
                child: ListTile(
                  leading: Image.asset(image!),
                  title: Text(title),
                  subtitle: Text(
                    "Category: $category\nNumber of choices: $choicesNumber",
                    maxLines: 2,
                  ),
                  isThreeLine: true,
                ),
              ), /*
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Expanded(
                    child: IconButton(
                      icon: const Icon(Icons.arrow_right),
                      onPressed: () {
                        if (imagechoices != null) {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => HistoryDetailsPage(
                                    title: title,
                                    category: category,
                                    choicesNumber: choicesNumber,
                                    imagechoices: imagechoices,
                                    image: image,
                                  )));
                        } else {
                          ;
                        }
                      },
                    ),
                  ),
                  Expanded(
                    child: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {},
                    ),
                  ),
                ],
              ),*/
            ],
          ),
        ),
      ),
    );
  }
}

class HistoryPage extends StatefulWidget {
  late List<Entry> data;
  late int _dataLength;

  @override
  HistoryPageState createState() => HistoryPageState();
}

class HistoryPageState extends State<HistoryPage> {
  Future<void> initializeHistory() async {
    widget.data = await mySqliteService.getAllEntries();
    setState(() {}); //may not be needed
  }

  @override
  void initState() {
    super.initState;
    initializeHistory();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text("History"),
          centerTitle: true,
        ),
        body: FutureBuilder(
          future: mySqliteService.getAllEntries(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              widget._dataLength = widget.data.length;
              return ListView.separated(
                itemCount: widget._dataLength,
                itemBuilder: (BuildContext context, int index) {
                  //print("History image path is ${widget.data.last.image} !!!!");
                  //print("History type is ${widget.data.last.type} !!!!");
                  Entry temp = widget.data[index];
                  //if chosen through camera
                  if (temp.type == 1) {
                    return HistoryLog(
                      title: temp.title,
                      category: temp.category,
                      choicesNumber: temp.choices,
                      //
                      imagechoices: temp.imageChoices,
                      image: temp.image,
                    );
                    //return HistoryLog(
                    //"Appetite for Destruction", "Music Albums", 4);
                  }
                  //if chosen through configuration
                  else {
                    return HistoryLog(
                      title: temp.title,
                      category: temp.category,
                      choicesNumber: temp.choices,
                    );
                  }
                },
                separatorBuilder: (BuildContext context, int index) {
                  return const Divider(
                    height: 2,
                    thickness: 1,
                    indent: 4,
                    endIndent: 4,
                    color: Colors.black,
                  );
                },
              );
            } else {
              return const Center(child: CircularProgressIndicator());
            }
          },
        ),
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
          currentIndex: 2,
        ),
      ),
    );
  }
}
