import 'package:flutter/material.dart';
import 'package:vision_sandbox/pages/home/welcome_page.dart';
import 'home/welcome_page.dart';
import 'home/project_page.dart';
import 'home/team_page.dart';
import 'home/more_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePage();
}

class _HomePage extends State<HomePage> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;
  static const List<String> _titles = ['Home Page','Project Page', 'Team Page', 'Moreeeeeeeeee'];// List of titles corresponding to each page
  // Direction of slide animation: 
  // 1-> from the right (next page)->title enters from the Right
  // -1 -> from the left (previous page)->title enters from the Left
  int _direction = 1;
  int _targetIndex = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
         title: AnimatedSwitcher(
          duration: const Duration(milliseconds: 800), // duration of animation
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          transitionBuilder: (child, anim) {
            final childIndex = (child.key as ValueKey<int>).value;
            final isIncoming = childIndex == _targetIndex;
            final begin = isIncoming
              ? Offset(_direction.toDouble(), 0.0)   // enters from +dir
              : Offset.zero;                          // starts at center

            final end = isIncoming
              ? Offset.zero                           // ends at center
              : Offset(-_direction.toDouble(), 0.0);  // exits to -dir

            return FadeTransition(
              opacity: anim,
              child: SlideTransition(
                  position: Tween(
                    begin: begin,
                    end: end,
                  ).animate(anim),
              child: child,
              ),
            );
          },
          child: Text(
            _titles[_currentIndex],
            key: ValueKey(_currentIndex),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        // page indicator of appBar
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(20),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_titles.length, (i) {
                final selected = i == _currentIndex;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOut,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  height: 6,
                  width: selected ? 20 : 6,
                  decoration: BoxDecoration(
                    color: selected
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.outlineVariant,
                    borderRadius: BorderRadius.circular(3),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _direction = index > _currentIndex ? 1 : -1; // Capture the direction BEFORE updating _currentIndex.
            _targetIndex = index;
            _currentIndex = index;
          });
        },
        children: const[
          WelcomePage(),
          ProjectPage(),
          TeamPage(),
          MorePage(),
        ],
      ),
    );
  }
}
