import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:livekit_client/livekit_client.dart';

class VideoCallScreen extends StatefulWidget {
  final String token;
  const VideoCallScreen({Key? key, required this.token}) : super(key: key);

  @override
  _VideoCallScreenState createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends State<VideoCallScreen>
    with WidgetsBindingObserver {
  static const platform = MethodChannel('com.example.app/pip');

  final Room _room = Room();
  late final EventsListener<RoomEvent> _listener = _room.createListener();

  bool _isConnected = false;
  bool _isMuted = false;
  bool _isVideoEnabled = true;

  final roomOptions = RoomOptions(
    adaptiveStream: true,
    dynacast: true,
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _setUserInCall(true);
    _room.addListener(_onRoomChanged);

    _listener
      ..on<RoomDisconnectedEvent>((e) {
        log('Room disconnected : ${e.reason}');
        _room.removeListener(_onRoomChanged);
        _room.dispose();
        Navigator.pop(context);
      })
      ..on<ParticipantConnectedEvent>((e) {
        print("participant joined: ${e.participant.identity}");
        // setState(() {});
      })
      ..on<ParticipantDisconnectedEvent>((e) {
        log('Participant disconnected : ${e.participant.identity}');
        Navigator.pop(context);
      });
    _connectToRoom();
  }

  @override
  void dispose() {
    _setUserInCall(
        false); // Notify native code that the user left VideoCallScreen
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> _setUserInCall(bool isInCall) async {
    try {
      await platform.invokeMethod('setUserInCall', {'isInCall': isInCall});
    } on PlatformException catch (e) {
      print("Failed to set user in call: '${e.message}'.");
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      // App is minimized, trigger PiP mode via native code
      _enterPipMode();
    }
  }

  Future<void> _enterPipMode() async {
    try {
      await platform.invokeMethod('enterPipMode');
    } on PlatformException catch (e) {
      print("Failed to enter PiP mode: '${e.message}'.");
    }
  }

  Future<void> _connectToRoom() async {
    const String url = 'wss://aj-chat-tnl0o8ti.livekit.cloud';

    try {
      await _room.prepareConnection(url, widget.token);
      await _room.connect(url, widget.token, roomOptions: roomOptions);

      // Enable camera if available
      try {
        await _room.localParticipant?.setCameraEnabled(true);
      } catch (error) {
        print('Could not publish video, error: $error');
      }

      // Enable microphone
      await _room.localParticipant?.setMicrophoneEnabled(true);

      // Update state when connected
      setState(() {
        _isConnected = true;
      });

      // Listen to room changes
    } catch (e) {
      print('Error connecting to room: $e');
    }
  }

  void _onRoomChanged() {
    setState(() {});
  }

  void _toggleMute() async {
    if (_isMuted) {
      await _room.localParticipant?.setMicrophoneEnabled(true);
    } else {
      await _room.localParticipant?.setMicrophoneEnabled(false);
    }
    setState(() {
      _isMuted = !_isMuted;
    });
  }

  void _toggleVideo() async {
    if (_isVideoEnabled) {
      await _room.localParticipant?.setCameraEnabled(false);
    } else {
      await _room.localParticipant?.setCameraEnabled(true);
    }
    setState(() {
      _isVideoEnabled = !_isVideoEnabled;
    });
  }

  void _endCall() async {
    await _room.disconnect();

    // Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    log(_room.remoteParticipants.length.toString());
    final remoteParticipant = _room.remoteParticipants.isNotEmpty
        ? _room.remoteParticipants.values.first
        : null;
    return WillPopScope(
      onWillPop: () async {
        _enterPipMode();
        return false;
      },
      child: Scaffold(
          appBar: AppBar(
            title: const Text('LiveKit Video Call'),
            actions: [
              IconButton(
                icon: Icon(_isMuted ? Icons.mic_off : Icons.mic),
                onPressed: _toggleMute,
              ),
              IconButton(
                icon:
                    Icon(_isVideoEnabled ? Icons.videocam : Icons.videocam_off),
                onPressed: _toggleVideo,
              ),
              IconButton(
                icon: const Icon(Icons.call_end, color: Colors.red),
                onPressed: _endCall,
              ),
            ],
          ),
          body: _isConnected
              ? remoteParticipant == null
                  ? Stack(
                      children: [
                        _room.localParticipant == null
                            ? Container()
                            : ParticipantWidget(_room.localParticipant!),
                        // Local participant's video in fullscreen
                        Align(
                          alignment: Alignment.center,
                          child: Text(
                            'CALLING...',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 30,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    )
                  : Stack(
                      children: [
                        ParticipantWidget(remoteParticipant),
                        // Remote participants' video
                        // GridView.builder(
                        //   gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        //     crossAxisCount: _room.remoteParticipants.length + 2,
                        //     childAspectRatio: MediaQuery.of(context).size.width /
                        //         (MediaQuery.of(context).size.height),
                        //   ),
                        //   itemCount: _room.remoteParticipants.length,
                        //   itemBuilder: (context, index) {
                        //     return ParticipantWidget(
                        //         _room.remoteParticipants.values.elementAt(index));
                        //   },
                        // ),
                        // Local participant's video in fullscreen
                        Align(
                          alignment: Alignment.bottomRight,
                          child: SizedBox(
                            width: 150,
                            height: 200,
                            child: _room.localParticipant == null
                                ? Container()
                                : ParticipantWidget(_room.localParticipant!),
                          ),
                        ),
                      ],
                    )
              : _room.localParticipant == null
                  ? const Center(child: CircularProgressIndicator())
                  : Stack(
                      children: [
                        _room.localParticipant == null
                            ? Container()
                            : ParticipantWidget(_room.localParticipant!),
                        // Local participant's video in fullscreen
                        Align(
                          alignment: Alignment.center,
                          child: Text(
                            'CONNECTING...',
                          ),
                        ),
                      ],
                    )),
    );
  }
}

class ParticipantWidget extends StatelessWidget {
  final Participant participant;

  const ParticipantWidget(this.participant, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Access the video track from the participant
    final videoTrack = _getVideoTrack(participant);

    return Container(
      margin: const EdgeInsets.all(4.0),
      color: Colors.black,
      child: Stack(
        children: [
          // Render the video track if it exists, else show a camera off icon
          if (videoTrack != null)
            VideoTrackRenderer(videoTrack)
          else
            const Center(
              child: Icon(
                Icons.videocam_off,
                color: Colors.white,
              ),
            ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              color: Colors.black54,
              padding: const EdgeInsets.all(4.0),
              child: Text(
                participant.identity,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  VideoTrack? _getVideoTrack(Participant participant) {
    // Check if the participant has a video track published
    for (var publication in participant.trackPublications.values) {
      if (publication.track is VideoTrack) {
        return publication.track as VideoTrack;
      }
    }
    return null; // No video track available
  }
}
