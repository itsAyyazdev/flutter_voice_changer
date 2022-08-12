import 'package:flutter/material.dart';
import 'package:flutter_voice_changer/model/voice_morph.dart';

class AppUtils {
  static var textFieldBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(width: 1, color: Colors.grey));

  static List<VoiceMorph> effects = [
    VoiceMorph(
      id: 0,
      type: VoiceType.original,
      pitch: 1.0,
    ),
    VoiceMorph(
      id: 1,
      type: VoiceType.cartoon,
      pitch: 2.5,
      speed: 1.0,
    ),
    VoiceMorph(
      id: 2,
      type: VoiceType.devil,
      pitch: 0.6,
    ),
    VoiceMorph(
      id: 3,
      type: VoiceType.dizzy,
      pitch: 1.1,
      speed: 0.7,
    ),
    VoiceMorph(
      id: 4,
      type: VoiceType.bee,
      pitch: 2.8,
      speed: 1.25,
    ),
  ];

  String getNameByType(VoiceType type) {
    late String morph;
    switch (type) {
      case VoiceType.original:
        morph = "Original";
        break;
      case VoiceType.cartoon:
        morph = "Cartoon";
        break;
      case VoiceType.devil:
        morph = "Devil";
        break;
      case VoiceType.dizzy:
        morph = "Dizzy";
        break;
      case VoiceType.bee:
        morph = "Bee";
        break;
    }
    return morph;
  }
}

enum VoiceType { original, cartoon, devil, dizzy, bee }
