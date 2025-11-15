import 'package:flutter/material.dart';
import 'dart:math';

class ManualSteering extends StatefulWidget {
  const ManualSteering({super.key});

  static const routePath = "/manual-steering";

  @override
  State<ManualSteering> createState() => _ManualSteeringState();
}

// ============================================================================
// DRONE CONTROLLER (SAFE PLACEHOLDERS)
// ============================================================================
class DroneController {
  bool connected = false;

  Future<void> connect() async {
    await Future.delayed(const Duration(seconds: 1));
    connected = true;
  }

  void disconnect() {
    connected = false;
  }

  void emergencyStop() {}
  void toggleCamera() {}
  void startFlight() {}
  void land() {}
  void move(String direction) {}
  void rotate(String direction) {}
  void moveVertical(String direction) {}
}

// ============================================================================
// MANUAL STEERING PAGE UI
// ============================================================================
class _ManualSteeringState extends State<ManualSteering> {
  final DroneController controller = DroneController();
  bool connecting = false;

  @override
  void initState() {
    super.initState();
    connectToDrone();
  }

  Future<void> connectToDrone() async {
    setState(() => connecting = true);
    await controller.connect();
    setState(() => connecting = false);
  }

  Widget topButton(String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 55,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.grey.shade900,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(label, style: const TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget circleButton(IconData icon, {Color color = Colors.white, VoidCallback? onTap}) {
    return InkResponse(
      radius: 35,
      onTap: onTap,
      child: CircleAvatar(
        radius: 35,
        backgroundColor: Colors.grey.shade900,
        child: Icon(icon, color: color, size: 32),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Manual Steering"),
        backgroundColor: Colors.grey.shade900,
      ),

      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                // ------------------------------------
                // STATUS BAR
                // ------------------------------------
                Container(
                  padding: const EdgeInsets.all(16),
                  alignment: Alignment.centerLeft,
                  child: Text(
                    controller.connected ? "Drone connected" : "Drone not connected",
                    style: TextStyle(
                      color: controller.connected ? Colors.green : Colors.red,
                      fontSize: 18,
                    ),
                  ),
                ),

                // ------------------------------------
                // TOP NAV BUTTONS
                // ------------------------------------
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      topButton("PAGE 1", () {}),
                      const SizedBox(height: 10),
                      topButton("PAGE 2", () {}),
                      const SizedBox(height: 10),
                      topButton("PAGE 3", () {}),
                      const SizedBox(height: 10),
                      topButton("PAGE 4", () {}),
                    ],
                  ),
                ),

                const Spacer(),

                // ------------------------------------
                // CONTROLS ROW
                // ------------------------------------
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // ---------------- JOYSTICK ----------------
                      _Joystick(
                        onDirection: (dir) {
                          controller.move(dir);
                        },
                      ),

                      // --------------- SIDE BUTTONS ---------------
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          circleButton(Icons.arrow_drop_up, onTap: () {
                            controller.moveVertical("up");
                          }),
                          const SizedBox(height: 16),
                          circleButton(Icons.rotate_left, onTap: () {
                            controller.rotate("left");
                          }),
                          const SizedBox(height: 16),
                          circleButton(Icons.rotate_right, onTap: () {
                            controller.rotate("right");
                          }),
                          const SizedBox(height: 16),
                          circleButton(Icons.arrow_drop_down, onTap: () {
                            controller.moveVertical("down");
                          }),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // ------------------------------------
                // BOTTOM ACTION BUTTONS
                // ------------------------------------
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    circleButton(Icons.warning, color: Colors.red, onTap: controller.emergencyStop),
                    circleButton(Icons.camera_alt, onTap: controller.toggleCamera),
                    circleButton(Icons.flight_takeoff, onTap: controller.startFlight),
                    circleButton(Icons.flight_land, onTap: controller.land),
                  ],
                ),

                const SizedBox(height: 40),
              ],
            ),

            if (connecting)
              Container(
                color: Colors.black54,
                alignment: Alignment.center,
                child: const CircularProgressIndicator(color: Colors.white),
              ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// SIMPLE JOYSTICK
// ============================================================================
class _Joystick extends StatefulWidget {
  final void Function(String direction) onDirection;

  const _Joystick({required this.onDirection, super.key});

  @override
  State<_Joystick> createState() => _JoystickState();
}

class _JoystickState extends State<_Joystick> {
  Offset offset = Offset.zero;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanUpdate: (d) {
        setState(() => offset = Offset(d.delta.dx, d.delta.dy));

        if (d.delta.dx.abs() > d.delta.dy.abs()) {
          if (d.delta.dx > 0) widget.onDirection("right");
          if (d.delta.dx < 0) widget.onDirection("left");
        } else {
          if (d.delta.dy > 0) widget.onDirection("back");
          if (d.delta.dy < 0) widget.onDirection("forward");
        }
      },
      onPanEnd: (_) => setState(() => offset = Offset.zero),
      child: Container(
        height: 150,
        width: 150,
        decoration: BoxDecoration(
          color: Colors.grey.shade900,
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: const Text("JOYSTICK", style: TextStyle(color: Colors.white70)),
      ),
    );
  }
}
