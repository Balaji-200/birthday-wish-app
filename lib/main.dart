import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_share/flutter_share.dart';
import 'package:path_provider/path_provider.dart';
import 'apiKey.dart' as key;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  static const MaterialColor mcgpalette0 =
      MaterialColor(_mcgpalette0PrimaryValue, <int, Color>{
    50: Color(0xFFEDE3E4),
    100: Color(0xFFD2B9BC),
    200: Color(0xFFB48B8F),
    300: Color(0xFF965C62),
    400: Color(0xFF803940),
    500: Color(_mcgpalette0PrimaryValue),
    600: Color(0xFF61131A),
    700: Color(0xFF561016),
    800: Color(0xFF4C0C12),
    900: Color(0xFF3B060A),
  });
  static const int _mcgpalette0PrimaryValue = 0xFF69161E;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Birthday Wish App',
        theme: ThemeData(
          primarySwatch: mcgpalette0,
        ),
        home: MyAppBody());
  }
}

class MyAppBody extends StatefulWidget {
  @override
  _MyAppBodyState createState() => _MyAppBodyState();
}

class _MyAppBodyState extends State<MyAppBody> {
  final TextEditingController _controller = TextEditingController();
  Uint8List? bytes;
  bool isProcessing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text('BirthDay Wish'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      backgroundColor: Color(0xfffcebf1),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _controller,
              cursorColor: Theme.of(context).primaryColor,
              decoration:
                  InputDecoration(labelText: 'Name', hintText: 'Enter a name'),
            ),
          ),
          Center(
            child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    primary: Theme.of(context).primaryColor),
                onPressed: () {
                  setState(() => isProcessing = true);
                  FocusScope.of(context).requestFocus(new FocusNode());
                  getImage(_controller.text.toString())
                      .then((value) => setState(() {
                            bytes = value;
                            isProcessing = false;
                          }));
                },
                child: Text('Submit')),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                child: !isProcessing
                    ? bytes != null
                        ? Image.memory(bytes!)
                        : Container()
                    : CircularProgressIndicator(
                        color: Theme.of(context).primaryColor,
                      ),
              ),
            ),
          )
        ],
      ),
      floatingActionButton: bytes != null
          ? FloatingActionButton(
              backgroundColor: Theme.of(context).primaryColor,
              child: Icon(
                Icons.share_rounded,
                color: Colors.white,
              ),
              onPressed: shareImage)
          : Container(),
    );
  }

  void shareImage() async {
    final directory = (await getExternalStorageDirectory())!.path;
    final File img = new File(directory + '/birthday-wish.jpg');
    img.writeAsBytes(bytes!);
    await FlutterShare.shareFile(title: 'BirthDay Wish', filePath: img.path);
  }

  Future<Uint8List> getImage(String name) async {
    var response = await http.get(Uri.http(
        key.apiDomain, key.apiRoute, {'name': name, 'code': key.apiKey}));
    if (response.statusCode == 200) {
      Uint8List bytes = base64.decode(response.body.toString());
      return bytes;
    } else
      throw 'Something went Wrong';
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
