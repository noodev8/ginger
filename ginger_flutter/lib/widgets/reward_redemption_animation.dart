import 'package:flutter/material.dart';
import 'dart:math' as math;

class RewardRedemptionAnimation extends StatefulWidget {
  final VoidCallback? onAnimationComplete;
  final double size;
  final Color stampColor;
  final String message;

  const RewardRedemptionAnimation({
    super.key,
    this.onAnimationComplete,
    this.size = 140, // Slightly larger than points animation
    this.stampColor = const Color(0xFFFF8F00), // Warm amber/orange
    this.message = 'Reward Redeemed!',
  });

  @override
  State<RewardRedemptionAnimation> createState() => _RewardRedemptionAnimationState();
}

class _RewardRedemptionAnimationState extends State<RewardRedemptionAnimation>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _rotationController;
  late AnimationController _fadeController;
  late AnimationController _sparkleController;
  late AnimationController _pulseController;

  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _sparkleAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    // Scale animation controller
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    // Rotation animation controller
    _rotationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // Fade animation controller
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // Sparkle animation controller
    _sparkleController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    // Pulse animation controller
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    // Scale animation - more dramatic entrance
    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));

    // Rotation animation - celebratory spin
    _rotationAnimation = Tween<double>(
      begin: -0.2,
      end: 0.1,
    ).animate(CurvedAnimation(
      parent: _rotationController,
      curve: Curves.easeInOut,
    ));

    // Fade animation - stays visible longer then fades
    _fadeAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: const Interval(0.8, 1.0, curve: Curves.easeOut),
    ));

    // Sparkle animation - for celebratory effect
    _sparkleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _sparkleController,
      curve: Curves.easeInOut,
    ));

    // Pulse animation - for the coffee cup
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.3,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.elasticInOut,
    ));

    // Start the animation sequence
    _startAnimation();
  }

  void _startAnimation() async {
    // Start all animations with slight delays
    _scaleController.forward();
    
    await Future.delayed(const Duration(milliseconds: 150));
    _rotationController.forward();
    _sparkleController.forward();
    
    await Future.delayed(const Duration(milliseconds: 200));
    _pulseController.forward().then((_) {
      _pulseController.reverse().then((_) {
        _pulseController.forward().then((_) {
          _pulseController.reverse();
        });
      });
    });
    
    await Future.delayed(const Duration(milliseconds: 400));
    _fadeController.forward();

    // Complete the animation after total duration
    await Future.delayed(const Duration(milliseconds: 3000)); // Even longer for visibility
    if (widget.onAnimationComplete != null) {
      widget.onAnimationComplete!();
    }
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _rotationController.dispose();
    _fadeController.dispose();
    _sparkleController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _scaleAnimation,
        _rotationAnimation,
        _fadeAnimation,
        _sparkleAnimation,
        _pulseAnimation,
      ]),
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: Transform.rotate(
              angle: _rotationAnimation.value,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Sparkle effects around the stamp
                  ...List.generate(8, (index) {
                    final angle = (index * 45.0) * (3.14159 / 180.0);
                    final distance = widget.size * 0.7 * _sparkleAnimation.value;
                    return Transform.translate(
                      offset: Offset(
                        distance * math.cos(angle),
                        distance * math.sin(angle),
                      ),
                      child: Opacity(
                        opacity: _sparkleAnimation.value * (1.0 - _fadeAnimation.value),
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: widget.stampColor.withValues(alpha: 0.8),
                            boxShadow: [
                              BoxShadow(
                                color: widget.stampColor.withValues(alpha: 0.4),
                                blurRadius: 4,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                  
                  // Main stamp container
                  Container(
                    width: widget.size,
                    height: widget.size,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: widget.stampColor.withValues(alpha: 0.9),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFE65100).withValues(alpha: 0.4), // Darker orange shadow
                          blurRadius: 20,
                          spreadRadius: 4,
                          offset: const Offset(0, 6),
                        ),
                      ],
                      border: Border.all(
                        color: widget.stampColor.withValues(alpha: 0.8),
                        width: 4,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Takeaway coffee cup icon with pulse animation
                        Transform.scale(
                          scale: _pulseAnimation.value,
                          child: Container(
                            width: widget.size * 0.45,
                            height: widget.size * 0.45,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFE65100).withValues(alpha: 0.3),
                                  blurRadius: 10,
                                  spreadRadius: 2,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(widget.size * 0.08),
                              child: Icon(
                                Icons.local_cafe, // Takeaway coffee cup icon
                                size: widget.size * 0.25,
                                color: widget.stampColor,
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
                            fontSize: widget.size * 0.1,
                            fontWeight: FontWeight.bold,
                            shadows: [
                              Shadow(
                                color: const Color(0xFFE65100).withValues(alpha: 0.6),
                                blurRadius: 3,
                                offset: const Offset(1, 1),
                              ),
                            ],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
