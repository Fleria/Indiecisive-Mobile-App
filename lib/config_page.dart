import "package:flutter/material.dart";
//import "package:provider/provider.dart";
import "./history_page.dart";
import "./choice_page.dart";
import "./sqlite_service.dart";
import 'dart:math';

class _PopUp extends StatelessWidget {
  String string;
  _PopUp({required this.string});
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(string),
      content: SizedBox(
        height: 20,
        width: 70,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
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

class ConfigurationPage extends StatefulWidget {
  final double _minChoices = 0.0;
  final double _maxChoices = 10.0;
  final int? _divisions = 10;
  double _sliderValue = 0;
  //equal places as _divisions+1
  //they are only disposed once app is closed
  final List<TextEditingController> _controllersList =
      List.generate(11, (index) => TextEditingController());
  late List<String> categoriesList;
  List<String> optionsList = [];
  late String dropdownValue = categoriesList.first;

  @override
  _ConfigurationPageState createState() => _ConfigurationPageState();
}

class _ConfigurationPageState extends State<ConfigurationPage> {
  @override
  void initState() {
    super.initState();
    initializeConfig();
  }

  Future<void> initializeConfig() async {
    //mySqliteService.insertCategory("Books");
    //mySqliteService.insertCategory("Food");
    mySqliteService.insertCategory("Music");
    widget.categoriesList = await mySqliteService.getAllCategories();
    //print(widget.categoriesList);
  }

  //returns the chosen option
  String getresult() {
    final int random = Random().nextInt(widget.optionsList.length);
    return widget.optionsList[random];
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      //used to hide keyboard when touching outside anywhere
      child: GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: Scaffold(
          appBar: AppBar(
            title: const Text(
              "Configuration",
            ),
            centerTitle: true,
          ),
          //makes keyboard not resize screen
          resizeToAvoidBottomInset: false,
          body: Column(
            children: <Widget>[
              //treat category text+dropdown+text field as unit
              Expanded(
                flex: 3,
                child: Column(
                  children: <Widget>[
                    Expanded(
                      child: Container(
                        alignment: Alignment.center,
                        margin: const EdgeInsets.symmetric(vertical: 5.0),
                        child: const Text(
                          "Category",
                          style: TextStyle(
                            fontFamily: 'Arial',
                            fontSize: 22.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      //wait until categoriesList is initialized
                      child: FutureBuilder(
                          future: mySqliteService.getAllCategories(),
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              return Container(
                                //alignment: Alignment.center,
                                margin:
                                    const EdgeInsets.symmetric(vertical: 10.0),
                                child: DropdownButton(
                                  underline: null,
                                  value: widget.dropdownValue,
                                  items: widget.categoriesList
                                      .map<DropdownMenuItem<String>>(
                                          (String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Row(
                                        children: <Widget>[
                                          Expanded(
                                            child: Text(value),
                                          ),
                                          //print delete icon only for non-chosen options
                                          if (value != widget.dropdownValue)
                                            IconButton(
                                              onPressed: () {
                                                mySqliteService
                                                    .deleteCategory(value);
                                                initializeConfig();
                                                //need to make it so it collapses when pressing button
                                                setState(() {});
                                              },
                                              icon: const Icon(Icons.delete),
                                            )
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                  // This is called when the user selects an item.
                                  onChanged: (String? value) {
                                    //dropdownValue is non-nullable, throws error otherwise
                                    widget.dropdownValue = value!;

                                    //once another category is chosen clear all text fields
                                    widget._controllersList.forEach((element) {
                                      element.clear();
                                    });

                                    //remove all entries from options (in case user had pressed submitted)
                                    //and reset slider
                                    widget.optionsList.clear();
                                    widget._sliderValue = 0;

                                    setState(() {});
                                  },
                                  //must be kept true or throws error
                                  isExpanded: true,
                                ),
                              );
                            } else {
                              return Container();
                            }
                          }),
                    ),
                    Expanded(
                      child: Container(
                        alignment: Alignment.center,
                        margin: const EdgeInsets.symmetric(vertical: 5.0),
                        child: TextField(
                          decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              icon: Icon(Icons.add),
                              labelText: "Add another category"),
                          controller: TextEditingController(),
                          onSubmitted: (String value) {
                            mySqliteService.insertCategory(value);
                            initializeConfig();
                            setState(() {});
                          },
                        ),
                      ),
                    )
                  ],
                ),
              ),

              //treat slider+dividers+text as a unit
              Expanded(
                flex: 3,
                child: Column(
                  children: <Widget>[
                    Expanded(
                      child: Container(
                        alignment: Alignment.center,
                        margin: const EdgeInsets.symmetric(vertical: 5),
                        child: const Text(
                          "Choices",
                          style: TextStyle(
                            fontFamily: 'Arial',
                            fontSize: 22.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                    const Divider(
                      height: 25,
                      thickness: 3,
                      indent: 15,
                      endIndent: 15,
                      color: Colors.black,
                    ),
                    Expanded(
                      child: Slider(
                        //_sliderValue is the number of options the user inputs
                        value: widget._sliderValue,
                        onChanged: (newValue) {
                          //remove/keep option text when changing number of options
                          if (newValue > widget._sliderValue) {
                            for (int counter = 0;
                                counter < (newValue - widget._sliderValue);
                                counter++) {
                              widget.optionsList.add("");
                            }
                          } else if (newValue < widget._sliderValue) {
                            for (int counter = 0;
                                counter < (widget._sliderValue - newValue);
                                counter++) {
                              widget.optionsList.removeLast();
                            }
                          }
                          widget._sliderValue = newValue;
                          setState(() {});
                        },
                        min: widget._minChoices,
                        max: widget._maxChoices,
                        divisions: widget._divisions,
                        label: widget._sliderValue.toInt().toString(),
                      ),
                    ),
                    const Divider(
                      height: 25,
                      thickness: 3,
                      indent: 15,
                      endIndent: 15,
                      color: Colors.black,
                    ),
                  ],
                ),
              ),

              Expanded(
                flex: 1,
                child: Container(
                  alignment: Alignment.center,
                  child: const Text(
                    "Enter your options:",
                    style: TextStyle(
                        fontFamily: 'Arial',
                        fontSize: 22.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                  ),
                ),
              ),

              Expanded(
                flex: 5,
                child: ListView.builder(
                    itemCount: widget._sliderValue.toInt(),
                    itemBuilder: (BuildContext context, int index) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SizedBox(
                          height: 50,
                          child: TextField(
                            decoration: InputDecoration(
                              border: const OutlineInputBorder(),
                              labelText: 'Option $index',
                              suffixIcon: IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  widget._controllersList[index].clear();
                                  setState(() {});
                                },
                              ),
                            ),
                            controller: widget._controllersList[index],
                            onSubmitted: (String value) {
                              //print("Index value is: $index");
                              //print("Length is: ${widget.optionsList.length}");
                              //print("optionsList is: ${widget.optionsList}");
                              widget.optionsList[index] = value;
                              setState(() {});
                            },
                          ),
                        ),
                      );
                    }),
              ),

              //check if optionsList.length == widget._sliderValue before allowing to press button
              Container(
                alignment: Alignment.bottomCenter,
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: FloatingActionButton(
                  backgroundColor: const Color.fromARGB(255, 151, 24, 15),
                  shape: const CircleBorder(),
                  onPressed: () async {
                    //if there are no options/text fields return appropriate popup
                    if (widget.optionsList.isEmpty) {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) => _PopUp(
                          string: "Set a number of options first",
                        ),
                      );
                      return;
                    }
                    //if all created text fields aren't filled return popup that informs user
                    //instead of going to choice page
                    for (String string in widget.optionsList) {
                      if (string == "") {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) => _PopUp(
                            string: "Fill in all text fields first",
                          ),
                        );
                        return; //put popup here
                      } else {
                        continue;
                      }
                    }

                    //create temp entry and send id of inserted row to choice page
                    int tempID = await mySqliteService.insertEntry(Entry(
                        type: 0,
                        title: getresult(),
                        category: widget.dropdownValue,
                        choices: widget._sliderValue.toInt(),
                        imageChoices: null,
                        image: null));

                    //after you have passed all checks and sent data clear everything
                    //and rebuild widget
                    widget.optionsList.clear();
                    widget._controllersList.forEach((element) {
                      element.clear();
                    });
                    widget._sliderValue = 0;
                    setState(() {});
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ChoicePage(id: tempID)),
                    );
                  },
                ),
              ),
            ],
          ),
          bottomNavigationBar: BottomNavigationBar(
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(Icons.camera),
                label: "Camera",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.toll_rounded),
                label: "Configuration",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.list),
                label: "History",
              ),
            ],
            currentIndex: 1,
          ),
        ),
      ),
    );
  }
}
