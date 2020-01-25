import 'package:flutter/material.dart';
import 'package:speech_recognition/speech_recognition.dart';
import 'dart:async';
import 'package:http/http.dart' as http;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aut Rec Voice',
      theme: ThemeData(
        primarySwatch: Colors.grey,
      ),
      home: MyHomePage(title: 'Aut Rec Voice'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  SpeechRecognition _speechRecognition;
  bool _isAvailable = false;
  bool _isListening = false;

  String resultText = "";

  @override
  void initState(){
    super.initState();
    initSpeechRecognizer();
  }

  void initSpeechRecognizer(){
    _speechRecognition = SpeechRecognition();

    _speechRecognition.setAvailabilityHandler(
            (bool result) => setState(() => _isAvailable = result )
    );

    _speechRecognition.setRecognitionStartedHandler(
            () => setState(() => _isListening = true)
    );

    _speechRecognition.setRecognitionResultHandler(
            (String speech) => setState(() => resultText = speech)
    );

    Future<void> changeLed() async {
      final url = "http://192.168.0.99/?" + resultText;
      await http.get(
          Uri.encodeFull(url),
          headers: {"Accept": "application/json"}
      );
      _isListening = false;
    }

    _speechRecognition.setRecognitionCompleteHandler(() => setState(() => changeLed() ));

    _speechRecognition.activate().then(
            (result) => setState(() => _isAvailable = result)
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(

        title: Text(widget.title),
      ),
      body: Center(

        child: Column(

          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[

                  FloatingActionButton(
                    child: Icon(Icons.mic),
                    backgroundColor: Colors.grey,
                    onPressed: (){
                      if(_isAvailable && !_isListening){
                        _speechRecognition.listen(locale: "pt_BR").then((result) => print('$result'));
                      }
                    },
                  ),

              ]
            ),

            Container(
              padding: EdgeInsets.symmetric(
                vertical: 10.0,
              )
            ),

            Container(
              width: MediaQuery.of(context).size.width * 0.9,
              decoration: BoxDecoration(
                color: Colors.grey,
                borderRadius: BorderRadius.circular(6.0),
              ),
              padding: EdgeInsets.symmetric(
                vertical: 120.0,
                horizontal: 70.0
              ),
              child: Text(
                  resultText,
                  style: TextStyle(fontSize: 24.0),
              ),
            )

          ],

        ),
      ),
    );
  }
}
