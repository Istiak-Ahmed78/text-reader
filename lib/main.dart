import 'dart:io';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  File _file;
  bool _isSelected = false;
  void selectPhotoFromGallery() async {
    var file;
    try {
      file = await ImagePicker.pickImage(source: ImageSource.gallery);
    } catch (e) {
      print('Failed to bring photo');
    }
    if (file != null) {
      setState(() {
        _file = file;
        _isSelected = true;
      });
    } else {
      setState(() {
        _isSelected = false;
      });
    }
  }

  void selectPhotoFromCamera() async {
    var fileFromCamera =
        await ImagePicker.pickImage(source: ImageSource.camera);
    setState(() {
      _file = fileFromCamera;
      _isSelected = true;
    });
  }

  void bottomShit(String te) {
    showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(bottom: 40, left: 8.0, top: 10),
          child: SelectableText(te),
        );
      },
    );
  }

  void scanText() async {
    var proccesedImage = FirebaseVisionImage.fromFile(_file);
    final TextRecognizer textRecognizer =
        FirebaseVision.instance.textRecognizer();
    final VisionText visionText =
        await textRecognizer.processImage(proccesedImage);
    String scannedText = visionText.text;
    bottomShit(scannedText);
    for (TextBlock block in visionText.blocks) {
      final Rect boundingBox = block.boundingBox;
      final List<Offset> cornerPoints = block.cornerPoints;
      final String text = block.text;
      final List<RecognizedLanguage> languages = block.recognizedLanguages;
      print('block text: $text');
      for (TextLine line in block.lines) {
        // Same getters as TextBlock

        for (TextElement element in line.elements) {
          // Same getters as TextBlock
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
//      drawer: Drawer(
//        child: ListView(
//          children: <Widget>[
//            DrawerHeader(
//              decoration:
//                  BoxDecoration(color: Colors.indigoAccent.withOpacity(0.4)),
//              child: Column(
//                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                children: <Widget>[
//                  CircleAvatar(
//                    backgroundImage: AssetImage('images/istiakAhmed.jpg'),
//                    radius: 33,
//                  ),
//                  Text('Developed by Istiak Ahmed')
//                ],
//              ),
//            )
//          ],
//        ),
//      ),
      appBar: AppBar(
        centerTitle: true,
        title: Text('Text Recognizer'),
      ),
      body: Stack(
        children: <Widget>[
          Center(
            child: (!_isSelected)
                ? Text('No Photo Chosen')
                : Container(
                    child: Image.file(
                      _file,
                    ),
                    height: MediaQuery.of(context).size.height * 0.7,
                  ),
          ),
          (_isSelected)
              ? Positioned(
                  bottom: 32,
                  left: 12,
                  child: FloatingActionButton(
                    child: Icon(Icons.assignment),
                    onPressed: scanText,
                  ),
                )
              : Container()
        ],
      ),
      floatingActionButton: SpeedDial(
        animatedIcon: AnimatedIcons.menu_close,
        backgroundColor: Colors.red,
        children: [
          SpeedDialChild(
              child: Icon(Icons.photo), onTap: selectPhotoFromGallery),
          SpeedDialChild(
              child: Icon(Icons.camera), onTap: selectPhotoFromCamera)
        ],
      ),
    );
  }
}
