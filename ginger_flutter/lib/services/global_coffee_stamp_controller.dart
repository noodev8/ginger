import 'package:flutter/foundation.dart';

enum AnimationType { points, reward }

class GlobalCoffeeStampController extends ChangeNotifier {
  static final GlobalCoffeeStampController _instance = GlobalCoffeeStampController._internal();
  factory GlobalCoffeeStampController() => _instance;
  GlobalCoffeeStampController._internal();

  bool _showAnimation = false;
  String _message = '+1 Point!';
  AnimationType _animationType = AnimationType.points;

  bool get showAnimation => _showAnimation;
  String get message => _message;
  AnimationType get animationType => _animationType;

  /// Trigger the coffee stamp animation with a custom message
  void showCoffeeStamp({String message = '+1 Point!', AnimationType type = AnimationType.points}) {
    if (kDebugMode) {
      print('[GlobalCoffeeStampController] Showing ${type.name} animation: $message');
      print('[GlobalCoffeeStampController] Has ${hasListeners ? 'listeners' : 'no listeners'}');
    }

    _message = message;
    _animationType = type;
    _showAnimation = true;
    notifyListeners();

    if (kDebugMode) {
      print('[GlobalCoffeeStampController] notifyListeners() called');
    }
  }

  /// Hide the coffee stamp animation
  void hideCoffeeStamp() {
    if (kDebugMode) {
      print('[GlobalCoffeeStampController] Hiding coffee stamp');
    }
    
    _showAnimation = false;
    notifyListeners();
  }

  /// Show coffee stamp for a specific number of points
  void showPointsAdded(int points) {
    final message = '+$points Point${points > 1 ? 's' : ''}!';
    showCoffeeStamp(message: message, type: AnimationType.points);
  }

  /// Show reward redemption animation
  void showRewardRedeemed({String message = 'Reward Redeemed!'}) {
    showCoffeeStamp(message: message, type: AnimationType.reward);
  }
}
