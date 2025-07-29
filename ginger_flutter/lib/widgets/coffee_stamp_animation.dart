import 'package:flutter/material.dart';

class CoffeeStampAnimation extends StatefulWidget {
  final VoidCallback? onAnimationComplete;
  final double size;
  final Color stampColor;
  final String message;

  const CoffeeStampAnimation({
    super.key,
    this.onAnimationComplete,
    this.size = 120,
    this.stampColor = const Color(0xFF5D4037), // Darker brown
    this.message = '+1 Point!',
  });

  @override
  State<CoffeeStampAnimation> createState() => _CoffeeStampAnimationState();
}

class _CoffeeStampAnimationState extends State<CoffeeStampAnimation>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _rotationController;
  late AnimationController _fadeController;
  late AnimationController _bounceController;

  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();

    // Scale animation controller
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // Rotation animation controller
    _rotationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    // Fade animation controller
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    // Bounce animation controller
    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    // Scale animation - starts small, grows to full size, then slightly shrinks
    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));

    // Rotation animation - slight rotation for stamp effect
    _rotationAnimation = Tween<double>(
      begin: -0.1,
      end: 0.05,
    ).animate(CurvedAnimation(
      parent: _rotationController,
      curve: Curves.easeInOut,
    ));

    // Fade animation - stays visible then fades out
    _fadeAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: const Interval(0.7, 1.0, curve: Curves.easeOut),
    ));

    // Bounce animation for the coffee icon
    _bounceAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _bounceController,
      curve: Curves.elasticInOut,
    ));

    // Start the animation sequence
    _startAnimation();
  }

  void _startAnimation() async {
    // Start all animations with slight delays
    _scaleController.forward();
    
    await Future.delayed(const Duration(milliseconds: 100));
    _rotationController.forward();
    
    await Future.delayed(const Duration(milliseconds: 200));
    _bounceController.forward().then((_) {
      _bounceController.reverse();
    });
    
    await Future.delayed(const Duration(milliseconds: 300));
    _fadeController.forward();

    // Complete the animation after total duration
    await Future.delayed(const Duration(milliseconds: 1500));
    if (widget.onAnimationComplete != null) {
      widget.onAnimationComplete!();
    }
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _rotationController.dispose();
    _fadeController.dispose();
    _bounceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _scaleAnimation,
        _rotationAnimation,
        _fadeAnimation,
        _bounceAnimation,
      ]),
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: Transform.rotate(
              angle: _rotationAnimation.value,
              child: Container(
                width: widget.size,
                height: widget.size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.stampColor.withValues(alpha: 0.9),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF3E2723).withValues(alpha: 0.4), // Darker brown shadow
                      blurRadius: 15,
                      spreadRadius: 3,
                      offset: const Offset(0, 5),
                    ),
                  ],
                  border: Border.all(
                    color: widget.stampColor.withValues(alpha: 0.8),
                    width: 3,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Coffee icon with bounce animation
                    Transform.scale(
                      scale: _bounceAnimation.value,
                      child: Container(
                        width: widget.size * 0.4,
                        height: widget.size * 0.4,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF3E2723).withValues(alpha: 0.3), // Darker brown shadow
                              blurRadius: 8,
                              spreadRadius: 1,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(widget.size * 0.08),
                          child: Image.asset(
                            'assets/coffee_icon2.png',
                            fit: BoxFit.contain,
                            color: widget.stampColor,
                            colorBlendMode: BlendMode.srcIn,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: widget.size * 0.05),
                    // Message text
                    Text(
                      widget.message,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: widget.size * 0.12,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(
                            color: const Color(0xFF3E2723).withValues(alpha: 0.6), // Darker brown shadow
                            blurRadius: 2,
                            offset: const Offset(1, 1),
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// Overlay widget to show the stamp animation on top of other content
class CoffeeStampOverlay extends StatefulWidget {
  final Widget child;
  final bool showAnimation;
  final VoidCallback? onAnimationComplete;
  final String message;

  const CoffeeStampOverlay({
    super.key,
    required this.child,
    this.showAnimation = false,
    this.onAnimationComplete,
    this.message = '+1 Point!',
  });

  @override
  State<CoffeeStampOverlay> createState() => _CoffeeStampOverlayState();
}

class _CoffeeStampOverlayState extends State<CoffeeStampOverlay> {
  bool _showStamp = false;

  @override
  void didUpdateWidget(CoffeeStampOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.showAnimation && !oldWidget.showAnimation) {
      setState(() {
        _showStamp = true;
      });
    }
  }

  void _onAnimationComplete() {
    setState(() {
      _showStamp = false;
    });
    if (widget.onAnimationComplete != null) {
      widget.onAnimationComplete!();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (_showStamp)
          Positioned.fill(
            child: Container(
              color: Colors.black.withValues(alpha: 0.3),
              child: Center(
                child: CoffeeStampAnimation(
                  onAnimationComplete: _onAnimationComplete,
                  message: widget.message,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
