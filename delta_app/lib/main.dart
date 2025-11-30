import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Delta AI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xFF00E5FF), // Cyan accent
        scaffoldBackgroundColor: const Color(0xFF121212),
        textTheme: GoogleFonts.outfitTextTheme(
          Theme.of(context).textTheme.apply(bodyColor: Colors.white, displayColor: Colors.white),
        ),
        useMaterial3: true,
      ),
      home: const DeltaListenerScreen(),
    );
  }
}

class DeltaListenerScreen extends StatefulWidget {
  const DeltaListenerScreen({super.key});

  @override
  State<DeltaListenerScreen> createState() => _DeltaListenerScreenState();
}

class _DeltaListenerScreenState extends State<DeltaListenerScreen> {
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _status = "Initializing...";
  final List<String> _logs = [];
  final ScrollController _scrollController = ScrollController();
  int _errorCount = 0;
  bool _hasPermanentError = false;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _initSpeech();
  }

  Future<void> _initSpeech() async {
    // Request permissions first
    var status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      setState(() {
        _status = "Microphone permission denied";
      });
      return;
    }

    bool available = await _speech.initialize(
      onStatus: (val) {
        print('onStatus: $val');
        if (val == 'done' || val == 'notListening') {
          setState(() => _isListening = false);
          // Only auto-restart if we don't have a permanent error
          if (!_hasPermanentError && _errorCount < 3) {
            Future.delayed(const Duration(milliseconds: 500), _startListening);
          }
        } else if (val == 'listening') {
          setState(() {
            _isListening = true;
            _errorCount = 0; // Reset error count on successful listen
          });
        }
      },
      onError: (val) {
        print('onError: $val');
        _errorCount++;
        
        setState(() {
          _isListening = false;
          
          // Check if it's a permanent error
          if (val.permanent) {
            _hasPermanentError = true;
            if (val.errorMsg == 'error_client') {
              _status = "Error: Check internet connection & Google app";
            } else if (val.errorMsg == 'error_speech_timeout') {
              _status = "Error: No speech detected. Tap mic to retry.";
            } else {
              _status = "Error: ${val.errorMsg}. Tap mic to retry.";
            }
          } else {
            _status = "Error: ${val.errorMsg}";
            // Only retry non-permanent errors
            if (_errorCount < 3) {
              Future.delayed(const Duration(seconds: 2), _startListening);
            } else {
              _status = "Too many errors. Tap mic to retry.";
            }
          }
        });
      },
    );

    if (available) {
      setState(() {
        _status = "Ready to listen";
      });
      _startListening();
    } else {
      setState(() {
        _status = "Speech recognition not available";
      });
    }
  }

  void _startListening() async {
    if (!_isListening && _speech.isAvailable) {
      // Reset error flags when manually starting
      _hasPermanentError = false;
      _errorCount = 0;
      
      await _speech.listen(
        onResult: _onSpeechResult,
        listenFor: const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 5),
        partialResults: false,
        cancelOnError: false,
        listenMode: stt.ListenMode.dictation,
      );
      setState(() {
        _status = "Listening...";
        _isListening = true;
      });
    }
  }

  void _onSpeechResult(var result) {
    if (result.finalResult) {
      String sentence = result.recognizedWords;
      if (sentence.isEmpty) return;

      String logEntry;
      if (sentence.toLowerCase().contains("delta")) {
        logEntry = "recognising: $sentence";
      } else {
        logEntry = "ignoring: $sentence";
      }

      setState(() {
        _logs.add(logEntry);
        // Auto-scroll to bottom
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController.hasClients) {
            _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          }
        });
      });
      
      // Restart listening loop is handled by onStatus 'done'
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Delta AI Listener"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Status Indicator
          Container(
            padding: const EdgeInsets.all(16),
            width: double.infinity,
            color: _isListening ? const Color(0xFF1E1E1E) : Colors.red.withOpacity(0.1),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _isListening ? Icons.mic : Icons.mic_off,
                  color: _isListening ? const Color(0xFF00E5FF) : Colors.grey,
                ),
                const SizedBox(width: 10),
                Text(
                  _status,
                  style: TextStyle(
                    color: _isListening ? const Color(0xFF00E5FF) : Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          
          // Logs List
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _logs.length,
              itemBuilder: (context, index) {
                final log = _logs[index];
                final isRecognised = log.startsWith("recognising:");
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isRecognised 
                        ? const Color(0xFF00E5FF).withOpacity(0.1) 
                        : const Color(0xFF2C2C2C),
                    borderRadius: BorderRadius.circular(8),
                    border: isRecognised 
                        ? Border.all(color: const Color(0xFF00E5FF).withOpacity(0.3)) 
                        : null,
                  ),
                  child: Text(
                    log,
                    style: TextStyle(
                      color: isRecognised ? const Color(0xFF00E5FF) : Colors.grey[400],
                      fontSize: 16,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _isListening ? _speech.stop : _startListening,
        backgroundColor: const Color(0xFF00E5FF),
        child: Icon(_isListening ? Icons.stop : Icons.mic),
      ),
    );
  }
}
