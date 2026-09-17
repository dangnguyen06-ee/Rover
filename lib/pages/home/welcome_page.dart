import 'package:flutter/material.dart';

/// Landing page that greets the user. Sits as the FIRST child of the
class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePage();
}

class _WelcomePage extends State<WelcomePage> {
  // Holds the current text in the search bar.
  // Currently cosmetic — will drive filtering/jump later.
  String _query = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        // Search Bar
        TextField(
          controller: _searchController,
          onChanged: (value) => setState(() => _query = value),
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            hintText: 'Search about this app', // this is the hint before search
            prefixIcon: const Icon(Icons.search),
            suffixIcon: _query.isEmpty
              ? null
              : IconButton(
                onPressed: () {
                _searchController.clear();
                setState(() => _query = '');
                },
                icon: const Icon(Icons.close),
                tooltip:'Clear',
                ),
            border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(28),
            borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor:
              Theme.of(context).colorScheme.surfaceContainerHighest,
            contentPadding:
              const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
          ),
        ),

        const SizedBox(height: 20),

        // Welcome Text
        Card(
          color: Theme.of(context).colorScheme.primaryContainer,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.waving_hand,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Welcome',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Rover Parker is ready. Swipe to explore the project, '
                  'meet the team, or fine-tune settings.',
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.4,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 24),

                // ── PLACEHOLDER FOR NEXT SECTIONS ─────────────────────
        // When you're ready, drop Quick Access cards, recent activity,
        // shortcuts, etc. right here. The page already scrolls
        // vertically, so anything you add just works.
        if (_query.isNotEmpty)
          Text(
            'Searching for: "$_query"',
            style: const TextStyle(color: Colors.grey),
          ),
      ],
    );
  }
}
