import 'dart:math' as math;
import 'package:flutter/material.dart';

/// ─────────────────────────────────────────────────────────────
/// TEAM PAGE
/// Flip-card grid of team members. Tap a card → it rotates 180°
/// around its Y axis to reveal the bio and contact icons.
/// ─────────────────────────────────────────────────────────────
class TeamPage extends StatelessWidget {
  const TeamPage({super.key});

  // ── EDIT HERE: your real team members ──────────────────────
  // Each entry drives both the front and back face of one card.
  static const List<_Member> _members = [
    _Member(
      name: 'Danny',
      role: 'Firmware & Integration',
      tag: 'ESP32',
      bio: 'Builds the brain. Handles real-time control loops and the Wi-Fi protocol.',
      email: 'danny@example.com',
      github: 'github.com/danny',
    ),
    _Member(
      name: 'Alex',
      role: 'Computer Vision',
      tag: 'MediaPipe',
      bio: 'Trains and tunes the gesture recognizer. Owns the camera pipeline.',
      email: 'alex@example.com',
      github: 'github.com/alex',
    ),
    _Member(
      name: 'Sam',
      role: 'Hardware & PCB',
      tag: 'Sensors',
      bio: 'Designs the board and wiring. Calibrates ToF and IMU sensor fusion.',
      email: 'sam@example.com',
      github: 'github.com/sam',
    ),
    _Member(
      name: 'Jordan',
      role: 'Mobile App',
      tag: 'Flutter',
      bio: 'Owns the Flutter app. Bridges Bluetooth/Wi-Fi commands to the rover.',
      email: 'jordan@example.com',
      github: 'github.com/jordan',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // ── Header ───────────────────────────────────────────
        const Center(
          child: Text(
            'Meet the Crew',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 4),
        const Center(
          child: Text(
            'Tap a card to flip it',
            style: TextStyle(color: Colors.grey),
          ),
        ),
        const SizedBox(height: 20),

        // ── Grid of flip cards ───────────────────────────────
        // shrinkWrap + NeverScrollableScrollPhysics so the grid
        // doesn't scroll independently — the outer ListView owns
        // the vertical scroll for the whole page.
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _members.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            // Tweak: 2 = two cards per row. Use 1 for one big card,
            // 3 for a compact grid on wider screens.
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            // Tweak: lower value = taller card. 0.75 is a nice
            // portrait shape for the flip effect.
            childAspectRatio: 0.75,
          ),
          itemBuilder: (context, i) => _FlipMemberCard(member: _members[i]),
        ),
      ],
    );
  }
}

/// ─────────────────────────────────────────────────────────────
/// MEMBER DATA MODEL
/// ─────────────────────────────────────────────────────────────
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

/// ─────────────────────────────────────────────────────────────
/// FLIP CARD
/// A card that rotates 180° around its Y axis when tapped.
/// ─────────────────────────────────────────────────────────────
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

  /// True when the BACK face is currently visible.
  bool _showingBack = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      // Tweak: flip speed. 550ms = snappy. 700ms = dramatic.
      duration: const Duration(milliseconds: 550),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      // Tweak: flip easing. easeInOutCubic feels mechanical and clean.
      // Try Curves.easeOutBack for a slight overshoot/bounce.
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    // Haptic tick on tap — remove if you don't want it.
    // Needs: import 'package:flutter/services.dart';
    // HapticFeedback.selectionClick();

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
          // angle goes 0 → π (180°). At π/2 the card is edge-on
          // and invisible, so we swap which face renders there.
          final angle = _animation.value * math.pi;
          final isFront = angle < math.pi / 2;

          // Perspective transform — the 0.001 entry adds depth.
          // Without it, the rotation looks flat.
          final transform = Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateY(angle);

          return Transform(
            alignment: Alignment.center,
            transform: transform,
            child: isFront
                // FRONT — shown while angle < 90°.
                ? _FrontFace(member: widget.member)
                // BACK — counter-rotated so text isn't mirrored.
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

/// ─────────────────────────────────────────────────────────────
/// FRONT FACE — avatar, name, role, tag pill
/// ─────────────────────────────────────────────────────────────
class _FrontFace extends StatelessWidget {
  final _Member member;
  const _FrontFace({required this.member});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              // Tweak: avatar size.
              radius: 32,
              backgroundColor:
                  Theme.of(context).colorScheme.secondaryContainer,
              child: Text(
                // First letter of the name as a placeholder avatar.
                member.name[0],
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              member.name,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              member.role,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 8),

            // Small pill showing the tech tag.
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                member.tag,
                style: TextStyle(
                  fontSize: 11,
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

/// ─────────────────────────────────────────────────────────────
/// BACK FACE — bio + contact icon buttons
/// ─────────────────────────────────────────────────────────────
class _BackFace extends StatelessWidget {
  final _Member member;
  const _BackFace({required this.member});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      // Tweak: back face background. Swap to a custom color if you want.
      color: Theme.of(context).colorScheme.secondaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              member.name,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              member.bio,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, height: 1.35),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Tweak: replace onPressed with url_launcher calls.
                // Add url_launcher: ^6.2.0 to pubspec.yaml.
                IconButton(
                  iconSize: 20,
                  icon: const Icon(Icons.email_outlined),
                  tooltip: member.email,
                  onPressed: () {
                    // TODO: launch mailto:${member.email}
                  },
                ),
                IconButton(
                  iconSize: 20,
                  icon: const Icon(Icons.code),
                  tooltip: member.github,
                  onPressed: () {
                    // TODO: launch https://${member.github}
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}