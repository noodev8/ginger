import 'package:flutter/material.dart';
import '../services/points_service.dart';
import '../models/loyalty_points.dart';

class UserPointsSummaryWidget extends StatefulWidget {
  final int userId;

  const UserPointsSummaryWidget({super.key, required this.userId});

  @override
  State<UserPointsSummaryWidget> createState() => _UserPointsSummaryWidgetState();
}

class _UserPointsSummaryWidgetState extends State<UserPointsSummaryWidget> {
  final PointsService _pointsService = PointsService();
  LoyaltyPoints? _loyaltyPoints;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPoints();
  }

  Future<void> _loadPoints() async {
    try {
      final points = await _pointsService.getUserPoints(widget.userId);
      if (mounted) {
        setState(() {
          _loyaltyPoints = points;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Text(
        'Loading points...',
        style: TextStyle(
          color: Colors.white70,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      );
    }

    final currentPoints = _loyaltyPoints?.currentPoints ?? 0;
    final freeCoffees = currentPoints ~/ 10; // Integer division - how many free coffees earned

    return Text(
      '$currentPoints Points • $freeCoffees Free Coffees Earned',
      style: const TextStyle(
        color: Colors.white70,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}
