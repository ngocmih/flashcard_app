import 'package:flutter/material.dart';
import 'dart:math';

class FlashcardItem extends StatefulWidget {
  final String question;
  final String answer;
  final bool isLearned;

  const FlashcardItem({
    super.key,
    required this.question,
    required this.answer,
    required this.isLearned,
  });

  @override
  State<FlashcardItem> createState() => _FlashcardItemState();
}

class _FlashcardItemState extends State<FlashcardItem>
    with SingleTickerProviderStateMixin {
  bool _showFront = true;
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(duration: const Duration(milliseconds: 500), vsync: this);
    _animation = Tween<double>(begin: 0, end: 1).animate(_controller);
  }

  void _flipCard() {
    if (_showFront) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
    setState(() {
      _showFront = !_showFront;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _flipCard,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          final isFront = _animation.value < 0.5;
          final angle = _animation.value * pi;

          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.rotationY(angle),
            child: Container(
              decoration: BoxDecoration(
                color: widget.isLearned
                    ? Colors.green.shade100
                    : (isFront ? Colors.white : Colors.teal.shade100),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 8,
                    offset: Offset(2, 4),
                  )
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: isFront
                  ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.question,
                    style: const TextStyle(fontSize: 18),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '(Chạm để xem đáp án)',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              )
                  : Transform(
                alignment: Alignment.center,
                transform: Matrix4.rotationY(pi),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.answer,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '(Chạm để quay lại)',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
