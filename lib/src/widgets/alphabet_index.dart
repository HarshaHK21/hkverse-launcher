import 'package:flutter/material.dart';

import '../theme.dart';

/// A-Z quick-scroll rail fixed to the right edge. Dragging/tapping a letter
/// scrolls the app list to the first app in that section.
class AlphabetIndex extends StatefulWidget {
  const AlphabetIndex({
    super.key,
    required this.letters,
    required this.activeLetter,
    required this.onLetterSelected,
  });

  /// Sections present in the app list (e.g. `['#', 'A', 'B', ...]`).
  final List<String> letters;
  final String activeLetter;
  final ValueChanged<String> onLetterSelected;

  @override
  State<AlphabetIndex> createState() => _AlphabetIndexState();
}

class _AlphabetIndexState extends State<AlphabetIndex> {
  void _selectAt(double dy, double height) {
    if (widget.letters.isEmpty || height <= 0) return;
    final index = (dy / (height / widget.letters.length))
        .floor()
        .clamp(0, widget.letters.length - 1);
    widget.onLetterSelected(widget.letters[index]);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final height = constraints.maxHeight;
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: (d) => _selectAt(d.localPosition.dy, height),
          onVerticalDragStart: (d) => _selectAt(d.localPosition.dy, height),
          onVerticalDragUpdate: (d) => _selectAt(d.localPosition.dy, height),
          child: SizedBox(
            width: 30,
            height: height,
            child: Column(
              children: [
                for (final letter in widget.letters)
                  Expanded(
                    child: Center(
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 120),
                        curve: Curves.easeOut,
                        alignment: Alignment.center,
                        child: Text(
                          letter,
                          style: TextStyle(
                            fontFamily: AppTypography.body,
                            fontWeight:
                                letter == widget.activeLetter
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                            fontSize: 10,
                            color: letter == widget.activeLetter
                                ? AppColors.accent
                                : AppColors.textMuted,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}