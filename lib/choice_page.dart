import "package:flutter/material.dart";
import "./sqlite_service.dart";

class ChoicePage extends StatefulWidget {
  late int id;
  late Entry choice;

  ChoicePage({required this.id});

  @override
  _ChoicePageState createState() => _ChoicePageState();
}

class _ChoicePageState extends State<ChoicePage> {
  void getFinal() async {
    widget.choice = await mySqliteService.getOneEntry(widget.id);
    return;
  }

  @override
  void initState() {
    super.initState();
    getFinal();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            "You finally picked!",
            style: TextStyle(
                fontFamily: 'Arial',
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
                color: Colors.black),
          ),
          centerTitle: true,
        ),
        body: Column(
          children: [
            Expanded(
              flex: 1,
              child: Container(
                  alignment: Alignment.bottomCenter,
                  child: FutureBuilder(
                    future: mySqliteService.getOneEntry(widget.id),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return Text(
                          "Your choice is:\n${widget.choice.title}",
                          maxLines: 3,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontFamily: 'Arial',
                              fontSize: 40.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.black),
                        );
                      } else
                        return const Center(child: CircularProgressIndicator());
                    },
                  )),
            ),
            Expanded(
              flex: 1,
              child: Center(
                  child: Image.network(
                      'https://cdn.pixabay.com/animation/2022/12/05/15/23/15-23-06-837_512.gif',
                      width: 300,
                      height: 500)),
            ),
          ],
        ),
      ),
    );
  }
}
