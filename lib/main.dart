import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:esys_flutter_share/esys_flutter_share.dart';
import 'apiKey.dart' as key;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Birthday Wish App',
        theme: ThemeData(
          primaryColor: Color(0xFF69161E),
          accentColor: Color(0xFFF7B1C9),
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
  Uint8List bytes;
  bool isProcessing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text('BirthDay Wish'),
      ),
      backgroundColor: Color(0xfffcebf1),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _controller,
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
                        ? Image.memory(bytes)
                        : Container()
                    : CircularProgressIndicator(),
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
    await Share.file('BirthDay Wish', 'birthday_wish.jpg', bytes, 'image/jpeg');
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
