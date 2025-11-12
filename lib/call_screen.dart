import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:livekit_client/livekit_client.dart';
import 'utils/snackbar_helper.dart';
import 'theme/app_colors.dart';
import 'theme/app_text_styles.dart';
import 'theme/app_dimensions.dart';

class VideoCallScreen extends StatefulWidget {
  final String token;
  const VideoCallScreen({super.key, required this.token});

  @override
  State<VideoCallScreen> createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends State<VideoCallScreen>
    with WidgetsBindingObserver {
  static const platform = MethodChannel('com.example.app/pip');

  final Room _room = Room(
    roomOptions: RoomOptions(
      adaptiveStream: true,
      dynacast: true,
    ),
  );
  late final EventsListener<RoomEvent> _listener = _room.createListener();

  bool _isConnected = false;
  bool _isMuted = false;
  bool _isVideoEnabled = true;

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
        log("participant joined: ${e.participant.identity}");
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
      log("Failed to set user in call: '${e.message}'.");
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
      log("Failed to enter PiP mode: '${e.message}'.");
    }
  }

  Future<void> _connectToRoom() async {
    const String url = 'wss://aj-chat-tnl0o8ti.livekit.cloud';

    try {
      await _room.prepareConnection(url, widget.token);
      await _room.connect(url, widget.token);

      // Enable camera if available
      try {
        await _room.localParticipant?.setCameraEnabled(true);
      } catch (error) {
        log('Could not publish video, error: $error');
      }

      // Enable microphone
      await _room.localParticipant?.setMicrophoneEnabled(true);

      // Update state when connected
      setState(() {
        _isConnected = true;
      });

      // Listen to room changes
    } catch (e) {
      log('Error connecting to room: $e');
      if (mounted) {
        SnackBarHelper.showError(context, 'Failed to connect to video call');
      }
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
    
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          _enterPipMode();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            // Video content area
            _buildVideoContent(remoteParticipant),
            
            // Modern app bar overlay
            _buildModernAppBar(context),
            
            // Modern control buttons overlay
            _buildControlsOverlay(),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoContent(Participant? remoteParticipant) {
    if (!_isConnected) {
      // Connecting state
      return Stack(
        children: [
          if (_room.localParticipant != null)
            ParticipantWidget(_room.localParticipant!),
          Center(
            child: _buildConnectionStatus('CONNECTING...', true),
          ),
        ],
      );
    }

    if (remoteParticipant == null) {
      // Calling state (waiting for remote participant)
      return Stack(
        children: [
          if (_room.localParticipant != null)
            ParticipantWidget(_room.localParticipant!),
          Center(
            child: _buildConnectionStatus('CALLING...', true),
          ),
        ],
      );
    }

    // Connected state with remote participant
    return Stack(
      children: [
        // Remote participant video (full screen)
        ParticipantWidget(remoteParticipant),
        
        // Local participant video (bottom-right corner)
        Positioned(
          bottom: AppDimensions.spacingXxl + 80, // Above controls
          right: AppDimensions.paddingL,
          child: Container(
            width: AppDimensions.localVideoPreviewWidth,
            height: AppDimensions.localVideoPreviewHeight,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppDimensions.radiusM),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppDimensions.radiusM),
              child: _room.localParticipant == null
                  ? Container(color: Colors.black)
                  : ParticipantWidget(_room.localParticipant!),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildConnectionStatus(String status, bool showLoader) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingL,
        vertical: AppDimensions.paddingM,
      ),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showLoader) ...[
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
            const SizedBox(height: AppDimensions.paddingM),
          ],
          Text(
            status,
            style: AppTextStyles.h3.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernAppBar(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top + AppDimensions.paddingS,
          bottom: AppDimensions.paddingM,
          left: AppDimensions.paddingS,
          right: AppDimensions.paddingM,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withValues(alpha: 0.7),
              Colors.black.withValues(alpha: 0.3),
              Colors.transparent,
            ],
          ),
        ),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white, size: AppDimensions.appBarIconSize),
              onPressed: () {
                _enterPipMode();
              },
            ),
            const SizedBox(width: AppDimensions.paddingS),
            Expanded(
              child: Text(
                'Video Call',
                style: AppTextStyles.h3.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlsOverlay() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).padding.bottom + AppDimensions.paddingM,
          top: AppDimensions.paddingXl,
          left: AppDimensions.paddingL,
          right: AppDimensions.paddingL,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [
              Colors.black.withValues(alpha: 0.7),
              Colors.black.withValues(alpha: 0.3),
              Colors.transparent,
            ],
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildControlButton(
              icon: _isMuted ? Icons.mic_off : Icons.mic,
              onPressed: _toggleMute,
              isActive: !_isMuted,
            ),
            _buildControlButton(
              icon: _isVideoEnabled ? Icons.videocam : Icons.videocam_off,
              onPressed: _toggleVideo,
              isActive: _isVideoEnabled,
            ),
            _buildControlButton(
              icon: Icons.call_end,
              onPressed: _endCall,
              isActive: false,
              isEndCall: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onPressed,
    required bool isActive,
    bool isEndCall = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(AppDimensions.radiusCircular),
        child: Container(
          width: AppDimensions.videoControlButtonSize,
          height: AppDimensions.videoControlButtonSize,
          decoration: BoxDecoration(
            color: isEndCall
                ? AppColors.error
                : isActive
                    ? AppColors.primary
                    : Colors.white.withValues(alpha: 0.3),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: AppDimensions.videoControlIconSize,
          ),
        ),
      ),
    );
  }
}

class ParticipantWidget extends StatelessWidget {
  final Participant participant;

  const ParticipantWidget(this.participant, {super.key});

  @override
  Widget build(BuildContext context) {
    // Access the video track from the participant
    final videoTrack = _getVideoTrack(participant);

    return Container(
      color: Colors.black,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Render the video track if it exists, else show a camera off icon
          if (videoTrack != null)
            VideoTrackRenderer(videoTrack)
          else
            const Center(
              child: Icon(
                Icons.videocam_off,
                color: Colors.white,
                size: 48,
              ),
            ),
          
          // Participant name overlay with modern typography
          Positioned(
            bottom: AppDimensions.paddingS,
            left: AppDimensions.paddingS,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.paddingM,
                vertical: AppDimensions.paddingS,
              ),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(AppDimensions.radiusS),
              ),
              child: Text(
                participant.identity,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
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
