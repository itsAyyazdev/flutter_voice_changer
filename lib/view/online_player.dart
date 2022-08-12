import 'package:flutter/material.dart';
import 'package:flutter_voice_changer/view/instant_player.dart';
import 'package:flutter_voice_changer/view_model/utils.dart';
import 'package:just_audio/just_audio.dart';

class OnlinePlayer extends StatefulWidget {
  AudioSource audioSource;
  OnlinePlayer({Key? key, required this.audioSource}) : super(key: key);

  @override
  OnlinePlayerState createState() => OnlinePlayerState();
}

class OnlinePlayerState extends State<OnlinePlayer> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Player & voice changer"),
      ),
      body: Column(
        children: [
          InstantAudioPlayer(
            source: widget.audioSource,
            voiceType: VoiceType.devil,
          ),
        ],
      ),
    );
  }
}
