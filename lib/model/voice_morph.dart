import 'package:flutter_voice_changer/view_model/utils.dart';

class VoiceMorph {
  late int id;
  late VoiceType type;
  late double pitch;
  double? speed;
  VoiceMorph(
      {required this.id,
      required this.type,
      required this.pitch,
      this.speed = 1.0});
}
