// ManualSteeringPage_landscape.dart
// LANDSCAPE version – ready-to-use
// - Video stream background
// - Joysticks overlay
// - Scrollable layout to prevent overflow
// - Drone connect / RC logic unchanged
// - Telemetry row removed

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

// -----------------------------
// CONFIG
// -----------------------------
const String TELLO_IP = '192.168.10.1';
const int TELLO_CMD_PORT = 8889;
const int TELLO_STATE_PORT = 8890;
const int VLC_UDP_PORT = 11111; // aktuell ungenutzt, aber gelassen


const int RC_MAX = 100;
const double JOYSTICK_DEADZONE = 0.05;

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
  static const MethodChannel _telloChannel = MethodChannel('tello/network');

  Future<void> _bindWifi() async {
    try {
      debugPrint('TELLO/NET: bindWifi() calling Android...');
      await _telloChannel.invokeMethod('bindWifi');
      debugPrint('TELLO/NET: bindWifi() done');
    } catch (e) {
      debugPrint('TELLO/NET: bindWifi() FAILED: $e');
    }
  }

  Future<void> _logNetworks() async {
    try {
      debugPrint('TELLO/NET: logNetworks()');
      await _telloChannel.invokeMethod('logNetworks');
    } catch (e) {
      debugPrint('TELLO/NET: logNetworks FAILED: $e');
    }
  }

  Future<void> _unbindWifi() async {
    try {
      debugPrint('TELLO/NET: unbindWifi()');
      await _telloChannel.invokeMethod('unbindWifi');
      debugPrint('TELLO/NET: unbindWifi done');
    } catch (e) {
      debugPrint('TELLO/NET: unbindWifi FAILED: $e');
    }
  }

  bool connected = false;
  String statusText = 'Not connected to any drone';

  RawDatagramSocket? _cmdSocket;
  RawDatagramSocket? _stateSocket;

  // NEU: media_kit
  Player? _player;
  VideoController? _videoController;
  String? _videoError;

  Timer? _rcTimer;

  int roll = 0;
  int pitch = 0;
  int throttle = 0;
  int yaw = 0;

  // -----------------------------
  // FAILSAFE (Battery)
  // -----------------------------
  int? _batteryPct;
  bool _lowBattWarned = false;
  bool _landingTriggered = false;
  bool _isLanding = false;

  static const int LOW_BATT = 5;
  static const int CRIT_BATT = 2;

  Offset _leftJoy = Offset.zero;
  Offset _rightJoy = Offset.zero;

  late final AnimationController _fadeController;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _player = Player(
      configuration: PlayerConfiguration(
        logLevel: MPVLogLevel.debug,
        ready: () {
          try {
            final platform = (_player as dynamic).platform;
            platform.setProperty('load-unsafe-playlists', 'yes');
            debugPrint('TELLO/MPV: set load-unsafe-playlists=yes (ready)');
          } catch (e) {
            debugPrint('TELLO/MPV: setProperty failed in ready(): $e');
          }
        },
      ),
    );

    _videoController = VideoController(_player!);

    // mpv / media_kit logs auf Flutter-Konsole
    _player?.stream.log.listen((log) {
      debugPrint('TELLO/MPV_LOG: [${log.level}] ${log.prefix}: ${log.text}');
    });

    // errors
    _player?.stream.error.listen((err) {
      debugPrint('TELLO/MEDIA_KIT ERROR: $err');
      setState(() => _videoError = err);
    });

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

// muss top-level oder static sein, weil const PlayerConfiguratio

  @override
  void dispose() {
    _rcTimer?.cancel();
    _cmdSocket?.close();
    _stateSocket?.close();

    _player?.dispose();
    _fadeController.dispose();
    stopRc();

    try { _telloChannel.invokeMethod('unbindWifi'); } catch (_) {}

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  Future<void> _probeVideoPacketsOnce() async {
    RawDatagramSocket? probe;
    int count = 0;

    try {
      debugPrint('TELLO/PROBE: bind UDP 11111...');
      probe = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 11111, reuseAddress: true, reusePort: true);

      probe.listen((event) {
        if (event == RawSocketEvent.read) {
          final dg = probe!.receive();
          if (dg != null) {
            count++;
            if (count % 20 == 0) {
              debugPrint('TELLO/PROBE: packets=$count lastSize=${dg.data.length}');
            }
          }
        }
      });

      await Future.delayed(const Duration(seconds: 2));
      debugPrint('TELLO/PROBE: done packets=$count');
    } catch (e) {
      debugPrint('TELLO/PROBE: FAILED: $e');
    } finally {
      probe?.close();
    }
  }

  Future<void> _applyMpvOptions() async {
    try {
      final p = (_player as dynamic).platform;

      // wichtig bei Live-UDP
      p.setProperty('demuxer-lavf-probesize', '32k');
      p.setProperty('demuxer-lavf-analyzeduration', '0');

      // optional: drop frames lieber als stallen
      p.setProperty('framedrop', 'yes');

      // falls unsafe-playlist warning wiederkommt
      p.setProperty('load-unsafe-playlists', 'yes');

      debugPrint('TELLO/MPV: lavf low-latency options set');
    } catch (e) {
      debugPrint('TELLO/MPV: setProperty failed: $e');
    }
  }


  // -----------------------------
  // CONNECT
  // -----------------------------
  Future<void> connect() async {
    try {
      setState(() => statusText = 'Connecting...');
      debugPrint('TELLO: connect() start');

      // 1) Bind process to WIFI (Android fix)
      await _bindWifi();
      await _logNetworks();

      // 2) sockets
      debugPrint('TELLO: binding cmd socket...');
      _cmdSocket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 0);
      debugPrint('TELLO: cmd socket bound on ${_cmdSocket!.port}');

      debugPrint('TELLO: binding state socket 8890...');
      _stateSocket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, TELLO_STATE_PORT);
      debugPrint('TELLO: state socket bound on ${TELLO_STATE_PORT}');

      _stateSocket!.listen((event) {
        if (event == RawSocketEvent.read) {
          final datagram = _stateSocket!.receive();
          if (datagram != null) {
            final msg = utf8.decode(datagram.data, allowMalformed: true).trim();
            debugPrint('TELLO/STATE: $msg');
            _handleStateMessage(msg);
          }
        }
      });

      // 3) command mode
      _sendCmd('command');
      debugPrint('TELLO: sent command');
      await Future.delayed(const Duration(milliseconds: 800));
      _sendCmd('streamoff');
      await Future.delayed(const Duration(milliseconds: 300));

      // 4) stream on
      _sendCmd('streamon');
      debugPrint('TELLO: sent streamon');
      await Future.delayed(const Duration(milliseconds: 800));
      await _probeVideoPacketsOnce();

      // 5) open video stream (ONLY ONCE)
      debugPrint('TELLO/VIDEO: preparing mpv options...');
      await _applyMpvOptions();

      debugPrint('TELLO/VIDEO: opening udp://@:11111');
      await _player?.open(Media('avformat://udp://0.0.0.0:11111'));

      debugPrint('TELLO/VIDEO: open() finished');


      // 6) RC loop
      _rcTimer = Timer.periodic(const Duration(milliseconds: 50), (_) {
        if (!_isLanding) {
          _sendCmd('rc $roll $pitch $throttle $yaw');
        }
      });
      debugPrint('TELLO: RC timer started');

      setState(() {
        connected = true;
        statusText = 'Drone connected';
      });
      _fadeController.forward();
      debugPrint('TELLO: connect() success');
    } catch (e, st) {
      debugPrint('TELLO: connect() ERROR: $e');
      debugPrint('TELLO: stack: $st');
      setState(() {
        statusText = 'Connection error: $e';
        connected = false;
      });
    }
  }

  void _sendCmd(String cmd) {
    try {
      debugPrint('>>> TELLO CMD: $cmd');
      final bytes = utf8.encode(cmd);
      _cmdSocket?.send(bytes, InternetAddress(TELLO_IP), TELLO_CMD_PORT);
    } catch (e) {
      debugPrint('CMD SEND ERROR: $e');
    }
  }

  void takeoff() {
    _isLanding = false;
    _landingTriggered = false;
    _sendCmd('takeoff');
  }
  void land() => _sendCmd('land');
  void emergency() => _sendCmd('emergency');
  void stopRc() {
    roll = pitch = throttle = yaw = 0;
    _sendCmd('rc 0 0 0 0');
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

  void _handleStateMessage(String msg) {
    // Beispiel: "pitch:0;roll:0;...;bat:87;...;"
    final parts = msg.split(';');
    for (final p in parts) {
      final kv = p.split(':');
      if (kv.length != 2) continue;
      if (kv[0] == 'bat') {
        final b = int.tryParse(kv[1]);
        if (b != null) _onBattery(b);
      }
    }
  }

  void _onBattery(int b) {
    setState(() {
      _batteryPct = b;
    });

    // kritisch -> landen (einmalig)
    if (connected && !_landingTriggered && b <= CRIT_BATT) {
      _landingTriggered = true;
      _isLanding = true;

      setState(() {
        statusText = 'Critical battery ($b%). Auto-landing...';
      });

      stopRc();
      land();
      return;
    }

    // low warning (einmalig)
    if (connected && !_lowBattWarned && b <= LOW_BATT) {
      _lowBattWarned = true;
      setState(() {
        statusText = 'Low battery ($b%). Please land soon.';
      });
    }
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
                      SizedBox(height: 120, child: _buildActionsArea()),
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
            Positioned(
              left: 16,
              top: 18,
              child: FadeTransition(opacity: _fadeController, child: _connectionBadge()),
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
          const Spacer(),
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(color: Colors.red[100], shape: BoxShape.circle, border: Border.all(color: Colors.red)),
                child: const Center(child: Icon(Icons.arrow_downward, color: Colors.red)),
              ),
              const SizedBox(width: 8),
              _batteryBadge(),
              const SizedBox(width: 8),
              _iconCircle(Icons.videocam, 42, bgColor: Colors.yellow[100]),
              const SizedBox(width: 8),
              _iconCircle(Icons.download, 42, bgColor: Colors.yellow[100]),
              const SizedBox(width: 8),
              _iconCircle(Icons.upload, 42, bgColor: Colors.yellow[100]),
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
            if (_videoController != null)
              Video(
                controller: _videoController!,
                fit: BoxFit.cover,
              )
            else
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Warte auf Videostream...',
                      style: TextStyle(color: Colors.white),
                    ),
                    if (_videoError != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        // Text gelassen wie vorher (VLC-Fehler), um UI nicht zu ändern
                        'VLC-Fehler: $_videoError',
                        style: const TextStyle(color: Colors.redAccent, fontSize: 12),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ],
                ),
              ),
            Positioned(
              top: 12,
              left: 12,
              child: Row(
                children: [
                  _smallIconButton(Icons.settings, Colors.black.withOpacity(0.06), null),
                  const SizedBox(width: 8),
                  _smallIconButton(Icons.help_outline, Colors.black.withOpacity(0.06), null),
                ],
              ),
            ),
            Positioned(
              bottom: 12,
              left: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Roll: $roll', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text('Pitch: $pitch', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionsArea() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _bigActionButton('CONNECT', Icons.wifi, connected ? null : connect, connected ? Colors.grey : Colors.blue),
          _bigActionButton('TAKEOFF', Icons.flight_takeoff, connected ? takeoff : null, Colors.green),
          _bigActionButton('LAND', Icons.flight_land, connected ? land : null, Colors.red),
          _bigActionButton('EMERGENCY', Icons.warning, connected ? emergency : null, Colors.orange),
        ],
      ),
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
          Text(
            connected ? 'CONNECTED' : 'NOT CONNECTED',
            style: TextStyle(color: connected ? Colors.green[800] : Colors.red[800], fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _batteryBadge() {
    final b = _batteryPct; // int? (aus deinem State)
    final text = b == null ? '--%' : '$b%';

    final bool low = (b != null && b <= LOW_BATT);
    final bool crit = (b != null && b <= CRIT_BATT);

    Color bg;
    Color border;
    Color fg;

    if (crit) {
      bg = Colors.red[50]!;
      border = Colors.red;
      fg = Colors.red[800]!;
    } else if (low) {
      bg = Colors.orange[50]!;
      border = Colors.orange;
      fg = Colors.orange[800]!;
    } else {
      bg = Colors.green[50]!;
      border = Colors.green;
      fg = Colors.green[800]!;
    }

    return Container(
      height: 42,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: border, width: 1.2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.battery_std, size: 18, color: fg),
          const SizedBox(width: 6),
          Text(
            'BAT $text',
            style: TextStyle(color: fg, fontWeight: FontWeight.bold, fontSize: 12),
          ),
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

  const JoystickWidget({
    super.key,
    this.size = 140,
    this.backgroundOpacity = 0.2,
    this.innerOpacity = 0.4,
    this.child,
    this.onChanged,
    this.onEnd,
  });

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
    final normalized = Offset(
      (clamped.dx / radius).clamp(-1.0, 1.0),
      (clamped.dy / radius).clamp(-1.0, 1.0),
    );
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
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.12),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: Center(
                  child: Container(
                    width: knobSize * 0.38,
                    height: knobSize * 0.38,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.75),
                      shape: BoxShape.circle,
                    ),
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
