// ManualSteeringPage.dart
// Full-featured Tello control page with professional UI mockup support
// - Vertical layout
// - Two transparent joysticks (left + right, bottom corners)
// - VLC video stream (udp://@:11111) using flutter_vlc_player
// - UDP command + state sockets (192.168.10.1:8889 / 8890)
// - RC send loop (20 Hz)
// - Smooth joystick with deadzone and max scaling
// - Copy & paste ready Dart file

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';

// -----------------------------
// CONFIG
// -----------------------------
const String TELLO_IP = '192.168.10.1';
const int TELLO_CMD_PORT = 8889;
const int TELLO_STATE_PORT = 8890;
const int VLC_UDP_PORT = 11111;

// Joystick mapping configuration (Tello expects rc <roll> <pitch> <throttle> <yaw>)
// We'll map right joystick to roll (x) and pitch (y)
// Left joystick to throttle (y) and yaw (x)
const int RC_MAX = 100; // max absolute value sent to tello
const double JOYSTICK_DEADZONE = 0.08; // fraction of radius

// -----------------------------
// MAIN WIDGET
// -----------------------------
class ManualSteering extends StatefulWidget {
  static const String routePath = '/manual-steering';

  const ManualSteering({super.key});

  @override
  State<ManualSteering> createState() => _ManualSteeringState();
}

class _ManualSteeringState extends State<ManualSteering> with TickerProviderStateMixin {
  // connection & status
  bool connected = false;
  String statusText = 'Not connected to any drone';

  // sockets
  RawDatagramSocket? _cmdSocket;
  RawDatagramSocket? _stateSocket;

  // video
  VlcPlayerController? _videoController;

  // RC timer (20Hz)
  Timer? _rcTimer;

  // RC values (-100..100)
  int roll = 0;
  int pitch = 0;
  int throttle = 0;
  int yaw = 0;

  // Joystick states (normalized -1..1)
  Offset _leftJoy = Offset.zero; // throttle (y), yaw (x)
  Offset _rightJoy = Offset.zero; // pitch (y), roll (x)

  // Smooth animation for UI feedback
  late final AnimationController _fadeController;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
  }

  @override
  void dispose() {
    _rcTimer?.cancel();
    _cmdSocket?.close();
    _stateSocket?.close();
    _videoController?.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  // -----------------------------
  // CONNECT
  // -----------------------------
  Future<void> connect() async {
    try {
      setState(() => statusText = 'Connecting...');

      // bind command socket
      _cmdSocket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, TELLO_CMD_PORT);

      // bind state socket and listen for telemetry
      _stateSocket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, TELLO_STATE_PORT);
      _stateSocket!.listen((event) {
        if (event == RawSocketEvent.read) {
          final datagram = _stateSocket!.receive();
          if (datagram != null) {
            // optional: parse state string if you want to show battery/height
            // final payload = utf8.decode(datagram.data);
            // print('STATE: $payload');
          }
        }
      });

      // send command mode
      _sendCmd('command');
      await Future.delayed(const Duration(milliseconds: 500));

      // enable video
      _sendCmd('streamon');
      await Future.delayed(const Duration(milliseconds: 500));

      // initialize VLC controller
      _videoController = VlcPlayerController.network(
        'udp://@:$VLC_UDP_PORT',
        hwAcc: HwAcc.full,
        autoPlay: true,
        options: VlcPlayerOptions(
          advanced: VlcAdvancedOptions(['--network-caching=150']),
          rtp: VlcRtpOptions(['--rtp-client-port=$VLC_UDP_PORT']),
        ),
      );

      // start RC loop 20Hz
      _rcTimer = Timer.periodic(const Duration(milliseconds: 50), (_) {
        _sendCmd('rc \$roll \$pitch \$throttle \$yaw');
      });

      setState(() {
        connected = true;
        statusText = 'Drone connected';
      });

      _fadeController.forward();
    } catch (e) {
      setState(() {
        statusText = 'Connection error: \$e';
        connected = false;
      });
    }
  }

  // -----------------------------
  // SEND COMMAND
  // -----------------------------
  void _sendCmd(String cmd) {
    try {
      final bytes = utf8.encode(cmd);
      _cmdSocket?.send(bytes, InternetAddress(TELLO_IP), TELLO_CMD_PORT);
    } catch (e) {
      // ignore send errors silently
    }
  }

  // -----------------------------
  // ACTIONS
  // -----------------------------
  void takeoff() => _sendCmd('takeoff');
  void land() => _sendCmd('land');
  void emergency() => _sendCmd('emergency');
  void stopRc() {
    roll = pitch = throttle = yaw = 0;
    _sendCmd('rc 0 0 0 0');
  }

  // -----------------------------
  // JOYSTICK -> RC mapping
  // -----------------------------
  void _updateFromJoysticks() {
    // right joystick -> roll (x), pitch (y)
    final rx = _rightJoy.dx; // -1..1
    final ry = -_rightJoy.dy; // invert Y so up is positive

    // left joystick -> yaw (x), throttle (y)
    final lx = _leftJoy.dx;
    final ly = -_leftJoy.dy;

    // apply deadzone
    int mapAxis(double v) {
      if (v.abs() < JOYSTICK_DEADZONE) return 0;
      final scaled = (v.clamp(-1.0, 1.0) * RC_MAX).round();
      return scaled;
    }

    setState(() {
      roll = mapAxis(rx);
      pitch = mapAxis(ry);
      yaw = mapAxis(lx);
      throttle = mapAxis(ly);
    });
  }

  // -----------------------------
  // BUILD
  // -----------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                // TOP BAR
                _buildTopBar(),

                // VIDEO
                Expanded(flex: 5, child: _buildVideoArea()),

                // ACTIONS & INFO
                _buildActionsArea(),
              ],
            ),

            // Joysticks overlay bottom-left and bottom-right
            Positioned(
              left: 12,
              bottom: 12,
              child: JoystickWidget(
                size: 140,
                backgroundOpacity: 0.22, // transparent per user
                innerOpacity: 0.35,
                onChanged: (offset) {
                  _leftJoy = offset;
                  _updateFromJoysticks();
                },
                onEnd: () {
                  _leftJoy = Offset.zero;
                  _updateFromJoysticks();
                },
                // label overlay (optional)
                child: const SizedBox.shrink(),
              ),
            ),

            Positioned(
              right: 12,
              bottom: 12,
              child: JoystickWidget(
                size: 140,
                backgroundOpacity: 0.22,
                innerOpacity: 0.35,
                onChanged: (offset) {
                  _rightJoy = offset;
                  _updateFromJoysticks();
                },
                onEnd: () {
                  _rightJoy = Offset.zero;
                  _updateFromJoysticks();
                },
              ),
            ),

            // small status floating indicator
            Positioned(
              left: 16,
              top: 18,
              child: FadeTransition(
                opacity: _fadeController,
                child: _connectionBadge(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // Logo / title area
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text('Spechti Tello', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 4),
              Text('Professional Control', style: TextStyle(fontSize: 12, color: Colors.black54)),
            ],
          ),
          const Spacer(),
          // small indicators
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(statusText, style: const TextStyle(fontSize: 12, color: Colors.black54)),
              const SizedBox(height: 4),
              Row(
                children: [
                  _smallIconButton(Icons.power, connected ? Colors.green : Colors.grey, connect),
                  const SizedBox(width: 8),
                  _smallIconButton(Icons.videocam, Colors.blue, connect),
                ],
              )
            ],
          )
        ],
      ),
    );
  }

  Widget _buildVideoArea() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 12, offset: const Offset(0, 6))],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: SizedBox.expand(
          child: _videoController == null
              ? Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.videocam_off, size: 48, color: Colors.white54),
                SizedBox(height: 8),
                Text('Live stream not started', style: TextStyle(color: Colors.white70)),
              ],
            ),
          )
              : VlcPlayer(
            controller: _videoController!,
            aspectRatio: 16 / 9,
            placeholder: const Center(child: CircularProgressIndicator()),
          ),
        ),
      ),
    );
  }

  Widget _buildActionsArea() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _bigActionButton('CONNECT', Icons.wifi, connect, connected ? Colors.grey : Colors.blue),
              _bigActionButton('TAKEOFF', Icons.flight_takeoff, connected ? takeoff : null, Colors.green),
              _bigActionButton('LAND', Icons.flight_land, connected ? land : null, Colors.red),
              _bigActionButton('EMERGENCY', Icons.warning, connected ? emergency : null, Colors.orange),
            ],
          ),
          const SizedBox(height: 12),

          // telemetry strip (placeholder for battery/height)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 6))],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _telemetryItem('Battery', '—'),
                _telemetryItem('Height', '—'),
                _telemetryItem('Temp', '—'),
                _telemetryItem('Roll', '\$roll'),
                _telemetryItem('Pitch', '\$pitch'),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _telemetryItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.black54)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _bigActionButton(String label, IconData icon, VoidCallback? onTap, Color color) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: onTap == null ? Colors.grey[300] : color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Widget _smallIconButton(IconData icon, Color color, VoidCallback? onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: color.withOpacity(0.12), shape: BoxShape.circle),
        child: Icon(icon, size: 18, color: color),
      ),
    );
  }

  Widget _connectionBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: connected ? Colors.green[50] : Colors.red[50],
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: connected ? Colors.green : Colors.red, width: 1.2),
      ),
      child: Row(
        children: [
          Icon(connected ? Icons.check_circle : Icons.cancel, color: connected ? Colors.green : Colors.red, size: 16),
          const SizedBox(width: 8),
          Text(connected ? 'CONNECTED' : 'NOT CONNECTED', style: TextStyle(color: connected ? Colors.green[800] : Colors.red[800], fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

// -----------------------------
// JOYSTICK WIDGET
// - simple reusable joystick
// - outputs Offset(-1..1, -1..1)
// - supports transparent background and inner knob
// -----------------------------
class JoystickWidget extends StatefulWidget {
  final double size;
  final double backgroundOpacity;
  final double innerOpacity;
  final Widget? child;
  final void Function(Offset normalized)? onChanged;
  final VoidCallback? onEnd;

  const JoystickWidget({super.key, this.size = 140, this.backgroundOpacity = 0.2, this.innerOpacity = 0.4, this.child, this.onChanged, this.onEnd});

  @override
  State<JoystickWidget> createState() => _JoystickWidgetState();
}

class _JoystickWidgetState extends State<JoystickWidget> {
  Offset _localPos = Offset.zero; // from center

  void _updateLocal(Offset globalPos) {
    final renderBox = context.findRenderObject() as RenderBox;
    final local = renderBox.globalToLocal(globalPos);
    final center = Offset(widget.size / 2, widget.size / 2);
    final delta = local - center;

    final radius = widget.size / 2;
    final clamped = Offset(delta.dx.clamp(-radius, radius), delta.dy.clamp(-radius, radius));
    setState(() => _localPos = clamped);

    final normalized = Offset((clamped.dx / radius).clamp(-1.0, 1.0), (clamped.dy / radius).clamp(-1.0, 1.0));
    widget.onChanged?.call(normalized);
  }

  void _end() {
    setState(() => _localPos = Offset.zero);
    widget.onEnd?.call();
  }

  @override
  Widget build(BuildContext context) {
    final radius = widget.size / 2;
    final knobSize = widget.size * 0.42;

    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: GestureDetector(
        onPanStart: (details) => _updateLocal(details.globalPosition),
        onPanUpdate: (details) => _updateLocal(details.globalPosition),
        onPanEnd: (_) => _end(),
        onPanCancel: _end,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // background circle (transparent)
            CustomPaint(
              size: Size(widget.size, widget.size),
              painter: _JoystickBackgroundPainter(opacity: widget.backgroundOpacity),
            ),

            // inner grid marks (subtle)
            Positioned.fill(
              child: CustomPaint(
                painter: _JoystickGridPainter(),
              ),
            ),

            // optional child (icons etc.)
            if (widget.child != null) Center(child: widget.child),

            // knob
            Transform.translate(
              offset: _localPos,
              child: Container(
                width: knobSize,
                height: knobSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(widget.innerOpacity),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 8, offset: const Offset(0, 4))],
                ),
                child: Center(child: Container(width: knobSize * 0.38, height: knobSize * 0.38, decoration: BoxDecoration(color: Colors.white.withOpacity(0.75), shape: BoxShape.circle))),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _JoystickBackgroundPainter extends CustomPainter {
  final double opacity;
  _JoystickBackgroundPainter({required this.opacity});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black.withOpacity(opacity);
    canvas.drawCircle(Offset(size.width / 2, size.height / 2), size.width / 2, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _JoystickGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.06)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    // crosshair
    canvas.drawLine(Offset(center.dx, 0), Offset(center.dx, size.height), paint);
    canvas.drawLine(Offset(0, center.dy), Offset(size.width, center.dy), paint);

    // small rings
    for (int i = 1; i <= 3; i++) {
      canvas.drawCircle(center, (size.width / 2) * (i / 4), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// -----------------------------
// USAGE NOTES (do not include in app):
// - Add dependency in pubspec.yaml: flutter_vlc_player: ^7.4.4
// - Android: ensure INTERNET and ACCESS_NETWORK_STATE and uses-permission for UDP if needed
// - Run app while phone is connected to Tello WiFi (default SSID usually Tello-XXXX)
// - Copy this file into your lib/ and push to device
// -----------------------------
