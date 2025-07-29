import 'package:flutter/material.dart';
import '../services/global_coffee_stamp_controller.dart';
import 'coffee_stamp_animation.dart';
import 'reward_redemption_animation.dart';

class GlobalCoffeeStampOverlay extends StatefulWidget {
  final Widget child;

  const GlobalCoffeeStampOverlay({
    super.key,
    required this.child,
  });

  @override
  State<GlobalCoffeeStampOverlay> createState() => _GlobalCoffeeStampOverlayState();
}

class _GlobalCoffeeStampOverlayState extends State<GlobalCoffeeStampOverlay> {
  final GlobalCoffeeStampController _controller = GlobalCoffeeStampController();
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();
    print('[GlobalCoffeeStampOverlay] Initializing overlay');
    _controller.addListener(_onControllerChange);
    print('[GlobalCoffeeStampOverlay] Listener added to controller');
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerChange);
    _removeOverlay();
    super.dispose();
  }

  void _onControllerChange() {
    print('[GlobalCoffeeStampOverlay] Controller changed - showAnimation: ${_controller.showAnimation}');
    if (_controller.showAnimation) {
      _showOverlay();
    } else {
      _removeOverlay();
    }
  }

  void _showOverlay() {
    if (_overlayEntry != null) {
      return; // Already showing
    }

    print('[GlobalCoffeeStampOverlay] Creating overlay entry');

    _overlayEntry = OverlayEntry(
      builder: (context) => Material(
        color: _controller.animationType == AnimationType.reward
            ? Colors.black.withValues(alpha: 0.5) // Darker background for reward
            : Colors.black.withValues(alpha: 0.3),
        child: Center(
          child: _controller.animationType == AnimationType.points
              ? CoffeeStampAnimation(
                  onAnimationComplete: () {
                    print('[GlobalCoffeeStampOverlay] Points animation completed, hiding overlay');
                    _controller.hideCoffeeStamp();
                  },
                  message: _controller.message,
                )
              : RewardRedemptionAnimation(
                  onAnimationComplete: () {
                    print('[GlobalCoffeeStampOverlay] Reward animation completed, hiding overlay');
                    _controller.hideCoffeeStamp();
                  },
                  message: _controller.message,
                ),
        ),
      ),
    );

    // Insert the overlay at the top level with highest priority
    try {
      Overlay.of(context).insert(_overlayEntry!, above: null); // Insert at the very top
      print('[GlobalCoffeeStampOverlay] Overlay inserted successfully at highest level');
    } catch (e) {
      print('[GlobalCoffeeStampOverlay] Error inserting overlay: $e');
      _overlayEntry = null;
    }
  }

  void _removeOverlay() {
    if (_overlayEntry != null) {
      print('[GlobalCoffeeStampOverlay] Removing overlay');
      _overlayEntry!.remove();
      _overlayEntry = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
