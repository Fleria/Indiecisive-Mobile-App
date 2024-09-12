import "package:flutter/material.dart";
import "package:indiecisive/settings_page.dart";

class HistoryDetailsPage extends StatelessWidget {
  final String title;
  final String category;
  final int choicesNumber;
  final List<String>? imagechoices;
  String? image;

  HistoryDetailsPage({
    required this.title,
    required this.category,
    required this.choicesNumber,
    required this.imagechoices,
    required this.image,
  });

  @override
  Widget build(BuildContext context) {
    final double width =
        MediaQuery.of(context).size.width; //available max width
    final double height =
        MediaQuery.of(context).size.height; //available max height

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text("History"),
          centerTitle: true,
          actions: [
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SettingsPage()),
                );
              },
              icon: const Icon(Icons.share),
            ),
          ],
        ),
        body: Container(
          padding: const EdgeInsets.all(5),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(top: 5, bottom: 2, left: 2, right: 2),
                child: Center(
                  child: Text(
                      maxLines: 1,
                      style: TextStyle(fontSize: 32, fontFamily: "Patua One"),
                      category),
                ),
              ),
              Expanded(
                flex: 3,
                child: Center(
                  child: Image.asset(image!),
                ),
              ),
              Expanded(
                flex: 1,
                child: Center(
                  child: const Text(
                      maxLines: 1,
                      style: const TextStyle(
                          fontSize: 32, fontFamily: "Patua One"),
                      "You Finally Picked!"),
                ),
              ),
              Expanded(
                flex: 2,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Expanded(
                      flex: 3,
                      child: Container(
                        alignment: const Alignment(0.0, 0.0),
                        padding: const EdgeInsets.only(right: 5.0),
                        child: Image.asset(imagechoices![0]),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Container(
                        alignment: const Alignment(0.0, 0.0),
                        padding: const EdgeInsets.symmetric(horizontal: 5.0),
                        child: Image.asset(imagechoices![1]),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Container(
                        alignment: const Alignment(0.0, 0.0),
                        padding: const EdgeInsets.only(left: 5.0),
                        child: Image.asset(imagechoices![2]),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                alignment: const Alignment(0.0, 0.0),
                padding: const EdgeInsets.only(bottom: 15),
                child: const Text(
                    maxLines: 1,
                    style:
                        const TextStyle(fontSize: 32, fontFamily: "Patua One"),
                    "Other Choices"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
