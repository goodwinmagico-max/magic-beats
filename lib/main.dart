import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:record/record.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

void main() {
  runApp(const MagicBeatsApp());
}

class MagicBeatsApp extends StatelessWidget {
  const MagicBeatsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Magic Beats',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF1A1612),
        primaryColor: Colors.amber,
      ),
      home: const StudioScreen(),
    );
  }
}

class StudioScreen extends StatefulWidget {
  const StudioScreen({super.key});

  @override
  State<StudioScreen> createState() => _StudioScreenState();
}

class _StudioScreenState extends State<StudioScreen> {
  double currentBpm = 130.0;
  bool isCountingDown = false;
  bool isRecording = false;
  int countdownTimer = 3;
  String statusText = 'Ready to Record...';
  String? recordedFilePath;
  String currentTrack = 'Magic_Beat_001.m4a';

  Timer? _timer;
  final AudioRecorder _audioRecorder = AudioRecorder();

  @override
  void dispose() {
    _timer?.cancel();
    _audioRecorder.dispose();
    super.dispose();
  }

  Future<void> startRecProcess() async {
    if (isRecording || isCountingDown) return;

    final status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Разрешите доступ к микрофону!')),
        );
      }
      return;
    }

    setState(() {
      isCountingDown = true;
      countdownTimer = 3;
      statusText = 'Get ready... 3';
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      setState(() {
        countdownTimer--;
        if (countdownTimer > 0) {
          statusText = 'Get ready... $countdownTimer';
        } else {
          timer.cancel();
          isCountingDown = false;
          _startActualRecording();
        }
      });
    });
  }

  Future<void> _startActualRecording() async {
    try {
      final Directory appDocDir = await getApplicationDocumentsDirectory();
      final String filePath = '${appDocDir.path}/Magic_Beat_${DateTime.now().millisecondsSinceEpoch}.m4a';

      await _audioRecorder.start(
        const RecordConfig(encoder: AudioEncoder.aacLc),
        path: filePath,
      );

      setState(() {
        isRecording = true;
        recordedFilePath = filePath;
        currentTrack = filePath.split('/').last;
        statusText = '🔴 Recording Trap Loop (BPM: ${currentBpm.toInt()})...';
      });
    } catch (e) {
      setState(() {
        statusText = 'Error starting record';
      });
    }
  }

  Future<void> stopRec() async {
    try {
      final path = await _audioRecorder.stop();
      setState(() {
        isRecording = false;
        recordedFilePath = path;
        statusText = 'Saved: $currentTrack';
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Запись сохранена: $currentTrack')),
        );
      }
    } catch (e) {
      setState(() {
        isRecording = false;
        statusText = 'Error stopping record';
      });
    }
  }

  void shareBeat() {
    if (recordedFilePath != null && File(recordedFilePath!).existsSync()) {
      Share.shareXFiles(
        [XFile(recordedFilePath!)],
        text: 'Мой новый бит из Magic Beats! BPM: ${currentBpm.toInt()}',
      );
    } else {
      Share.share('Magic Beats Loop (BPM: ${currentBpm.toInt()})');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Image.asset(
            'studio_background.jpg',
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
          Container(color: Colors.black26),

          Padding(
            padding: const EdgeInsets.only(top: 80, left: 20, right: 20, bottom: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.amber.withOpacity(0.3)),
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(color: Colors.amber.shade900, borderRadius: BorderRadius.circular(20)),
                        child: Text('${currentBpm.toInt()} BPM', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                      ),
                      Slider(
                        value: currentBpm,
                        min: 100, max: 160,
                        divisions: 12,
                        activeColor: Colors.amber,
                        onChanged: isRecording || isCountingDown ? null : (v) => setState(() => currentBpm = v),
                      ),
                    ],
                  ),
                ),

                GestureDetector(
                  onTap: isRecording ? stopRec : startRecProcess,
                  child: Container(
                    width: 180, height: 180,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isRecording ? Colors.red : isCountingDown ? Colors.orange : Colors.amber.shade700,
                      boxShadow: [BoxShadow(color: (isRecording ? Colors.red : Colors.amber).withOpacity(0.5), blurRadius: 20, spreadRadius: 5)],
                      border: Border.all(color: Colors.white24, width: 3),
                    ),
                    child: Center(
                      child: Text(
                        isCountingDown ? '$countdownTimer' : isRecording ? 'STOP' : 'REC',
                        style: TextStyle(fontSize: isCountingDown ? 50 : 32, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                  ),
                ),

                GestureDetector(
                  onTap: shareBeat,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.black87,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.amber.withOpacity(0.4)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Your Recording (Tap to Share)', style: TextStyle(fontSize: 10, color: Colors.grey)),
                              const SizedBox(height: 2),
                              Text(
                                currentTrack,
                                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.share, color: Colors.amber, size: 22),
                          onPressed: shareBeat,
                        ),
                      ],
                    ),
                  ),
                ),

                Text(
                  statusText,
                  style: TextStyle(color: isRecording ? Colors.redAccent : Colors.amber.shade200, fontSize: 13, fontStyle: FontStyle.italic),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
