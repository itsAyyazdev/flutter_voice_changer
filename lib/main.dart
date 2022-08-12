import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_voice_changer/view/online_player.dart';
import 'package:flutter_voice_changer/view/recorder_page.dart';
import 'package:just_audio/just_audio.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter voice changer'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  go(route) =>
      Navigator.push(context, MaterialPageRoute(builder: (context) => route));
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(
          // Center is a layout widget. It takes a single child and positions it
          // in the middle of the parent.
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              ListTile(
                tileColor: Colors.blue.withOpacity(0.6),
                title: const Text("Online link"),
                onTap: () {
                  go(OnlinePlayer(
                    audioSource: AudioSource.uri(Uri.parse(
                        "https://s3.amazonaws.com/scifri-episodes/scifri20181123-episode.mp3")),
                  ));
                },
              ),
              const SizedBox(
                height: 10,
              ),
              ListTile(
                tileColor: Colors.blue.withOpacity(0.6),
                title: const Text("With Recorder"),
                onTap: () {
                  go(AudioRecorder(onStop: (path) {
                    Navigator.pop(context);
                    var recordedFile = File.fromUri(Uri.parse(path));
                    log("recorded file===>>>> ${recordedFile.path}");
                    var audioSource = AudioSource.uri(Uri.parse(path));
                    go(
                      OnlinePlayer(audioSource: audioSource),
                    );
                  }));
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
