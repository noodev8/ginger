import 'package:flutter/material.dart';
import 'coffee_stamp_animation.dart';

class CoffeeStampTestWidget extends StatefulWidget {
  const CoffeeStampTestWidget({super.key});

  @override
  State<CoffeeStampTestWidget> createState() => _CoffeeStampTestWidgetState();
}

class _CoffeeStampTestWidgetState extends State<CoffeeStampTestWidget> {
  bool _showAnimation = false;

  void _triggerAnimation() {
    setState(() {
      _showAnimation = true;
    });
  }

  void _onAnimationComplete() {
    setState(() {
      _showAnimation = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return CoffeeStampOverlay(
      showAnimation: _showAnimation,
      message: '+1 Point!',
      onAnimationComplete: _onAnimationComplete,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Coffee Stamp Animation Test'),
          backgroundColor: const Color(0xFF8B7355),
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Test the Coffee Stamp Animation',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF8B7355),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: _showAnimation ? null : _triggerAnimation,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8B7355),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Trigger Coffee Stamp Animation',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                _showAnimation ? 'Animation Playing...' : 'Ready to animate!',
                style: TextStyle(
                  fontSize: 16,
                  color: _showAnimation ? Colors.green : Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
