import 'dart:math' as math;
import 'package:flutter/material.dart';

class TeamPage extends StatefulWidget {
  const TeamPage({super.key});
  @override
  State<TeamPage> createState() => _TeamPageState();
}

class _TeamPageState extends State<TeamPage> {
  // ── EDIT HERE: your three members ─────────────────────────
  static const List<_Member> _members = [
    _Member(
      name: 'Dang',
      role: 'Firmware & Integration',
      tag: 'ESP32',
      bio: 'Builds the brain. Handles real-time control loops and Wi-Fi.',
      email: 'example.com',
      github: 'github.com/danny',
    ),
    _Member(
      name: 'Justin',
      role: 'Computer Vision',
      tag: 'MediaPipe',
      bio: 'Trains and tunes the gesture recognizer. Owns the camera pipeline.',
      email: '@example.com',
      github: 'github.com/alex',
    ),
    _Member(
      name: 'Lalith',
      role: 'Hardware & PCB',
      tag: 'Sensors',
      bio: 'Designs the board and wiring. Calibrates ToF and IMU sensor fusion.',
      email: '@example.com',
      github: 'github.com/sam',
    ),
  ];

  int _currentIndex = 0;
  double _gearAngle = 0;
  double _dragAccumulator = 0;

  // ── TUNING KNOBS ──────────────────────────────────────────
  // Pixels of drag per card step. Lower = more sensitive.
  static const double _dragStepPixels = 35;

  // Visual spin rate. Lower divisor = faster gear rotation.
  static const double _gearSpinDivisor = 40;

  void _onGearDragUpdate(DragUpdateDetails d) {
    setState(() {
      _gearAngle += d.delta.dy / _gearSpinDivisor;
      _dragAccumulator += d.delta.dy;

      while (_dragAccumulator >= _dragStepPixels) {
        _dragAccumulator -= _dragStepPixels;
        _stepForward();
      }
      while (_dragAccumulator <= -_dragStepPixels) {
        _dragAccumulator += _dragStepPixels;
        _stepBackward();
      }
    });
  }

  void _stepForward() {
    _currentIndex = (_currentIndex + 1) % _members.length;
  }

  void _stepBackward() {
    _currentIndex = (_currentIndex - 1 + _members.length) % _members.length;
  }

  /// -1 = top-right small, 0 = center-left big, 1 = bottom-right small,
  /// null = hidden.
  int? _slotFor(int memberIndex) {
    final n = _members.length;
    int diff = memberIndex - _currentIndex;
    if (diff > n ~/ 2) diff -= n;
    if (diff < -(n ~/ 2)) diff += n;
    if (diff >= -1 && diff <= 1) return diff;
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Center(
          child: Text(
            'Meet the Crew',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 4),
        const Center(
          child: Text(
            'Turn the gear to switch · tap a card to flip',
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ),
        const SizedBox(height: 20),

        // ── STAGE ────────────────────────────────────────────
        // Height is fixed so LayoutBuilder can compute stable
        // coordinates for the absolutely positioned cards + gear.
        SizedBox(
          height: 440,
          child: LayoutBuilder(
            builder: (context, constraints) {
              const double H = 440;
              const double rightColW = 130;
              const double gap = 12;
              const double gearSize = 90;

              final totalW = constraints.maxWidth;
              final leftColW = totalW - rightColW - gap;
              // Two small cards + two gaps + gear fill the height.
              final smallH = (H - gearSize - 2 * gap) / 2;
              final rightX = leftColW + gap;

              return Stack(
                clipBehavior: Clip.none,
                children: [
                  // ── CARDS ──────────────────────────────────
                  ..._members.asMap().entries.map((e) {
                    final slot = _slotFor(e.key);

                    // Compute target geometry for each slot.
                    double top, left, w, h;
                    switch (slot) {
                      case 0: // BIG — left column, full height
                        top = 0;
                        left = 0;
                        w = leftColW;
                        h = H;
                        break;
                      case -1: // small — top right, above gear
                        top = 0;
                        left = rightX;
                        w = rightColW;
                        h = smallH;
                        break;
                      case 1: // small — bottom right, below gear
                        top = H - smallH;
                        left = rightX;
                        w = rightColW;
                        h = smallH;
                        break;
                      default: // hidden — parked off-screen, faded
                        top = H;
                        left = rightX;
                        w = rightColW;
                        h = smallH;
                    }

                    return AnimatedPositioned(
                      key: ValueKey('member-${e.key}'),
                      duration: const Duration(milliseconds: 420),
                      curve: Curves.easeOutCubic,
                      top: top,
                      left: left,
                      width: w,
                      height: h,
                      child: AnimatedOpacity(
                        duration: const Duration(milliseconds: 420),
                        opacity: slot != null ? 1 : 0,
                        child: _FlipMemberCard(member: e.value),
                      ),
                    );
                  }),

                  // ── GEAR ───────────────────────────────────
                  Positioned(
                    top: smallH + gap,
                    left: rightX + (rightColW - gearSize) / 2,
                    width: gearSize,
                    height: gearSize,
                    child: _GearWidget(
                      angle: _gearAngle,
                      onDragUpdate: _onGearDragUpdate,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
// GEAR
// ─────────────────────────────────────────────────────────────
class _GearWidget extends StatelessWidget {
  final double angle;
  final void Function(DragUpdateDetails) onDragUpdate;

  const _GearWidget({required this.angle, required this.onDragUpdate});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onVerticalDragUpdate: onDragUpdate,
      child: MouseRegion(
        cursor: SystemMouseCursors.grab,
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.18),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Center(
            child: Transform.rotate(
              angle: angle,
              child: Icon(
                Icons.settings,
                size: 48,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// MEMBER DATA MODEL
// ─────────────────────────────────────────────────────────────
class _Member {
  final String name;
  final String role;
  final String tag;
  final String bio;
  final String email;
  final String github;

  const _Member({
    required this.name,
    required this.role,
    required this.tag,
    required this.bio,
    required this.email,
    required this.github,
  });
}

// ─────────────────────────────────────────────────────────────
// FLIP CARD (unchanged)
// ─────────────────────────────────────────────────────────────
class _FlipMemberCard extends StatefulWidget {
  final _Member member;
  const _FlipMemberCard({required this.member});

  @override
  State<_FlipMemberCard> createState() => _FlipMemberCardState();
}

class _FlipMemberCardState extends State<_FlipMemberCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;
  bool _showingBack = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 550),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    if (_showingBack) {
      _controller.reverse();
    } else {
      _controller.forward();
    }
    setState(() => _showingBack = !_showingBack);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggle,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, _) {
          final angle = _animation.value * math.pi;
          final isFront = angle < math.pi / 2;

          final transform = Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateY(angle);

          return Transform(
            alignment: Alignment.center,
            transform: transform,
            child: isFront
                ? _FrontFace(member: widget.member)
                : Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()..rotateY(math.pi),
                    child: _BackFace(member: widget.member),
                  ),
          );
        },
      ),
    );
  }
}

class _FrontFace extends StatelessWidget {
  final _Member member;
  const _FrontFace({required this.member});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Flexible so the avatar shrinks when the card is small.
            Flexible(
              child: CircleAvatar(
                radius: 28,
                backgroundColor:
                    Theme.of(context).colorScheme.secondaryContainer,
                child: Text(
                  member.name[0],
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              member.name,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 2),
            Text(
              member.role,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                member.tag,
                style: TextStyle(
                  fontSize: 10,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BackFace extends StatelessWidget {
  final _Member member;
  const _BackFace({required this.member});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      color: Theme.of(context).colorScheme.secondaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              member.name,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 6),
            Flexible(
              child: Text(
                member.bio,
                textAlign: TextAlign.center,
                maxLines: 5,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 11, height: 1.3),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  iconSize: 18,
                  visualDensity: VisualDensity.compact,
                  icon: const Icon(Icons.email_outlined),
                  onPressed: () {/* TODO */},
                ),
                IconButton(
                  iconSize: 18,
                  visualDensity: VisualDensity.compact,
                  icon: const Icon(Icons.code),
                  onPressed: () {/* TODO */},
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
