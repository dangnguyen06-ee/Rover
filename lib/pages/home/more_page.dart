import 'package:flutter/material.dart';

/// ─────────────────────────────────────────────────────────────
/// MORE PAGE
/// Sectioned menu list — Features / Support / About.
/// Each section has a header and a group of tappable rows.
/// ─────────────────────────────────────────────────────────────
class MorePage extends StatelessWidget {
  const MorePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: [
        // ── FEATURES ─────────────────────────────────────────
        const _SectionHeader('Features'),
        _MenuTile(
          icon: Icons.sports_esports,
          label: 'Manual Control',
          onTap: () {
            // TODO: navigate to Manual Control tab,
            // or push a detail page.
          },
        ),
        _MenuTile(
          icon: Icons.smart_toy,
          label: 'Autonomous Mode',
          onTap: () {
            // TODO: navigate to Autonomous tab.
          },
        ),
        _MenuTile(
          icon: Icons.camera_alt_outlined,
          label: 'Camera Stream',
          onTap: () {
            // TODO: open gesture_camera_page.
          },
        ),

        // ── SUPPORT ──────────────────────────────────────────
        const _SectionHeader('Support'),
        _MenuTile(
          icon: Icons.description_outlined,
          label: 'Documentation',
          onTap: () {
            // TODO: launch docs URL.
          },
        ),
        _MenuTile(
          icon: Icons.bug_report_outlined,
          label: 'Report a Bug',
          onTap: () {
            // TODO: launch issue tracker.
          },
        ),
        _MenuTile(
          icon: Icons.star_outline,
          label: 'Rate the App',
          onTap: () {
            // TODO: launch store listing.
          },
        ),

        // ── ABOUT ────────────────────────────────────────────
        const _SectionHeader('About'),
        _MenuTile(
          icon: Icons.groups_outlined,
          label: 'Credits',
          onTap: () {
            // TODO: show credits dialog or push page.
          },
        ),
        _MenuTile(
          icon: Icons.article_outlined,
          label: 'Licenses',
          onTap: () {
            // Built-in Flutter license page:
            // showLicensePage(context: context);
          },
        ),
        _MenuTile(
          icon: Icons.privacy_tip_outlined,
          label: 'Privacy Policy',
          onTap: () {
            // TODO: launch privacy URL.
          },
        ),

        const SizedBox(height: 24),

        // ── Footer ───────────────────────────────────────────
        Center(
          child: Text(
            // Tweak: your app version string.
            'Rover Parker  •  v1.0.0',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

/// ─────────────────────────────────────────────────────────────
/// SECTION HEADER
/// Small uppercase label with letter-spacing, tinted with the
/// primary color. Used between menu groups.
/// ─────────────────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      // Tweak: header padding. fromLTRB(left, top, right, bottom).
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 6),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          // Tweak: letter spacing. 1.2 is subtle; 2.0 is editorial.
          letterSpacing: 1.2,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}

/// ─────────────────────────────────────────────────────────────
/// MENU TILE
/// One row in the menu — icon, label, chevron. Tap calls onTap.
/// Falls back to a "coming soon" snackbar if onTap is null.
/// ─────────────────────────────────────────────────────────────
class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const _MenuTile({
    required this.icon,
    required this.label,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      trailing: const Icon(Icons.chevron_right, size: 20),
      onTap: onTap ??
          () {
            // Default fallback so every tile does *something* visually.
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('$label — coming soon')),
            );
          },
    );
  }
}
