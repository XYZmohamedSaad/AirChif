// ManualSteeringPage_landscape.dart
// LANDSCAPE version – ready-to-use
// - Video stream background
// - Joysticks overlay
// - Top-right control icons: Emergency, Video, Land, Takeoff
// - Drone connect / RC logic unchanged

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';

const String TELLO_IP = '192.168.10.1';
const int TELLO_CMD_PORT = 8889;
const int TELLO_STATE_PORT = 8890;
const int VLC_UDP_PORT = 11111;

const int RC_MAX = 100;
const double JOYSTICK_DEADZONE = 0.08;

class ManualSteering extends StatefulWidget {
  static const String routePath = '/manual-steering';

  const ManualSteering({super.key});

  @override
  State<ManualSteering> createState() => _ManualSteeringState();
}

class _ManualSteeringState extends State<ManualSteering> with TickerProviderStateMixin {
  bool connected = false;
  bool videoOn = true;
  String statusText = 'Not connected to any drone';

  RawDatagramSocket? _cmdSocket;
  RawDatagramSocket? _stateSocket;

  VlcPlayerController? _videoController;

  Timer? _rcTimer;

  int roll = 0;
  int pitch = 0;
  int throttle = 0;
  int yaw = 0;

  Offset _leftJoy = Offset.zero;
  Offset _rightJoy = Offset.zero;

  late final AnimationController _fadeController;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  @override
  void dispose() {
    _rcTimer?.cancel();
    _cmdSocket?.close();
    _stateSocket?.close();
    _videoController?.dispose();
    _fadeController.dispose();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  // -----------------------------
  // CONNECT / VIDEO STREAM
  // -----------------------------
  Future<void> connect() async {
    try {
      setState(() => statusText = 'Connecting...');
      _cmdSocket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, TELLO_CMD_PORT);
      _stateSocket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, TELLO_STATE_PORT);
      _stateSocket!.listen((event) {
        if (event == RawSocketEvent.read) {
          final datagram = _stateSocket!.receive();
          if (datagram != null) {
            // parse state if needed
          }
        }
      });

      _sendCmd('command');
      await Future.delayed(const Duration(milliseconds: 500));
      _sendCmd('streamon');
      await Future.delayed(const Duration(seconds: 1)); // Warten bis Stream startet

      _videoController = VlcPlayerController.network(
        'udp://@:$VLC_UDP_PORT',
        hwAcc: HwAcc.full,
        autoPlay: true,
        options: VlcPlayerOptions(
          advanced: VlcAdvancedOptions(['--network-caching=300']),
          rtp: VlcRtpOptions(['--rtp-client-port=$VLC_UDP_PORT']),
        ),
      );

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

  void _sendCmd(String cmd) {
    try {
      final bytes = utf8.encode(cmd);
      _cmdSocket?.send(bytes, InternetAddress(TELLO_IP), TELLO_CMD_PORT);
    } catch (e) {}
  }

  void takeoff() => _sendCmd('takeoff');
  void land() => _sendCmd('land');
  void emergency() => _sendCmd('emergency');
  void stopRc() {
    roll = pitch = throttle = yaw = 0;
    _sendCmd('rc 0 0 0 0');
  }

  void _toggleVideo() {
    setState(() => videoOn = !videoOn);
    if (_videoController != null) {
      if (videoOn) {
        _videoController!.play();
      } else {
        _videoController!.stop();
      }
    }
  }

  void _updateFromJoysticks() {
    final rx = _rightJoy.dx;
    final ry = -_rightJoy.dy;
    final lx = _leftJoy.dx;
    final ly = -_leftJoy.dy;

    int mapAxis(double v) {
      if (v.abs() < JOYSTICK_DEADZONE) return 0;
      return (v.clamp(-1.0, 1.0) * RC_MAX).round();
    }

    setState(() {
      roll = mapAxis(rx);
      pitch = mapAxis(ry);
      yaw = mapAxis(lx);
      throttle = mapAxis(ly);
    });
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: media.size.height),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(height: 68, child: _buildTopBar()),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          child: _buildVideoAreaLandscape(),
                        ),
                      ),
                      const SizedBox(height: 120),
                    ],
                  ),
                ),
              ),
            ),
            // Joysticks overlay
            Positioned(
              left: 12,
              bottom: 12,
              child: JoystickWidget(
                size: 140,
                backgroundOpacity: 0.22,
                innerOpacity: 0.35,
                onChanged: (offset) {
                  _leftJoy = offset;
                  _updateFromJoysticks();
                },
                onEnd: () {
                  _leftJoy = Offset.zero;
                  _updateFromJoysticks();
                },
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
            // Connection badge
            Positioned(
              left: 16,
              top: 18,
              child: FadeTransition(opacity: _fadeController, child: _connectionBadge()),
            ),
            // Top-right control icons
            Positioned(
              right: 16,
              top: 18,
              child: Row(
                children: [
                  _smallIconButton(Icons.warning, Colors.red, connected ? emergency : null),
                  const SizedBox(width: 8),
                  _smallIconButton(videoOn ? Icons.videocam : Icons.videocam_off, Colors.yellow[800]!, _toggleVideo),
                  const SizedBox(width: 8),
                  _smallIconButton(Icons.flight_land, Colors.red, connected ? land : null),
                  const SizedBox(width: 8),
                  _smallIconButton(Icons.flight_takeoff, Colors.green, connected ? takeoff : null),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // -----------------------------
  // WIDGETS
  // -----------------------------
  Widget _buildTopBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Row(
            children: [
              _iconCircle(Icons.settings, 40),
              const SizedBox(width: 10),
              _iconCircle(Icons.home, 40),
              const SizedBox(width: 10),
              _iconCircle(Icons.pie_chart, 40),
              const SizedBox(width: 10),
              _iconCircle(Icons.person, 40),
            ],
          ),
        ],
      ),
    );
  }

  Widget _iconCircle(IconData icon, double size, {Color? bgColor}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: bgColor ?? Colors.black12, shape: BoxShape.circle),
      child: Icon(icon, size: size * 0.46),
    );
  }

  Widget _buildVideoAreaLandscape() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 12, offset: const Offset(0, 6))],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (_videoController != null && videoOn)
              VlcPlayer(
                controller: _videoController!,
                aspectRatio: 16 / 9,
                placeholder: Container(color: Colors.black),
              )
            else
              Container(color: Colors.black),
            Positioned(
              bottom: 12,
              left: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Roll: \$roll', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text('Pitch: \$pitch', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],
        ),
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
  Offset _localPos = Offset.zero;

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
            CustomPaint(
              size: Size(widget.size, widget.size),
              painter: _JoystickBackgroundPainter(opacity: widget.backgroundOpacity),
            ),
            Positioned.fill(
              child: CustomPaint(
                painter: _JoystickGridPainter(),
              ),
            ),
            if (widget.child != null) Center(child: widget.child),
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
                child: Center(
                  child: Container(
                    width: knobSize * 0.38,
                    height: knobSize * 0.38,
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.75), shape: BoxShape.circle),
                  ),
                ),
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
    canvas.drawLine(Offset(center.dx, 0), Offset(center.dx, size.height), paint);
    canvas.drawLine(Offset(0, center.dy), Offset(size.width, center.dy), paint);
    for (int i = 1; i <= 3; i++) {
      canvas.drawCircle(center, (size.width / 2) * (i / 4), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
