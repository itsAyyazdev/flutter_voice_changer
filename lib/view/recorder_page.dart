import 'dart:async';

import 'package:flutter/material.dart';
import 'package:record/record.dart';
import 'package:simple_ripple_animation/simple_ripple_animation.dart';

class AudioRecorder extends StatefulWidget {
  final void Function(String path) onStop;

  const AudioRecorder({required this.onStop});

  @override
  _AudioRecorderState createState() => _AudioRecorderState();
}

class _AudioRecorderState extends State<AudioRecorder> {
  bool _isRecording = false;
  bool _isPaused = false;
  int _recordDuration = 0;
  Timer? _timer;
  Timer? _ampTimer;
  final _audioRecorder = Record();
  Amplitude? _amplitude;

  @override
  void initState() {
    if (_isRecording) _start();
    super.initState();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _ampTimer?.cancel();
    _audioRecorder.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text("Recorder"),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(
            height: height * (_isRecording ? 0.2 : 0.05),
          ),
          _isRecording && _isPaused == false
              ? RippleAnimation(
                  repeat: true,
                  color: Colors.blue.withOpacity(0.6),
                  minRadius: 50,
                  ripplesCount: 5,
                  child: mic())
              : _isPaused
                  ? mic()
                  : SizedBox(height: height * 0.1),
          SizedBox(
            height: height * (_isRecording ? 0.06 : 0.03),
          ),
          SizedBox(
            width: width,
            child: !(_isRecording || _isPaused)
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      SizedBox(height: 64),
                      _buildRecordStopControl(),
                      const SizedBox(height: 20),
                      _buildPauseResumeControl(),
                      const SizedBox(height: 10),
                      _buildText(),
                      const SizedBox(height: 10),
                    ],
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      const SizedBox(height: 10),
                      _buildText(),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildRecordStopControl(),
                          const SizedBox(width: 20),
                          _buildPauseResumeControl(),
                        ],
                      ),
                      SizedBox(height: 20),
                    ],
                  ),
          ),
          // if (_amplitude != null) ...[
          //   const SizedBox(height: 40),
          //   Text('Current: ${_amplitude?.current ?? 0.0}'),
          //   Text('Max: ${_amplitude?.max ?? 0.0}'),
          // ],
        ],
      ),
    );
  }

  Widget _buildRecordStopControl() {
    late Widget icon;
    late Color color;

    if (_isRecording || _isPaused) {
      icon = Icon(Icons.stop, color: Colors.red, size: 34);
      color = Colors.red.withOpacity(0.1);
    } else {
      final theme = Theme.of(context);
      icon = mic();
      color = theme.primaryColor.withOpacity(0.1);
    }
    if (!(_isRecording || _isPaused)) {
      return GestureDetector(
          onTap: () {
            _start();
          },
          child: mic());
    } else {
      return ClipOval(
        child: Material(
          color: color,
          child: InkWell(
            child: SizedBox(width: 64, height: 64, child: icon),
            onTap: () {
              _isRecording ? _stop() : _start();
            },
          ),
        ),
      );
    }
  }

  Widget _buildPauseResumeControl() {
    if (!_isRecording && !_isPaused) {
      return const SizedBox.shrink();
    }

    late Icon icon;
    late Color color;

    if (!_isPaused) {
      icon = Icon(Icons.pause, color: Colors.red, size: 34);
      color = Colors.red.withOpacity(0.1);
    } else {
      final theme = Theme.of(context);
      icon = Icon(Icons.mic, color: Colors.red, size: 34);
      color = theme.primaryColor.withOpacity(0.1);
    }

    return ClipOval(
      child: Material(
        color: color,
        child: InkWell(
          child: SizedBox(width: 64, height: 64, child: icon),
          onTap: () {
            _isPaused ? _resume() : _pause();
          },
        ),
      ),
    );
  }

  Widget _buildText() {
    if (_isRecording || _isPaused) {
      return _buildTimer();
    }

    return Text(
      "Tap to start recording",
      textAlign: TextAlign.center,
      style: TextStyle(color: Colors.black, fontSize: 18),
    );
  }

  Widget _buildTimer() {
    final String minutes = _formatNumber(_recordDuration ~/ 60);
    final String seconds = _formatNumber(_recordDuration % 60);

    return Text(
      '$minutes : $seconds',
      style: TextStyle(color: Colors.black, fontSize: 24),
    );
  }

  String _formatNumber(int number) {
    String numberStr = number.toString();
    if (number < 10) {
      numberStr = '0' + numberStr;
    }

    return numberStr;
  }

  Future<void> _start() async {
    try {
      if (await _audioRecorder.hasPermission()) {
        await _audioRecorder.start();

        bool isRecording = await _audioRecorder.isRecording();
        setState(() {
          _isRecording = isRecording;
          _recordDuration = 0;
        });

        _startTimer();
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> _stop() async {
    _timer?.cancel();
    _ampTimer?.cancel();
    final path = await _audioRecorder.stop();

    widget.onStop(path!);

    setState(() => _isRecording = false);
  }

  Future<void> _pause() async {
    _timer?.cancel();
    _ampTimer?.cancel();
    await _audioRecorder.pause();

    setState(() => _isPaused = true);
  }

  Future<void> _resume() async {
    _startTimer();
    await _audioRecorder.resume();

    setState(() => _isPaused = false);
  }

  void _startTimer() {
    _timer?.cancel();
    _ampTimer?.cancel();

    _timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      setState(() => _recordDuration++);
    });

    _ampTimer =
        Timer.periodic(const Duration(milliseconds: 200), (Timer t) async {
      _amplitude = await _audioRecorder.getAmplitude();
      setState(() {});
    });
  }

  Widget mic() {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.black,
          width: 2,
        ),
        color: Colors.transparent,
      ),
      child: Padding(
        padding: EdgeInsets.all(28),
        child: SizedBox(height: 50, child: Icon(Icons.mic)),
      ),
    );
  }
}
