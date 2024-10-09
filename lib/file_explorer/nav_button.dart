import 'package:flutter/material.dart';

class NavButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool selected; // Added selected property

  const NavButton({
    Key? key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.selected = false, // Default to false
  }) : super(key: key);

  @override
  _NavButtonState createState() => _NavButtonState();
}

class _NavButtonState extends State<NavButton> {
  bool _isHovered = false; // Track hover state

  @override
  Widget build(BuildContext context) {
    final Color selectedColor = Theme.of(context).colorScheme.primary;
    final Color normalColor = Theme.of(context).colorScheme.onSurface;

    return MouseRegion(
      onEnter: (_) {
        setState(() {
          _isHovered = true;
        });
      },
      onExit: (_) {
        setState(() {
          _isHovered = false;
        });
      },
      child: ListTile(
        leading: Icon(
          widget.icon,
          color: widget.selected
              ? selectedColor
              : _isHovered
              ? selectedColor.withOpacity(0.7)
              : normalColor,
        ),
        title: Text(
          widget.label,
          style: TextStyle(
            color: widget.selected
                ? selectedColor
                : _isHovered
                ? selectedColor.withOpacity(0.7)
                : normalColor,
          ),
        ),
        onTap: widget.onTap,
        tileColor: widget.selected
            ? selectedColor.withOpacity(0.1)
            : _isHovered
            ? Colors.grey.withOpacity(0.1)
            : Colors.transparent,
      ),
    );
  }
}