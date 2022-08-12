import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_voice_changer/model/voice_morph.dart';
import 'package:flutter_voice_changer/view_model/utils.dart';
import 'package:intl/intl.dart';
import 'package:just_audio/just_audio.dart' as ap;

class InstantAudioPlayer extends StatefulWidget {
  final ap.AudioSource source;
  final VoiceType voiceType;
  const InstantAudioPlayer(
      {Key? key, required this.source, required this.voiceType})
      : super(key: key);

  @override
  InstantAudioPlayerState createState() => InstantAudioPlayerState();
}

class InstantAudioPlayerState extends State<InstantAudioPlayer> {
  static const double _controlSize = 56;

  final _audioPlayer = ap.AudioPlayer();
  late StreamSubscription<ap.PlayerState> _playerStateChangedSubscription;
  late StreamSubscription<Duration?> _durationChangedSubscription;
  late StreamSubscription<Duration> _positionChangedSubscription;
  Duration _pos = const Duration(seconds: 0);
  Duration _dur = const Duration(seconds: 0);
  VoiceMorph selectedMorph = AppUtils.effects.first;
  @override
  void initState() {
    _playerStateChangedSubscription =
        _audioPlayer.playerStateStream.listen((state) async {
      if (state.processingState == ap.ProcessingState.completed) {
        await stop();
      }
      setState(() {});
    });
    _positionChangedSubscription =
        _audioPlayer.positionStream.listen((position) => setState(() {
              _pos = position;
            }));
    _durationChangedSubscription =
        _audioPlayer.durationStream.listen((duration) => setState(() {
              _dur = duration!;
            }));
    _init();

    super.initState();
  }

  Future<void> _init() async {
    await _audioPlayer.setAudioSource(widget.source);
    selectedMorph = AppUtils.effects
        .firstWhere((element) => element.type == widget.voiceType);
    applyMorph();
  }

  void applyMorph() {
    // if (selectedMorph == null) {
    //   return;
    // }
    if (Platform.isAndroid) {
      _audioPlayer.setPitch(selectedMorph.pitch);
      _audioPlayer.setSpeed(selectedMorph.speed ?? 1.0);
    }
  }

  @override
  void dispose() {
    _playerStateChangedSubscription.cancel();
    _positionChangedSubscription.cancel();
    _durationChangedSubscription.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    return LayoutBuilder(
      builder: (context, constraints) {
        return Padding(
          padding: const EdgeInsets.all(4.0),
          child: Column(
            children: [
              Container(
                height: height * 0.12,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: const Color(0xffec1d3d),
                    width: 1,
                  ),
                  color: Colors.white,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    _buildControl(),
                    _buildSlider(constraints.maxWidth),
                    Text(
                        DateFormat("mm:ss").format(DateTime(
                            2020,
                            1,
                            1,
                            1,
                            0,
                            _audioPlayer.playing
                                ? _pos.inSeconds
                                : _dur.inSeconds)),
                        style: const TextStyle(
                          color: Color(0xff707070),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        )),
                    // IconButton(
                    //   icon: Icon(Icons.delete,
                    //       color: const Color(0xFF73748D), size: _deleteBtnSize),
                    //   onPressed: () {
                    //     _audioPlayer.stop().then((value) => widget.onDelete());
                    //   },
                    // ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(
                    height: 10,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Text(
                      "Apply Voice Morph",
                      style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.black.withOpacity(0.9)),
                    ),
                  ),
                  SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: Wrap(
                      children: List.generate(AppUtils.effects.length, (index) {
                        return GestureDetector(
                          onTap: () async {
                            selectedMorph = AppUtils.effects[index];
                            applyMorph();
                            delay() => Future.delayed(
                                const Duration(milliseconds: 100));
                            // _audioPlayer.play();
                            // await delay();
                            // _audioPlayer.play();
                            // await delay();
                            // _audioPlayer.play();
                          },
                          child: Container(
                            height: 80,
                            width: 152,
                            padding: const EdgeInsets.symmetric(
                                vertical: 8.0, horizontal: 2),
                            child: Card(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              elevation:
                                  selectedMorph.id == AppUtils.effects[index].id
                                      ? 10
                                      : 2,
                              color:
                                  selectedMorph.id == AppUtils.effects[index].id
                                      ? Colors.blue
                                      : Colors.blue.withOpacity(0.4),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 2),
                                child: Center(
                                  child: Text(
                                    AppUtils().getNameByType(
                                        AppUtils.effects[index].type),
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ],
              )
            ],
          ),
        );
      },
    );
  }

  Widget _buildControl() {
    Icon icon;

    if (_audioPlayer.playerState.playing) {
      icon = const Icon(Icons.pause, color: Colors.red, size: 30);
    } else {
      icon =
          const Icon(Icons.play_arrow_rounded, color: Colors.yellow, size: 42);
    }

    return ClipOval(
      child: InkWell(
        child: SizedBox(width: _controlSize, height: _controlSize, child: icon),
        onTap: () {
          if (_audioPlayer.playerState.playing) {
            pause();
          } else {
            play();
          }
        },
      ),
    );
  }

  Widget _buildSlider(double widgetWidth) {
    final position = _audioPlayer.position;
    final duration = _audioPlayer.duration;
    bool canSetValue = false;
    if (duration != null) {
      canSetValue = position.inMilliseconds > 0;
      canSetValue &= position.inMilliseconds < duration.inMilliseconds;
    }

    var width = MediaQuery.of(context).size.width;
    return SizedBox(
      width: width * 0.7,
      child: Slider(
        activeColor: Colors.yellow,
        inactiveColor: Colors.grey.shade300,
        onChanged: (v) {
          if (duration != null) {
            final position = v * duration.inMilliseconds;
            _audioPlayer.seek(Duration(milliseconds: position.round()));
          }
        },
        value: canSetValue && duration != null
            ? position.inMilliseconds / duration.inMilliseconds
            : 0.0,
      ),
    );
  }

  Future<void> play() {
    return _audioPlayer.play();
  }

  Future<void> pause() {
    return _audioPlayer.pause();
  }

  Future<void> stop() async {
    await _audioPlayer.stop();
    return _audioPlayer.seek(const Duration(milliseconds: 0));
  }
}
