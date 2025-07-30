import 'package:flutter/material.dart';

class PresetProfileIcons {
  static const List<PresetIcon> icons = [
    PresetIcon(
      id: 'coffee_icon_1',
      name: 'Coffee Cup 1',
      assetPath: 'assets/coffee_icon_1.png',
      backgroundColor: Color(0xFFFFF3E0), // Light cream
    ),
    PresetIcon(
      id: 'coffee_icon_2',
      name: 'Coffee Cup 2',
      assetPath: 'assets/coffee_icon_2.png',
      backgroundColor: Color(0xFFD7CCC8), // Light brown
    ),
    PresetIcon(
      id: 'coffee_icon_3',
      name: 'Coffee Cup 3',
      assetPath: 'assets/coffee_icon_3.png',
      backgroundColor: Color(0xFFF5F5F5), // Light grey
    ),
    PresetIcon(
      id: 'coffee_icon_4',
      name: 'Coffee Cup 4',
      assetPath: 'assets/coffee_icon_4.png',
      backgroundColor: Color(0xFFFFF8E1), // Light amber
    ),
    PresetIcon(
      id: 'coffee_icon_5',
      name: 'Coffee Cup 5',
      assetPath: 'assets/coffee_icon_5.png',
      backgroundColor: Color(0xFFEFEBE9), // Very light brown
    ),
    PresetIcon(
      id: 'coffee_icon_6',
      name: 'Coffee Cup 6',
      assetPath: 'assets/coffee_icon_6.png',
      backgroundColor: Color(0xFFE8F5E8), // Light green
    ),
  ];

  static PresetIcon? getIconById(String id) {
    try {
      return icons.firstWhere((icon) => icon.id == id);
    } catch (e) {
      return null;
    }
  }

  static PresetIcon get defaultIcon => icons.first; // coffee_icon_1
}

class PresetIcon {
  final String id;
  final String name;
  final IconData? icon;
  final String? assetPath;
  final Color? color;
  final Color backgroundColor;

  const PresetIcon({
    required this.id,
    required this.name,
    this.icon,
    this.assetPath,
    this.color,
    required this.backgroundColor,
  }) : assert(icon != null || assetPath != null, 'Either icon or assetPath must be provided');
}

class PresetProfileIconWidget extends StatelessWidget {
  final PresetIcon presetIcon;
  final double size;
  final bool isSelected;
  final VoidCallback? onTap;

  const PresetProfileIconWidget({
    super.key,
    required this.presetIcon,
    this.size = 60,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor = presetIcon.color ?? const Color(0xFF5D4037);
    final shadowColor = presetIcon.color ?? const Color(0xFF5D4037);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: presetIcon.backgroundColor,
          border: Border.all(
            color: isSelected
                ? borderColor
                : borderColor.withValues(alpha: 0.3),
            width: isSelected ? 3 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: shadowColor.withValues(alpha: 0.2),
              blurRadius: 8,
              spreadRadius: 1,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: presetIcon.assetPath != null
            ? ClipOval(
                child: Image.asset(
                  presetIcon.assetPath!,
                  width: size,
                  height: size,
                  fit: BoxFit.cover,
                ),
              )
            : Icon(
                presetIcon.icon!,
                size: size * 0.5,
                color: presetIcon.color,
              ),
      ),
    );
  }
}

class ProfileIconSelector extends StatelessWidget {
  final String? selectedIconId;
  final Function(String iconId) onIconSelected;

  const ProfileIconSelector({
    super.key,
    this.selectedIconId,
    required this.onIconSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Choose Profile Icon',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF5D4037),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: PresetProfileIcons.icons.map((presetIcon) {
            final isSelected = selectedIconId == presetIcon.id;
            return Column(
              children: [
                PresetProfileIconWidget(
                  presetIcon: presetIcon,
                  size: 70,
                  isSelected: isSelected,
                  onTap: () => onIconSelected(presetIcon.id),
                ),
                const SizedBox(height: 4),
                Text(
                  presetIcon.name,
                  style: TextStyle(
                    fontSize: 12,
                    color: isSelected 
                        ? presetIcon.color 
                        : Colors.grey[600],
                    fontWeight: isSelected 
                        ? FontWeight.bold 
                        : FontWeight.normal,
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }
}

class UserProfileIcon extends StatelessWidget {
  final String? iconId;
  final double size;

  const UserProfileIcon({
    super.key,
    this.iconId,
    this.size = 40,
  });

  @override
  Widget build(BuildContext context) {
    final presetIcon = iconId != null 
        ? PresetProfileIcons.getIconById(iconId!)
        : null;
    
    final icon = presetIcon ?? PresetProfileIcons.defaultIcon;

    return PresetProfileIconWidget(
      presetIcon: icon,
      size: size,
    );
  }
}
